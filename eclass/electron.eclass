# Copyright 2023-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: electron-utils.eclass
# @SUPPORTED_EAPIS: 8
# @BLURB: Eclass for patching electron build processes
# @MAINTAINER:
# Ada <ada@chronovore.dev>
# @AUTHOR:
# Ada <ada@chronovore.dev>

# @ECLASS_VARIABLE: ELECTRON_SLOT
# @PRE_INHERIT
# @DEFAULT_UNSET
# @DESCRIPTION:
# The electron slot to use

# @ECLASS_VARIABLE: ELECTRON_BUILDER_VER
# @DEFAULT_UNSET
# @DESCRIPTION:
# If set, this electron-builder version will be used

# @ECLASS_VARIABLE: ELECTRON_WVCUS
# @DEFAULT_UNSET
# @DESCRIPTION:
# If set, use Electron with support for Widevine

# @ECLASS_VARIABLE: ELECTRON_BDEPEND
# @DEFAULT_UNSET
# @DESCRIPTION:
# Set by eclass, list of bdepends that are required.

# @ECLASS_VARIABLE: ELECTRON_SRC_URI
# @DEFAULT_UNSET
# @DESCRIPTION:
# Set by eclass, list of src uris for the selecetd electron version.

# @ECLASS_VARIABLE: ELECTRON_KEYWORDS
# @DESCRIPTION:
# Package Keywords that are at least valid for Electron


ELECTRON_BDEPEND="
	app-misc/jq
	app-arch/unzip
"

if [[ ${ELECTRON_WVCUS} ]]; then
	ELECTRON_RDEPEND="virtual/electron-wvcus:${ELECTRON_SLOT}="
	ELECTRON_KEYWORDS="-* ~amd64"
	ELECTRON_BIN_NAME="electron-wvcus-${ELECTRON_SLOT}"
else
	ELECTRON_RDEPEND="virtual/electron:${ELECTRON_SLOT}="
	ELECTRON_KEYWORDS="-* ~amd64 ~arm ~arm64"
	ELECTRON_BIN_NAME="electron-${ELECTRON_SLOT}"
fi

electron_dobin() {
	[[ ${EBUILD_PHASE} != install ]] &&
		die "${FUNCNAME} can only be used in src_install"
	[[ ${#} -eq 2 ]] || die "Usage: ${FUNCNAME} <path> <name>"

	local asarpath=${1}
	local name=${2}
	cat > "electron-${name}" <<-EOF
	#!/bin/sh
	
	/usr/bin/${ELECTRON_BIN_NAME} "${asarpath}" "\$@"
	EOF
	newbin "electron-${name}" "${name}"
}

electron_src_prepare() {
    default

	if [[ ${ELECTRON_WVCUS} ]]; then
		ELECTRON_VER=$(best_version virtual/electron-wvcus:${ELECTRON_SLOT})
	else
		ELECTRON_VER=$(best_version virtual/electron:${ELECTRON_SLOT})
	fi
	ELECTRON_VER=${ELECTRON_VER#*/*-} # reduce it to ${PV}-${PR}
	ELECTRON_VER=${ELECTRON_VER%%[_-]*} # main version without beta/pre/patch/revision

	echo "$(jq ".build.electronDist = \"/usr/share/electron/${ELECTRON_SLOT}\"" package.json)" > package.json
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
