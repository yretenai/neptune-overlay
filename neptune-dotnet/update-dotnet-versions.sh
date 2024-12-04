#!/bin/sh

ADADOTNET_ROOT='/var/db/repos/neptune/neptune-dotnet'

# usage: dotnet_strip "name"
dotnet_strip() {
	printf "%s" "$1" | sed 's/-rc//g; s/-preview//g'
}

# usage: dotnet_apply "name" "version"
dotnet_apply() {
	EBUILD_NAME="$1"
	VERSION="$2"
	VERSION_SAFE="$(dotnet_strip "${VERSION}")"

	cp "${EBUILD_NAME}.ebuild" "${ADADOTNET_ROOT}/${EBUILD_NAME}/${EBUILD_NAME}-${VERSION_SAFE}.ebuild"
	if ! [ "${VERSION_SAFE}" = "${VERSION}" ]; then
		sed -i "/\${PV}/s//${VERSION}/g" "${ADADOTNET_ROOT}/${EBUILD_NAME}/${EBUILD_NAME}-${VERSION_SAFE}.ebuild"
	fi
}

TARGETS="dotnet-aspnetcore-runtime dotnet-runtime dotnet-sdk dotnet-cli-bin dotnet-man netstandard"
for TARGET in $TARGETS; do
	find "${ADADOTNET_ROOT}/${TARGET}" -iname "*.ebuild" -delete
done

LATEST_NETSTANDARD_VERSION="2.1.0"
IS_FIRST=Y

dotnet_apply netstandard "${LATEST_NETSTANDARD_VERSION}"

for RELEASE in $(curl -s https://dotnetcli.blob.core.windows.net/dotnet/release-metadata/releases-index.json | jq -r '.["releases-index"][] | [.["channel-version", "latest-sdk", "latest-runtime", "support-phase", "releases.json"]] | join("^")'); do
	IFS="^"
	set -- $RELEASE
	RELEASE_CHANNEL=$1
	RELEASE_SDK=$2
	RELEASE_RUNTIME=$3
	RELEASE_TYPE=$4
	RELEASE_INDEX=$5
	unset IFS

	echo $RELEASE_CHANNEL $RELEASE_TYPE $RELEASE_SDK $RELEASE_RUNTIME $RELEASE_ASP $RELEASE_INDEX

	if ! ([ "${RELEASE_TYPE}" = "active" ] || [ "${RELEASE_TYPE}" = "eol" ] || [ "${RELEASE_TYPE}" = "maintenance" ]); then
		RELEASE_ASP="$(curl -s "${RELEASE_INDEX}" | jq --raw-output '.releases[0]["aspnetcore-runtime"].version')"

		dotnet_apply dotnet-aspnetcore-runtime "${RELEASE_ASP}"
		dotnet_apply dotnet-runtime "${RELEASE_RUNTIME}"
		dotnet_apply dotnet-sdk "${RELEASE_SDK}"
		dotnet_apply dotnet-cli-bin "${RELEASE_RUNTIME}"
	else
		dotnet_apply dotnet-aspnetcore-runtime "${RELEASE_RUNTIME}"
		dotnet_apply dotnet-runtime "${RELEASE_RUNTIME}"
		dotnet_apply dotnet-sdk "${RELEASE_SDK}"

		if [ "${IS_FIRST}" = "Y" ]; then
			dotnet_apply dotnet-cli-bin "${RELEASE_RUNTIME}"
			dotnet_apply dotnet-man "$(printf "%s" "${RELEASE_SDK}" | sed 's/..$/00/')"

			sed -i "/__DOTNET_VERSION__/s//${RELEASE_SDK}/g" "${ADADOTNET_ROOT}/netstandard/netstandard-${LATEST_NETSTANDARD_VERSION}.ebuild"

			LATEST_VERSION="${RELEASE_RUNTIME}"
			LATEST_SDK_VERSION="${RELEASE_SDK}"
			IS_FIRST=N
		fi
	fi

	if [ "${RELEASE_CHANNEL}" = "5.0" ]; then
		break
	fi
done

for TARGET in $TARGETS; do
	TARGET_EBUILD="$(find "${ADADOTNET_ROOT}/${TARGET}" -type f -iname "*.ebuild" -print -quit)"
	ebuild "$TARGET_EBUILD" manifest
done

pkgdev_do() {
	git add $1
	if [ -n "$(git status --porcelain .)" ]; then
		pkgdev commit
	fi
}

if [ ! -z "$NEPTUNE_REPO_PKGDEV" ]; then
	OLD_PWD="${PWD}"
	cd "${ADADOTNET_ROOT}"
	for TARGET in $TARGETS; do
		pkgdev_do $TARGET
	done
	cd "${OLD_PWD}"
fi
