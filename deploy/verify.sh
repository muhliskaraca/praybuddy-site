#!/usr/bin/env bash
# Prüft den Live-Zustand von praybuddy.likafilm.com.
# Vor dem Deploy ausführen (zeigt den Ist-Zustand), danach erneut (muss grün sein).
#
#   ./deploy/verify.sh
#
# Exit-Code 0 = alles in Ordnung, 1 = mindestens eine Prüfung offen.

set -uo pipefail

BASE="https://praybuddy.likafilm.com"
CANON="$BASE/"
fails=0

green() { printf '  \033[32mOK\033[0m   %s\n' "$1"; }
red()   { printf '  \033[31mOFFEN\033[0m %s\n' "$1"; fails=$((fails+1)); }

# Erwartet eine 301 auf die kanonische URL
expect_redirect() {
    local url="$1" label="$2"
    local code loc
    code=$(curl -sS -o /dev/null -w '%{http_code}' --max-time 20 "$url" 2>/dev/null)
    loc=$(curl -sSI --max-time 20 "$url" 2>/dev/null | tr -d '\r' | awk 'tolower($1)=="location:"{print $2}')
    if [[ "$code" == "301" && "$loc" == "$CANON"* ]]; then
        green "$label → 301 $loc"
    else
        red "$label → HTTP $code${loc:+, Location: $loc} (erwartet: 301 auf $CANON)"
    fi
}

expect_status() {
    local url="$1" want="$2" label="$3"
    local code
    code=$(curl -sS -o /dev/null -w '%{http_code}' --max-time 20 "$url" 2>/dev/null)
    if [[ "$code" == "$want" ]]; then green "$label → HTTP $code"
    else red "$label → HTTP $code (erwartet: $want)"; fi
}

echo "Prüfe $BASE"
echo
echo "Weiterleitungen (Duplikat-URLs):"
expect_redirect "http://praybuddy.likafilm.com/"      "http:// ohne TLS"
expect_redirect "https://www.praybuddy.likafilm.com/" "www-Variante"
expect_redirect "$BASE/index.html"                    "/index.html"

echo
echo "Deutsche Sprachversion:"
expect_status "$BASE/de/" 200 "/de/ erreichbar"

if curl -sS --max-time 20 "$BASE/de/" 2>/dev/null | grep -q 'hreflang="de"'; then
    green "/de/ enthält hreflang"
else
    red "/de/ enthält kein hreflang (alte Datei auf dem Server?)"
fi

if curl -sS --max-time 20 "$BASE/sitemap.xml" 2>/dev/null | grep -q '/de/'; then
    green "sitemap.xml enthält /de/"
else
    red "sitemap.xml ohne /de/ (alte Datei auf dem Server?)"
fi

echo
echo "Performance:"
size=$(curl -sS -o /dev/null -w '%{size_download}' --max-time 30 "$BASE/icon.png" 2>/dev/null)
if [[ -n "$size" && "$size" -lt 200000 ]]; then
    green "icon.png = $size Bytes"
else
    red "icon.png = ${size:-?} Bytes (erwartet unter 200000; das 2048px-Original ist noch aktiv)"
fi

echo
echo "Fehlende URLs (Fix vom 29.07.2026):"
# Ohne die Rewrite-Regel auf /404.php antworten die likafilm-Subdomains auf
# jede unbekannte URL mit HTTP 500. Eine .htaccess ohne diese Regel dreht den
# Fix zurueck, ohne dass eine der Pruefungen oben es merkt.
expect_status "$BASE/gibt-es-nicht-$$"     404 "unbekannte URL im Root"
expect_status "$BASE/de/gibt-es-nicht-$$"  404 "unbekannte URL unter /de/"
expect_status "$BASE/404.html"             200 "404.html vorhanden"

echo
echo "Datenschutz und Auslieferung:"
# Die Seite darf keine fremde Ressource nachladen. Google Fonts hat bis zum
# 08.08.2026 die IP jedes Besuchers an Google uebertragen.
extern=0
for p in "/" "/de/"; do
    if curl -sS --max-time 20 "$BASE$p" 2>/dev/null |
        grep -oE '(src|href)="https?://[^"]+"' |
        grep -vE 'praybuddy\.likafilm\.com|apps\.apple\.com|github\.com|//likafilm\.com' |
        grep -q .; then
        red "$p laedt eine fremde Ressource nach"
        extern=1
    fi
done
[[ $extern -eq 0 ]] && green "keine fremden Ressourcen in / und /de/"

expect_status "$BASE/fonts/inter-latin.woff2" 200 "Schriften liegen lokal"

for p in "/" "/de/"; do
    if curl -sS --max-time 20 "$BASE$p" 2>/dev/null | grep -q 'Oberföhringer Str. 246a'; then
        green "$p nennt die ladungsfaehige Anschrift"
    else
        red "$p ohne Anschrift (§ 5 DDG)"
    fi
done

# Die Verifizierungsdatei der Search Console liegt nur auf dem Server. Ein
# mirror --delete aus dem Repo-Ordner wuerde sie abraeumen.
expect_status "$BASE/google3f2d86b09d73d64e.html" 200 "Search-Console-Verifizierung"

echo
echo "Sicherheits-Header:"
hdrs=$(curl -sSI --max-time 20 "$BASE/" 2>/dev/null | tr -d '\r' | tr 'A-Z' 'a-z')
for h in strict-transport-security x-content-type-options referrer-policy content-security-policy; do
    if grep -q "^$h:" <<<"$hdrs"; then green "$h gesetzt"; else red "$h fehlt"; fi
done

# Die hochgeladene .htaccess ist eine Kopie der Vorlage. Laufen sie
# auseinander, deployt man etwas anderes als das, was dokumentiert ist.
repo_root="$(cd "$(dirname "$0")/.." && pwd)"
if cmp -s "$repo_root/.htaccess" "$repo_root/deploy/htaccess-praybuddy"; then
    green ".htaccess stimmt mit der Vorlage ueberein"
else
    red ".htaccess und deploy/htaccess-praybuddy laufen auseinander"
fi

echo
if [[ $fails -eq 0 ]]; then
    echo "Alles erledigt. In der Search Console noch die Sitemap neu einreichen."
else
    echo "$fails Prüfung(en) offen, siehe deploy/README.md."
fi
exit $(( fails > 0 ))
