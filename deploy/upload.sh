#!/usr/bin/env bash
# Lädt die Seite per lftp aufs Hosting (ALL-INKL.COM).
#
# WARUM NICHT rsync/SSH: Der Tarif hat keinen SSH-Zugang. Der Weg, der
# tatsächlich funktioniert, ist FTP über den subdomain-eigenen, chrooted
# FTP-Nutzer (f0184137 für praybuddy). Zugangsdaten liegen ausserhalb des
# Repos in ~/praybuddy-website/tools/.env-deploy und gehören da auch hin.
#
#   ./deploy/upload.sh          # Trockenlauf, listet nur die Dateien
#   ./deploy/upload.sh --live   # überträgt wirklich
#
# Bewusst "put" statt "mirror --delete": die Übertragung ist rein additiv
# bzw. ersetzend. Ein Mirror aus diesem Ordner würde serverseitige Dateien
# löschen, die es hier nicht gibt (siehe reference_allinkl_ftp_chroot_pitfall).

set -euo pipefail
cd "$(dirname "$0")/.."

ENV_FILE="${ENV_FILE:-$HOME/praybuddy-website/tools/.env-deploy}"

FILES=(
    index.html
    de/index.html
    robots.txt
    sitemap.xml
    icon.png
    og-image.png
    badge-app-store.svg
    404.html
    404.php
    google3f2d86b09d73d64e.html
    .htaccess
)

# Schriften liegen seit dem 08.08.2026 lokal, damit die Seite keine Besucher-IP
# mehr an Google Fonts schickt. Glob statt fester Liste, damit ein Font-Update
# nicht stillschweigend am Deploy vorbeilaeuft.
shopt -s nullglob
FILES+=(fonts/LICENSE.txt fonts/*.woff2)
shopt -u nullglob

if [[ "${1:-}" != "--live" ]]; then
    echo "TROCKENLAUF, es wird nichts übertragen."
    echo "Dateien: ${FILES[*]}"
    echo "Für die echte Übertragung: ./deploy/upload.sh --live"
    exit 0
fi

[[ -f "$ENV_FILE" ]] || { echo "Fehlt: $ENV_FILE"; exit 1; }
command -v lftp >/dev/null || { echo "lftp fehlt. brew install lftp"; exit 1; }
# shellcheck source=/dev/null
source "$ENV_FILE"

for f in "${FILES[@]}"; do
    [[ -f "$f" ]] || { echo "Fehlt lokal: $f"; exit 1; }
done

echo "ECHTE ÜBERTRAGUNG nach ftp://$FTP_USER@$FTP_HOST/"

{
    echo "set ssl:verify-certificate no"
    echo "set ftp:ssl-allow yes"
    echo "set ftp:ssl-protect-data yes"
    echo "set net:max-retries 3"
    echo "cd /"
    echo "mkdir -p de"
    echo "mkdir -p fonts"
    for f in "${FILES[@]}"; do
        echo "put $f -o $f"
    done
    echo "quit"
} | lftp -u "$FTP_USER","$FTP_PASS" "$FTP_HOST" 2>&1 |
    sed -E 's#(ftp://[^:/]+):[^@]*@#\1:***@#g'

echo
echo "Übertragen. Jetzt prüfen: ./deploy/verify.sh"
