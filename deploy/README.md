# Deployment

## Hosting: ALL-INKL.COM (Shared Hosting)

Die IP `85.13.153.47` gehört laut RDAP der **Neue Medien Münnich GmbH**,
also **ALL-INKL.COM**. Daraus folgt alles Weitere:

| | |
|---|---|
| Serverzugriff | **kein Root**, Shared Hosting, **auch kein SSH** |
| Webserver | nginx als Proxy, **Apache dahinter** |
| Konfiguration | über **`.htaccess`**, `mod_rewrite` ist standardmäßig aktiv |
| Steuerpanel | KAS, <https://kas.all-inkl.com> |
| Upload | FTP über den subdomain-eigenen Nutzer `f0184137` |

Der FTP-Nutzer ist **chrooted** auf `/praybuddy.likafilm.com/`. Den FTP-Nutzer
einer anderen Subdomain zu verwenden, legt die Dateien in deren Chroot ab, wo
nginx sie nie findet. Hintergrund und Diagnose-Test:
`~/.claude/memory/reference_allinkl_ftp_chroot_pitfall.md`.

## Dieses Repo wird nicht automatisch ausgeliefert

Alle Änderungen müssen hochgeladen werden. Der zweite Quellordner
`~/praybuddy-website/` hält denselben Stand und enthält zusätzlich
`tools/.env-deploy` mit den FTP-Zugangsdaten (nicht im Repo).

Hochzuladen sind:

```
index.html
de/index.html
robots.txt
sitemap.xml
icon.png
og-image.png
badge-app-store.svg
fonts/*.woff2
fonts/LICENSE.txt
404.html
404.php
google3f2d86b09d73d64e.html
.htaccess
```

## Schritt 1: Dateien hochladen

```bash
./deploy/upload.sh          # Trockenlauf
./deploy/upload.sh --live   # überträgt wirklich
```

Das Skript nutzt `lftp` mit gezieltem `put`, **nicht** `mirror --delete`. Ein
Mirror aus diesem Ordner würde serverseitige Dateien löschen, die hier nicht
liegen. Zugangsdaten liest es aus `~/praybuddy-website/tools/.env-deploy`.

Alternativ derselbe Satz Dateien per KAS-Dateimanager, Verzeichnisstruktur
beibehalten (`de/index.html` muss im Unterordner `de/` landen).

## Schritt 2: .htaccess

`deploy/htaccess-praybuddy` ist die Vorlage, `/.htaccess` im Repo-Root ist die
Kopie, die tatsächlich hochgeladen wird. Beide müssen übereinstimmen,
`verify.sh` prüft das.

Sie deckt vier Dinge ab, und die **Reihenfolge ist bindend**:

1. `http://` auf `https://`
2. `www.` auf ohne `www`
3. `/index.html` auf `/`
4. Catch-all auf `/404.php`, damit fehlende URLs 404 statt 500 liefern

Punkt 4 stammt vom 29.07.2026 und gilt für alle likafilm-Subdomains:
`ErrorDocument 404` wird dort ignoriert, ohne die Rewrite-Regel antwortet der
Server auf jede unbekannte URL mit HTTP 500. Steht der Catch-all vor den
Redirects, greifen die Redirects nie.

Dazu kommen Sicherheits-Header und eine Content-Security-Policy. Die CSP ist
eng gefasst (`default-src 'self'`), was nur funktioniert, weil die Seite keine
fremde Ressource mehr lädt. Wer eine externe Einbindung ergänzt, muss die CSP
mitziehen, sonst blockt der Browser sie stillschweigend.

Im KAS ließen sich HTTPS-Erzwingung und die `www.`-Weiterleitung auch klicken.
Für `/index.html` auf `/` und für Punkt 4 gibt es dort nichts, deshalb liegt
alles in der `.htaccess`.

## Schritt 3: Kontrolle

```bash
./deploy/verify.sh
```

Prüft den Live-Server und liefert Exit-Code 1, solange etwas offen ist. Vor dem
Deploy ausführen (zeigt den Ausgangszustand), danach erneut.

## Schritt 4: Search Console

1. Sitemap einreichen: `https://praybuddy.likafilm.com/sitemap.xml`
2. `https://praybuddy.likafilm.com/de/` über die URL-Prüfung indexieren lassen

Beides beschleunigt nur. `robots.txt` verweist bereits auf die Sitemap, Google
findet sie also ohnehin.

Die Meldung "Alternative Seite mit richtigem kanonischen Tag" ist an sich
**keine Fehlfunktion**, sie bedeutet, dass Google die Duplikate erkannt und
korrekt zusammengeführt hat. Die Weiterleitungen räumen die Ursache trotzdem
auf.

## Was der Seite noch fehlt

Auf `likafilm.com` verlinkt keine Seite auf diese Subdomain. Ohne eingehenden
Link bleibt sie für Google schwach angebunden. Das ist der billigste wirksame
Hebel und braucht einen WordPress-Login.
