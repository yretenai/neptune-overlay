#!/bin/bash

ADADOTNET_ROOT='/var/db/repos/neptune/neptune-dotnet'

# usage: dotnet_strip "name"
dotnet_strip() {
	printf "%s" "$1" | sed 's/-rc//g; s/-preview//g'
}

# usage: dotnet_apply "name" "version"
dotnet_apply() {
	EBUILD_NAME="$1"
	VERSION="$2"
	IS_PREVIEW="$3"
	VERSION_SAFE="$(dotnet_strip "${VERSION}")"

	cp "${EBUILD_NAME}.ebuild" "${ADADOTNET_ROOT}/${EBUILD_NAME}/${EBUILD_NAME}-${VERSION_SAFE}.ebuild"
	if ! [ "${VERSION_SAFE}" = "${VERSION}" ]; then
		sed -i "/\${PV}/s//${VERSION}/g" "${ADADOTNET_ROOT}/${EBUILD_NAME}/${EBUILD_NAME}-${VERSION_SAFE}.ebuild" || exit
	fi

	if [[ "${IS_PREVIEW}" == 1 ]]; then
		sed -i '/KEYWORDS=/d' "${ADADOTNET_ROOT}/${EBUILD_NAME}/${EBUILD_NAME}-${VERSION_SAFE}.ebuild"
	fi
}

TARGETS="dotnet-aspnetcore-runtime dotnet-runtime dotnet-aspnetcore-nugets dotnet-runtime-nugets dotnet-sdk dotnet-cli-bin dotnet-man"
for TARGET in $TARGETS; do
	find "${ADADOTNET_ROOT}/${TARGET}" \( -iname "*8.0*.ebuild" -or -iname "*9.0*.ebuild" -or -iname "*10.0*.ebuild"-or -iname "*11.0*.ebuild" \) -delete
done
# find "${ADADOTNET_ROOT}/netstandard" -iname "*.ebuild" -delete

# LATEST_NETSTANDARD_VERSION="2.1.0"
IS_FIRST=Y

for RELEASE in $(curl -s https://dotnetcli.blob.core.windows.net/dotnet/release-metadata/releases-index.json | jq -r '.["releases-index"][] | [.["channel-version", "latest-sdk", "latest-runtime", "support-phase", "releases.json"]] | join("^")'); do
	IFS="^"
	set -- $RELEASE
	RELEASE_CHANNEL=$1
	RELEASE_HEAD_SDK=$2
	RELEASE_RUNTIME=$3
	RELEASE_ASP=$3
	RELEASE_TYPE=$4
	RELEASE_INDEX=$5
	IFS=" "
	RELEASE_INDEX_DATA=$(curl -s "${RELEASE_INDEX}")
	RELEASE_ASP="$(echo ${RELEASE_INDEX_DATA} | jq --raw-output '.releases[0]["aspnetcore-runtime"].version')"
	RELEASE_SDK_SAFE="$(dotnet_strip "${RELEASE_HEAD_SDK}")"

	if ([ "${RELEASE_TYPE}" = "go-live" ] || [ "${RELEASE_TYPE}" = "preview" ]); then
		IS_PREVIEW=1
	else
		IS_PREVIEW=0
	fi

	dotnet_apply dotnet-sdk "${RELEASE_HEAD_SDK}" "${IS_PREVIEW}"
	sed -i "/__DOTNET_ASP_VERSION__/s//$(dotnet_strip "${RELEASE_ASP}")/g" "${ADADOTNET_ROOT}/dotnet-sdk/dotnet-sdk-${RELEASE_SDK_SAFE}.ebuild" || exit
	sed -i "/__DOTNET_VERSION__/s//$(dotnet_strip "${RELEASE_RUNTIME}")/g" "${ADADOTNET_ROOT}/dotnet-sdk/dotnet-sdk-${RELEASE_SDK_SAFE}.ebuild" || exit

	dotnet_apply dotnet-aspnetcore-runtime "${RELEASE_ASP}" "${IS_PREVIEW}"
	dotnet_apply dotnet-runtime "${RELEASE_RUNTIME}" "${IS_PREVIEW}"

	if ([ "${RELEASE_TYPE}" = "active" ] || [ "${RELEASE_TYPE}" = "eol" ] || [ "${RELEASE_TYPE}" = "maintenance" ]); then
		# only add head cli
		if [ "${IS_FIRST}" = "Y" ]; then
			dotnet_apply dotnet-cli-bin "${RELEASE_RUNTIME}" "${IS_PREVIEW}"
			dotnet_apply dotnet-man "$(printf "%s" "${RELEASE_HEAD_SDK}" | sed 's/..$/00/')" "${IS_PREVIEW}"
			# dotnet_apply netstandard "${LATEST_NETSTANDARD_VERSION}.${RELEASE_HEAD_SDK}"

			# sed -i "/__DOTNET_VERSION__/s//${RELEASE_HEAD_SDK}/g" "${ADADOTNET_ROOT}/netstandard/netstandard-${LATEST_NETSTANDARD_VERSION}.${RELEASE_HEAD_SDK}.ebuild" || exit

			LATEST_VERSION="${RELEASE_RUNTIME}"
			LATEST_SDK_VERSION="${RELEASE_HEAD_SDK}"
			IS_FIRST=N
		fi
	else
		# also add preview cli
		dotnet_apply dotnet-cli-bin "${RELEASE_RUNTIME}" "${IS_PREVIEW}"
	fi

	echo channel=$RELEASE_CHANNEL type=$RELEASE_TYPE preview=$IS_PREVIEW sdk=$RELEASE_HEAD_SDK runtime=$RELEASE_RUNTIME asp=$RELEASE_ASP index=$RELEASE_INDEX

	RELEASE_NUGET_VERSIONS=""
	RELEASE_ASPNET_VERSIONS=""
	REVISION=$(echo ${RELEASE_INDEX_DATA} | jq --raw-output '[.releases[]["runtime"].version] | length + 1')

	for RELEASE_NUGET in $(echo ${RELEASE_INDEX_DATA} | jq --raw-output '[.releases[]["runtime"].version] | join(" ")'); do
		if ([[ "${IS_PREVIEW}" == 0 ]] && ( [[ "${RELEASE_NUGET}" == *preview* ]] || [[ "${RELEASE_NUGET}" == *rc* ]])); then
			continue
		fi

		RELEASE_NUGET_VERSIONS+="${RELEASE_NUGET} "
	done
	dotnet_apply dotnet-runtime-nugets "${RELEASE_CHANNEL}.${REVISION}" "${IS_PREVIEW}"
	sed -i "/__DOTNET_VERSION__/s//${RELEASE_NUGET_VERSIONS}/g" "${ADADOTNET_ROOT}/dotnet-runtime-nugets/dotnet-runtime-nugets-$(dotnet_strip "${RELEASE_CHANNEL}.${REVISION}").ebuild" || exit

	for RELEASE_NUGET in $(echo ${RELEASE_INDEX_DATA} | jq --raw-output '[.releases[]["aspnetcore-runtime"].version] | join(" ")'); do
		if ([[ "${IS_PREVIEW}" == 0 ]] && ( [[ "${RELEASE_NUGET}" == *preview* ]] || [[ "${RELEASE_NUGET}" == *rc* ]])); then
			continue
		fi

		RELEASE_ASPNET_VERSIONS+="${RELEASE_NUGET} "
	done
	dotnet_apply dotnet-aspnetcore-nugets "${RELEASE_CHANNEL}.${REVISION}" "${IS_PREVIEW}"
	sed -i "/__DOTNET_VERSION__/s//${RELEASE_ASPNET_VERSIONS}/g" "${ADADOTNET_ROOT}/dotnet-aspnetcore-nugets/dotnet-aspnetcore-nugets-$(dotnet_strip "${RELEASE_CHANNEL}.${REVISION}").ebuild" || exit

	if [ "${RELEASE_CHANNEL}" = "8.0" ]; then
		break
	fi
done

for TARGET in $TARGETS; do
	TARGET_EBUILD="$(find "${ADADOTNET_ROOT}/${TARGET}" -type f -iname "*.ebuild" -print -quit)"
	ebuild "$TARGET_EBUILD" manifest
done

pkgdev_do() {
	git add $1
}

if [ ! -z "$NEPTUNE_REPO_PKGDEV" ]; then
	OLD_PWD="${PWD}"
	cd "${ADADOTNET_ROOT}"
	for TARGET in $TARGETS; do
		pkgdev_do $TARGET
	done
	# pkgdev_do netstandard

	if [ -n "$(git status --porcelain .)" ]; then
		pkgdev commit -m "neptune-dotnet: bump dotnet"
	fi

	cd "${OLD_PWD}"
fi
