# Deployment

## Wichtig: Dieses Repo wird nicht automatisch ausgeliefert

Die Live-Seite läuft auf klassischem Webhosting, **nicht** auf GitHub Pages:

| | |
|---|---|
| `praybuddy.likafilm.com` löst auf | `85.13.153.47` (nginx, gleicher Server wie `likafilm.com`) |
| GitHub-Pages-IPs wären | `185.199.108–111.153` |

Die Datei `CNAME` im Repo-Root stammt aus einem GitHub-Pages-Setup, das nie
aktiv wurde. Sie hat auf dem jetzigen Hosting keine Wirkung. Entweder sie
bleibt als Altlast liegen, oder das DNS wird künftig wirklich auf GitHub
Pages umgestellt — dann greift sie wieder.

**Änderungen müssen also manuell aufs Hosting hochgeladen werden** (FTP/SFTP
oder Plesk-Dateimanager). Hochzuladen sind:

```
index.html
de/index.html
robots.txt
sitemap.xml
icon.png
og-image.png
badge-app-store.svg
```

## Redirects einrichten

Ohne diesen Schritt bleiben die Duplikat-URLs bestehen, die in der Search
Console als *„Alternative Seite mit richtigem kanonischen Tag"* auftauchen.

1. **Läuft nur nginx?** → Inhalt von `nginx-praybuddy.conf` in die
   Server-Konfiguration übernehmen (Pfade zu Zertifikat und Web-Root
   anpassen), dann `nginx -t && systemctl reload nginx`.
2. **Läuft Apache hinter nginx (Plesk-Standard)?** → `htaccess-praybuddy`
   als `.htaccess` ins Web-Root legen.

Bei Plesk lassen sich die nginx-Direktiven auch über
*Websites & Domains → Apache & nginx Settings → Zusätzliche nginx-Direktiven*
eintragen, ohne Shell-Zugriff.

## Danach prüfen

```bash
curl -sI http://praybuddy.likafilm.com/       | grep -i '^HTTP\|^location'
curl -sI https://www.praybuddy.likafilm.com/  | grep -i '^HTTP\|^location'
curl -sI https://praybuddy.likafilm.com/index.html | grep -i '^HTTP\|^location'
```

Alle drei sollen `301` plus `Location: https://praybuddy.likafilm.com/`
liefern. Der Ausgangszustand war bei allen dreien `200` ohne Weiterleitung.

## Search Console

Nach dem Upload:

1. Sitemap neu einreichen: `https://praybuddy.likafilm.com/sitemap.xml`
   (enthält jetzt zusätzlich `/de/`).
2. `https://praybuddy.likafilm.com/de/` über die URL-Prüfung indexieren lassen.

Die Meldung *„Alternative Seite mit richtigem kanonischen Tag"* ist an sich
**keine Fehlfunktion** — sie bedeutet, dass Google die Duplikate erkannt und
korrekt auf die kanonische URL zusammengeführt hat. Die Redirects räumen die
Ursache trotzdem auf.
