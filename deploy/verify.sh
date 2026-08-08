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
if [[ $fails -eq 0 ]]; then
    echo "Alles erledigt. In der Search Console noch die Sitemap neu einreichen."
else
    echo "$fails Prüfung(en) offen — siehe deploy/README.md."
fi
exit $(( fails > 0 ))
