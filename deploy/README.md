# Deployment

## Hosting: ALL-INKL.COM (Shared Hosting)

Die IP `85.13.153.47` gehört laut RDAP der **Neue Medien Münnich GmbH**,
also **ALL-INKL.COM**. Daraus folgt alles Weitere:

| | |
|---|---|
| Serverzugriff | **kein Root** — Shared Hosting |
| Webserver | nginx als Proxy, **Apache dahinter** |
| Konfiguration | über **`.htaccess`**, `mod_rewrite` ist standardmäßig aktiv |
| Steuerpanel | KAS — <https://kas.all-inkl.com> |
| Web-Root | typisch `/www/htdocs/<kundennummer>/<verzeichnis>/` |

**Wichtig:** `nginx-praybuddy.conf` lässt sich hier **nicht** einsetzen — dafür
fehlt der Root-Zugriff. Die Datei bleibt nur für den Fall im Repo, dass die
Seite einmal auf einen eigenen Server umzieht. Auf ALL-INKL ist
`htaccess-praybuddy` der richtige Weg.

## Dieses Repo wird nicht automatisch ausgeliefert

Die Datei `CNAME` im Repo-Root stammt aus einem GitHub-Pages-Setup, das nie
aktiv wurde (Pages-IPs wären `185.199.108–111.153`). Sie hat auf ALL-INKL
keine Wirkung. Alle Änderungen müssen manuell hochgeladen werden.

Hochzuladen sind:

```
index.html
de/index.html
robots.txt
sitemap.xml
icon.png
og-image.png
badge-app-store.svg
```

## Schritt 1 — Dateien hochladen

**Per SSH/rsync** (ALL-INKL bietet SSH bei den meisten Tarifen):

```bash
export DEPLOY_USER=DEIN_SSH_USER
export DEPLOY_HOST=praybuddy.likafilm.com
export DEPLOY_PATH=/www/htdocs/KUNDENNUMMER/praybuddy   # echten Pfad im KAS nachsehen

./deploy/upload.sh          # Trockenlauf
./deploy/upload.sh --live   # überträgt wirklich
```

**Oder per FTP / KAS-Dateimanager:** dieselben Dateien, Verzeichnisstruktur
beibehalten (`de/index.html` muss im Unterordner `de/` landen).

## Schritt 2 — Weiterleitungen einrichten

Der Upload allein behebt die Duplikat-URLs **nicht**. Zwei Wege, beide gehen:

### Variante A — `.htaccess` (empfohlen, alles an einer Stelle)

`deploy/htaccess-praybuddy` als `.htaccess` ins Web-Root der Subdomain legen.
Deckt `http://` → `https://`, `www.` → ohne `www` und `/index.html` → `/` ab.

### Variante B — KAS-Oberfläche

Im KAS lassen sich HTTPS-Erzwingung und Weiterleitungen auch klicken:

- *Domain → Bearbeiten → SSL-Schutz* — HTTPS erzwingen, optional HSTS
- *Domain → Bearbeiten → Weiterleitung* — für die `www.`-Variante

Variante B erspart die `.htaccess`-Regeln 1 und 2. Die Regel für
`/index.html` → `/` gibt es im KAS nicht, die braucht in jedem Fall
`.htaccess`.

## Schritt 3 — Kontrolle

```bash
./deploy/verify.sh
```

Prüft sieben Punkte gegen den Live-Server und liefert Exit-Code 1, solange
etwas offen ist. Vor dem Deploy ausführen (zeigt den Ausgangszustand), danach
erneut — dann muss alles grün sein.

## Schritt 4 — Search Console

1. Sitemap neu einreichen: `https://praybuddy.likafilm.com/sitemap.xml`
   (enthält jetzt zusätzlich `/de/`)
2. `https://praybuddy.likafilm.com/de/` über die URL-Prüfung indexieren lassen

Die Meldung *„Alternative Seite mit richtigem kanonischen Tag"* ist an sich
**keine Fehlfunktion** — sie bedeutet, dass Google die Duplikate erkannt und
korrekt auf die kanonische URL zusammengeführt hat. Die Weiterleitungen räumen
die Ursache trotzdem auf.
