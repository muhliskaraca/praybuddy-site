#!/usr/bin/env bash
# Lädt die Seite per rsync über SSH aufs Hosting.
#
# Standardmäßig ein Trockenlauf — es wird nur angezeigt, was passieren würde.
# Erst mit --live wird tatsächlich übertragen.
#
#   export DEPLOY_USER=dein_ssh_user
#   export DEPLOY_HOST=praybuddy.likafilm.com     # oder 85.13.153.47
#   export DEPLOY_PATH=/var/www/vhosts/likafilm.com/praybuddy   # echtes Web-Root eintragen
#
#   ./deploy/upload.sh          # Trockenlauf
#   ./deploy/upload.sh --live   # überträgt wirklich
#
# Kein SSH auf dem Hosting? Dann dieselben Dateien per Plesk-Dateimanager
# oder FTP hochladen — die Liste steht unten in FILES.

set -euo pipefail
cd "$(dirname "$0")/.."

FILES=(
    index.html
    de/index.html
    robots.txt
    sitemap.xml
    icon.png
    og-image.png
    badge-app-store.svg
)

: "${DEPLOY_USER:?Bitte DEPLOY_USER setzen}"
: "${DEPLOY_HOST:?Bitte DEPLOY_HOST setzen}"
: "${DEPLOY_PATH:?Bitte DEPLOY_PATH setzen (Web-Root auf dem Server)}"

DRY="--dry-run"
MODE="TROCKENLAUF — es wird nichts übertragen"
if [[ "${1:-}" == "--live" ]]; then
    DRY=""
    MODE="ECHTE ÜBERTRAGUNG"
fi

echo "$MODE"
echo "Ziel: $DEPLOY_USER@$DEPLOY_HOST:$DEPLOY_PATH"
echo "Dateien: ${FILES[*]}"
echo

# --relative erhält die Unterverzeichnisstruktur (de/index.html)
rsync -avz $DRY --relative --checksum \
    "${FILES[@]}" \
    "$DEPLOY_USER@$DEPLOY_HOST:$DEPLOY_PATH/"

echo
if [[ -n "$DRY" ]]; then
    echo "Das war ein Trockenlauf. Für die echte Übertragung: ./deploy/upload.sh --live"
else
    echo "Übertragen. Jetzt prüfen: ./deploy/verify.sh"
    echo "Achtung: Die Weiterleitungen sind damit noch NICHT eingerichtet —"
    echo "dafür nginx-praybuddy.conf bzw. htaccess-praybuddy einspielen."
fi
