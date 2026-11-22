#!/usr/bin/env bash
set -euo pipefail

root=$(cd "$(dirname "$0")/.." && pwd)
cd "$root/ecp-applications"
tola build --clean

# Keep intermediate plaintext inside the ignored applications directory.
stage=$(mktemp -d ./review-build.XXXXXXXX)
trap 'rm -rf "$stage"' EXIT
python3 "$root/scripts/review/copy-assets.py" public "$stage/site"
sed -e 's|href="/assets/|href="assets/|g' \
    -e 's|src="/assets/|src="assets/|g' \
    -e 's|href="/\.tola/|href="styles/|g' \
    public/index.html > "$stage/index.html"

# Keep the passphrase out of command arguments and shell traces.
set +x
password_file="$root/.review-password"
if [[ -e "$password_file" ]]; then
    {
        IFS= read -r review_password || :
        review_password=${review_password%$'\r'}
        if [[ -z "$review_password" ]] || IFS= read -r extra_line || [[ -n "$extra_line" ]]; then
            echo ".review-password must contain one nonempty line." >&2
            exit 1
        fi
    } < "$password_file"
    export STATICRYPT_PASSWORD="$review_password"
fi

npx --yes --package=staticrypt@3.5.4 staticrypt "$stage/index.html" \
    --template "$root/scripts/review/password.html" \
    --config .staticrypt.json --directory "$stage/encrypted" \
    --remember 60 --template-remember 'Remember me for two months'

unset review_password STATICRYPT_PASSWORD

dest="$root/applications"
mkdir -p "$dest"
cp -R "$stage/site/." "$dest/"
mv "$stage/encrypted/index.html" "$dest/index.html"
