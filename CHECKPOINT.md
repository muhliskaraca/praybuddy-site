# Checkpoint — Stand 08.08.2026

Übergabedokument für eine Desktop-Session. Enthält den vollständigen Kontext,
damit nichts neu untersucht werden muss.

---

## Was der Auslöser war

Google Search Console schickte am 08.08.2026 eine Mail zu
`praybuddy.likafilm.com`:

> **Alternative Seite mit richtigem kanonischen Tag**

Diese Meldung ist **keine Fehlfunktion**. Sie bedeutet: Google hat
Duplikat-URLs gefunden, den Canonical-Tag gelesen und korrekt auf die
Hauptseite konsolidiert. Genau so soll es laufen. Die Ursache wurde trotzdem
beseitigt.

## Wichtigster Befund: Dieses Repo wird nicht ausgeliefert

| | |
|---|---|
| `praybuddy.likafilm.com` löst auf | `85.13.153.47` (nginx, gleicher Server wie `likafilm.com`) |
| GitHub-Pages-IPs wären | `185.199.108–111.153` |
| `CNAME` im Repo-Root | Altlast aus einem nie aktivierten Pages-Setup, ohne Wirkung |

Das Repo enthielt bis zum 08.08.2026 eine völlig andere, alte Privacy-Seite.
Es ist jetzt mit dem Live-Stand synchronisiert — **Änderungen müssen aber von
Hand aufs Hosting hochgeladen werden.**

## Was bereits im Repo steckt (gemerged in `main`, PR #2)

- `index.html` auf Live-Stand, plus hreflang, Sprachumschalter, `width`/`height` am Hero-Icon
- `de/index.html` — vollständige deutsche Fassung inkl. Datenschutz und Impressum
- `sitemap.xml` mit beiden URLs und hreflang-Alternates
- `icon.png` von 2048 px / 6,8 MB auf 256 px / 54 KB verkleinert
- `deploy/` mit nginx- und Apache-Config, Upload- und Prüfskript
- Haftungsklausel korrigiert (behauptete fälschlich, die Seite habe keine externen Links)

## Live-Zustand — nichts davon ist online

Geprüft am 08.08.2026 mit `./deploy/verify.sh`, 7 von 7 Punkten offen:

```
http:// ohne TLS      → HTTP 200   (erwartet: 301)
www-Variante          → HTTP 200   (erwartet: 301)
/index.html           → HTTP 200   (erwartet: 301)
/de/ erreichbar       → HTTP 404   (erwartet: 200)
/de/ hreflang         → fehlt
sitemap.xml mit /de/  → fehlt
icon.png              → 6.793.364 Bytes (erwartet: unter 200.000)
```

---

## Was zu tun ist

### 1. Zugangsdaten setzen

`DEPLOY_PATH` ist das echte Web-Root auf dem Server — bei Plesk meist
`/var/www/vhosts/likafilm.com/praybuddy` oder ähnlich. Im Plesk-Dateimanager
nachsehen.

```bash
export DEPLOY_USER=DEIN_SSH_USER
export DEPLOY_HOST=praybuddy.likafilm.com
export DEPLOY_PATH=/var/www/vhosts/likafilm.com/praybuddy
```

### 2. Ist-Zustand festhalten, dann hochladen

```bash
git clone https://github.com/muhliskaraca/praybuddy-site.git
cd praybuddy-site

./deploy/verify.sh          # zeigt die 7 offenen Punkte
./deploy/upload.sh          # Trockenlauf — überträgt nichts
./deploy/upload.sh --live   # überträgt wirklich
```

Kein SSH auf dem Hosting? Dann diese Dateien per Plesk-Dateimanager oder FTP
hochladen, Struktur beibehalten:

```
index.html
de/index.html
robots.txt
sitemap.xml
icon.png
og-image.png
badge-app-store.svg
```

### 3. Weiterleitungen einrichten

Der Upload allein behebt die Duplikat-URLs **nicht**.

- **Nur nginx?** → `deploy/nginx-praybuddy.conf` in die Server-Konfiguration
  übernehmen (Zertifikatspfade und Web-Root anpassen), dann
  `nginx -t && systemctl reload nginx`
- **Apache hinter nginx (Plesk-Standard)?** → `deploy/htaccess-praybuddy` als
  `.htaccess` ins Web-Root legen
- **Kein Shell-Zugriff?** → Plesk: *Websites & Domains → Apache & nginx
  Settings → Zusätzliche nginx-Direktiven*

### 4. Kontrolle

```bash
./deploy/verify.sh   # muss jetzt komplett grün sein, Exit-Code 0
```

### 5. Search Console

1. Sitemap neu einreichen: `https://praybuddy.likafilm.com/sitemap.xml`
2. `https://praybuddy.likafilm.com/de/` über die URL-Prüfung indexieren lassen

---

## Zwei Punkte, die eine Entscheidung brauchen

### Impressum unvollständig

`§ 5 DDG` verlangt eine ladungsfähige Anschrift. Aktuell stehen im Impressum
nur Name und E-Mail. Die Stelle ist in `de/index.html` als HTML-Kommentar
markiert:

```html
<!-- HINWEIS: Für ein deutsches Impressum ist nach § 5 DDG eine ladungsfähige
     Anschrift erforderlich. Bitte hier die vollständige Postanschrift ergänzen. -->
```

Die Adresse wurde bewusst nicht erfunden. Sie muss auch in `index.html`
(Abschnitt „Legal Notice") ergänzt werden.

### Kein Backlink

`likafilm.com` verlinkt nicht auf `praybuddy.likafilm.com`. Die Subdomain hängt
ohne eingehende Links im Netz — das ist der billigste wirksame Hebel für die
Sichtbarkeit, liegt aber in einem anderen Projekt.

---

## Prompt zum Einfügen in die Desktop-Session

```
Lies CHECKPOINT.md in diesem Repo. Es beschreibt eine Website, die auf
klassischem Webhosting läuft und manuell deployt werden muss. Der Code ist
fertig und in main gemerged, aber nichts davon ist live.

Führe ./deploy/verify.sh aus, um den Ist-Zustand zu sehen. Hilf mir dann
beim Deployment nach den Schritten in CHECKPOINT.md. Ich habe SSH-Zugang
zum Server; frag mich nach den Zugangsdaten, wenn du sie brauchst.
```
