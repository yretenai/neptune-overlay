#!/bin/sh

NETIM_ROOT="/var/db/repos/neptune/net-im"

update_discord() {
	NAME=$1
	TARGET=$2
	EBUILD_TEMPLATE=$3

	EBUILD_PRE="${NETIM_ROOT}/${NAME}/${NAME}-"
	VERSION=$(./discord-version.sh $TARGET)
	echo $NAME version is $VERSION
	EBUILD_NAME="${EBUILD_PRE}${VERSION}.ebuild"
	find "${NETIM_ROOT}/${NAME}" -iname "*.ebuild" -print -delete
	cp "$EBUILD_TEMPLATE" "$EBUILD_NAME"
	case "${TARGET}" in
		canary)
			MODULES="$(./discord-modules.sh $TARGET)"
			awk -v r="${MODULES}" '{gsub(/__DISCORD_MODULES__/, r)}1' "$EBUILD_NAME" > "$EBUILD_NAME.tmp"
			mv "$EBUILD_NAME.tmp" "$EBUILD_NAME"
			;;
		*) ;;
	esac
	OLD_PWD="$PWD"
	cd "${NETIM_ROOT}/${NAME}"
	ebuild "$EBUILD_NAME" manifest
	if [ ! -z "$NEPTUNE_REPO_PKGDEV" ]; then
		git add .
		if [ -n "$(git status --porcelain .)" ]; then
			pkgdev commit
		fi
	fi
	cd "$OLD_PWD"
}

update_discord "discord" "" "discord.ebuild"
update_discord "discord-canary" "canary" "discord-canary.ebuild"
update_discord "discord-ptb" "ptb" "discord-ptb.ebuild"
update_discord "discord-development" "development" "discord-development.ebuild"
