# Stand 08.08.2026: alles live

Der Auslöser war eine Search-Console-Meldung "Alternative Seite mit richtigem
kanonischen Tag". Die ist **keine Fehlfunktion**: Google hatte Duplikat-URLs
gefunden, den Canonical-Tag gelesen und korrekt konsolidiert. Die Ursache
(fehlende Weiterleitungen) ist trotzdem beseitigt.

## Was live steht

`./deploy/verify.sh` prüft alles davon gegen den Server, Exit-Code 0.

- Weiterleitungen: `http://` auf `https://`, `www.` auf ohne, `/index.html` auf `/`
- Deutsche Fassung unter `/de/`, hreflang wechselseitig, `/de/` in der sitemap.xml
- `icon.png` von 6,8 MB auf 54 KB
- Ladungsfähige Anschrift im Impressum **und** beim Verantwortlichen der
  Datenschutzerklärung, in beiden Sprachfassungen (§ 5 DDG, Art. 13 DSGVO)
- Schriften lokal statt von Google Fonts, dazu ein eigener Abschnitt in der
  Datenschutzerklärung zu Hosting, Server-Logs und Schriften
- Sicherheits-Header und eine enge Content-Security-Policy
- 404-Fix vom 29.07.2026 unangetastet: fehlende URLs liefern 404, nicht 500

## Zwei Quellordner, ein Ziel

`~/praybuddy-site` (dieses Repo) und `~/praybuddy-website` halten denselben
Stand. Der zweite enthält zusätzlich `tools/.env-deploy` mit den
FTP-Zugangsdaten, die nicht ins Repo gehören. Wer hier etwas ändert, muss es
dorthin spiegeln, sonst überschreibt der nächste Deploy aus dem anderen Ordner
die Änderung.

## Offen

**Auf `likafilm.com` verlinkt keine einzige Seite auf diese Subdomain.**
Geprüft auf Startseite, /ich-biete, /about-me, /arbeiten, /portfolio und
/nano-prompt-studio. Das betrifft alle sechs likafilm-Subdomains, nicht nur
Pray Buddy. Ein Menüeintrag ist der billigste wirksame Hebel und braucht einen
WordPress-Login: Design, Menüs, Individueller Link,
`https://praybuddy.likafilm.com/`, Text "Pray Buddy".

Search Console: Sitemap einreichen und `/de/` per URL-Prüfung indexieren
lassen. Beschleunigt nur, `robots.txt` verweist bereits auf die Sitemap.

Technischer Hintergrund zum Hosting steht in `deploy/README.md`.
