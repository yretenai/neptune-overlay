#!/bin/zsh

NETIM_ROOT="/var/db/repos/neptune/net-im"

function update-discord
{
	NAME=$1
	TARGET=$2
	EBUILD_TEMPLATE=$3

	EBUILD_PRE="${NETIM_ROOT}/${NAME}/${NAME}-"
	VERSION=$(./discord-version.sh $TARGET)
	echo $NAME version is $VERSION
	EBUILD_NAME="${EBUILD_PRE}0.0.${VERSION}.ebuild"
	find "${NETIM_ROOT}/${NAME}" -iname "*.ebuild" -print -delete
	cp $EBUILD_TEMPLATE $EBUILD_NAME 
	pushd "${NETIM_ROOT}/${NAME}"
	ebuild "$EBUILD_NAME" manifest
	popd
}

update-discord "discord" "" "discord.ebuild"
update-discord "discord-canary" "canary" "discord-canary.ebuild"
update-discord "discord-ptb" "ptb" "discord-ptb.ebuild"
update-discord "discord-development" "development" "discord-canary.ebuild"
