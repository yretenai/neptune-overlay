#!/usr/bin/env sh

ADADOTNET_ROOT='/var/db/repos/neptune/neptune-dotnet'

dotnet_strip() {
	value=${"$1"/-rc/}
	value=${"${value}"/-preview/}
	echo $value
} 

find "${ADADOTNET_ROOT}/dotnet-aspnetcore-runtime" -iname "*.ebuild" -delete
find "${ADADOTNET_ROOT}/dotnet-runtime" -iname "*.ebuild" -delete
find "${ADADOTNET_ROOT}/dotnet-sdk" -iname "*.ebuild" -delete
find "${ADADOTNET_ROOT}/dotnet-cli-bin" -iname "*.ebuild" -delete
find "${ADADOTNET_ROOT}/dotnet-man" -iname "*.ebuild" -delete
find "${ADADOTNET_ROOT}/netstandard" -iname "*.ebuild" -delete

DOTNET_RELEASE_INDEX="$(curl -s https://dotnetcli.blob.core.windows.net/dotnet/release-metadata/releases-index.json)"
RELEASE_COUNT="$(jq ".[\"releases-index\"] | length - 1" <<< "${DOTNET_RELEASE_INDEX}")"
LATEST_VERSION="0.0.0"
LATEST_SDK_VERSION="0.0.0"
LATEST_NETSTANDARD_VERSION="2.1.0"
IS_FIRST=Y

for i in $(seq 0 ${RELEASE_COUNT}); do
	RELEASE_OBJ="$(jq --raw-output ".[\"releases-index\"][${i}]" <<< "${DOTNET_RELEASE_INDEX}")"
	RELEASE_CHANNEL="$(jq --raw-output '.["channel-version"]' <<< "${RELEASE_OBJ}")"
	RELEASE_SDK="$(jq --raw-output '.["latest-sdk"]' <<< "${RELEASE_OBJ}")"
	RELEASE_RUNTIME="$(jq --raw-output '.["latest-runtime"]' <<< "${RELEASE_OBJ}")"
	RELEASE_TYPE="$(jq --raw-output '.["support-phase"]' <<< "${RELEASE_OBJ}")"

	echo $RELEASE_CHANNEL ${RELEASE_TYPE} $RELEASE_SDK $RELEASE_RUNTIME $RELEASE_ASP

	if ! ([ "${RELEASE_TYPE}" = "active" ] || [ "${RELEASE_TYPE}" = "eol" ] || [ "${RELEASE_TYPE}" = "maintenance" ]); then
		RELEASE_ROOT="$(curl -s $(jq --raw-output ".[\"releases-index\"][${i}][\"releases.json\"]" <<< "${DOTNET_RELEASE_INDEX}"))"
		RELEASE_ASP="$(jq --raw-output '.releases[0]["aspnetcore-runtime"].version' <<< "${RELEASE_ROOT}")"
		RELEASE_SDK_SAFE=$(dotnet_strip "$RELEASE_SDK")
		RELEASE_RUNTIME_SAFE=$(dotnet_strip "$RELEASE_RUNTIME")
		RELEASE_ASP_SAFE=$(dotnet_strip "$RELEASE_ASP")

		cp dotnet-aspnetcore-runtime.ebuild "${ADADOTNET_ROOT}/dotnet-aspnetcore-runtime/dotnet-aspnetcore-runtime-${RELEASE_ASP_SAFE}.ebuild"
		cp dotnet-runtime.ebuild "${ADADOTNET_ROOT}/dotnet-runtime/dotnet-runtime-${RELEASE_RUNTIME_SAFE}.ebuild"
		cp dotnet-sdk.ebuild "${ADADOTNET_ROOT}/dotnet-sdk/dotnet-sdk-${RELEASE_SDK_SAFE}.ebuild"
		cp dotnet-cli-bin.ebuild "${ADADOTNET_ROOT}/dotnet-cli-bin/dotnet-cli-bin-${RELEASE_RUNTIME_SAFE}.ebuild"

		sed -i "/\${PV}/s//${RELEASE_ASP}/g" "${ADADOTNET_ROOT}/dotnet-aspnetcore-runtime/dotnet-aspnetcore-runtime-${RELEASE_ASP_SAFE}.ebuild"
		sed -i "/\${PV}/s//${RELEASE_RUNTIME}/g" "${ADADOTNET_ROOT}/dotnet-runtime/dotnet-runtime-${RELEASE_RUNTIME_SAFE}.ebuild"
		sed -i "/\${PV}/s//${RELEASE_SDK}/g" "${ADADOTNET_ROOT}/dotnet-sdk/dotnet-sdk-${RELEASE_SDK_SAFE}.ebuild"
		sed -i "/\${PV}/s//${RELEASE_RUNTIME}/g" "${ADADOTNET_ROOT}/dotnet-cli-bin/dotnet-cli-bin-${RELEASE_RUNTIME_SAFE}.ebuild"
	else
		cp dotnet-aspnetcore-runtime.ebuild "${ADADOTNET_ROOT}/dotnet-aspnetcore-runtime/dotnet-aspnetcore-runtime-${RELEASE_RUNTIME}.ebuild"
		cp dotnet-runtime.ebuild "${ADADOTNET_ROOT}/dotnet-runtime/dotnet-runtime-${RELEASE_RUNTIME}.ebuild"
		cp dotnet-sdk.ebuild "${ADADOTNET_ROOT}/dotnet-sdk/dotnet-sdk-${RELEASE_SDK}.ebuild"

		if [ "$IS_FIRST" = "Y" ]; then
			cp dotnet-cli-bin.ebuild "${ADADOTNET_ROOT}/dotnet-cli-bin/dotnet-cli-bin-${RELEASE_RUNTIME}.ebuild"
			cp dotnet-man.ebuild ${ADADOTNET_ROOT}/dotnet-man/dotnet-man-${RELEASE_SDK}.ebuild
			cp netstandard.ebuild ${ADADOTNET_ROOT}/netstandard/netstandard-${LATEST_NETSTANDARD_VERSION}.ebuild

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

ebuild "${ADADOTNET_ROOT}/dotnet-aspnetcore-runtime/dotnet-aspnetcore-runtime-${LATEST_VERSION}.ebuild" manifest
ebuild "${ADADOTNET_ROOT}/dotnet-runtime/dotnet-runtime-${LATEST_VERSION}.ebuild" manifest
ebuild "${ADADOTNET_ROOT}/dotnet-sdk/dotnet-sdk-${LATEST_SDK_VERSION}.ebuild" manifest
ebuild "${ADADOTNET_ROOT}/dotnet-cli-bin/dotnet-cli-bin-${LATEST_VERSION}.ebuild" manifest
ebuild "${ADADOTNET_ROOT}/dotnet-man/dotnet-man-${LATEST_SDK_VERSION}.ebuild" manifest
ebuild "${ADADOTNET_ROOT}/netstandard/netstandard-${LATEST_NETSTANDARD_VERSION}.ebuild" manifest

pkgdev_do() {
    git add $1
    if [ -n "$(git status --porcelain .)" ]; then
        pkgdev commit
    fi
}

if [ ! -z "$NEPTUNE_REPO_PKGDEV" ]; then
    pushd "${ADADOTNET_ROOT}"
    pkgdev_do dotnet-aspnetcore-runtime
    pkgdev_do dotnet-runtime
    pkgdev_do dotnet-sdk
    pkgdev_do dotnet-cli-bin
    pkgdev_do dotnet-man
    pkgdev_do netstandard
	popd
fi
