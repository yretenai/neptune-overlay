# Copyright 2023-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: electron-builder-utils.eclass
# @SUPPORTED_EAPIS: 8
# @BLURB: Eclass for patching electron-builder

# @ECLASS_VARIABLE: ELECTRON_VER
# @PRE_INHERIT
# @REQUIRED
# @DESCRIPTION:
# Version of electron to use

# @ECLASS_VARIABLE: ELECTRON_BUILDER_VER
# @DEFAULT_UNSET
# @DESCRIPTION:
# If set, this electron-builder version will be used

# @ECLASS_VARIABLE: ELECTRON_WVCUS
# @PRE_INHERIT
# @DEFAULT_UNSET
# @DESCRIPTION:
# If set, use Electron with support for Widevine 

ELECTRON_BDEPEND="
	app-misc/jq
"

if [[ ${ELECTRON_WVCUS} ]]; then
	ELECTRON_VER="${ELECTRON_VER}+wvcus"
	ELECTRON_SRC_URI="
		amd64? ( https://github.com/castlabs/electron-releases/releases/download/v${ELECTRON_VER}/electron-v${ELECTRON_VER}-linux-x64.zip )
	"
else
	ELECTRON_SRC_URI="
		amd64? ( https://github.com/electron/electron/releases/download/v${ELECTRON_VER}/electron-v${ELECTRON_VER}-linux-x64.zip )
		arm64? ( https://github.com/electron/electron/releases/download/v${ELECTRON_VER}/electron-v${ELECTRON_VER}-linux-arm64.zip )
		arm? ( https://github.com/electron/electron/releases/download/v${ELECTRON_VER}/electron-v${ELECTRON_VER}-linux-armv7l.zip )
	"
fi

SRC_URI="${ELECTRON_SRC_URI}"

electron-builder-utils_src_prepare() {
    default

	echo "$(jq --arg cache "${DISTDIR}" '.build.electronDownload.cache = $cache' package.json)" > package.json
	echo "$(jq 'del(.dependencies.electron)' package.json)" > package.json
	ELECTRON_NPM_VER="${ELECTRON_VER}"
	if [[ ${ELECTRON_WVCUS} ]]; then
		ELECTRON_NPM_VER="git+https://github.com/castlabs/electron-releases#v${ELECTRON_VER}"
	fi
	echo "$(jq --arg version "${ELECTRON_NPM_VER}" '.devDependencies.electron = $version' package.json)" > package.json

    if [[ ${ELECTRON_BUILDER_VER} ]]; then
	    echo "$(jq 'del(.dependencies["electron-builder"])' package.json)" > package.json
        echo "$(jq --arg version "${ELECTRON_BUILDER_VER}" '.devDependencies["electron-builder"] = $version' package.json)" > package.json
    fi
}

EXPORT_FUNCTIONS src_prepare
