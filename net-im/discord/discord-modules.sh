#!/bin/sh

MANIFEST="$(curl "https://updates.discord.com/distributions/app/manifests/latest?channel=$1&platform=linux&arch=x64" 2>/dev/null)"
echo "DISCORD_MODULE_URI=\""
echo "$(echo "${MANIFEST}" | jq -r '.modules | to_entries[] | "\t\(.value.full.url) -> ${P}-\(.key)-\(.value.full.module_version).tar.br"' | sort)"
echo "\""
echo

echo "DISCORD_MODULE=\""
echo "$(echo "${MANIFEST}" | jq -r '.modules | to_entries[] | "\t\(.key)-\(.value.full.module_version)"' | sort)"
echo "\""
