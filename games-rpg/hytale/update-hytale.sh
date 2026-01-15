#!/bin/bash

REPO_ROOT='/var/db/repos/neptune/games-rpg/hytale-launcher-bin'

VERSION=$(curl -s https://launcher.hytale.com/version/release/launcher.json | jq -r '.version')
VERSION_SHORT=$(echo $VERSION | cut -d- -f1)

find "${REPO_ROOT}/" -iname "*.ebuild" -print -delete
EBUILD_TARGET="${REPO_ROOT}/hytale-launcher-bin-${VERSION_SHORT}.ebuild"
cp hytale-launcher-bin.ebuild "${EBUILD_TARGET}"
sed -i "/__HYTALE_VERSION__/s//${VERSION}/g" "${EBUILD_TARGET}" || exit
cd "${REPO_ROOT}"
git add .
pkgdev commit
