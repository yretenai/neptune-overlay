# Copyright 2023-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: electron.eclass
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
# @PRE_INHERIT
# @DEFAULT_UNSET
# @DESCRIPTION:
# If set, this electron-builder version will be used

# @ECLASS_VARIABLE: ELECTRON_WVCUS
# @DEFAULT_UNSET
# @PRE_INHERIT
# @DESCRIPTION:
# If set, use Electron with support for Widevine

# @ECLASS_VARIABLE: ELECTRON_RDEPEND
# @DEFAULT_UNSET
# @DESCRIPTION:
# Set by eclass, list of rdepends that are required.

# @ECLASS_VARIABLE: ELECTRON_BDEPEND
# @DEFAULT_UNSET
# @DESCRIPTION:
# Set by eclass, list of bdepends that are required.

# @ECLASS_VARIABLE: ELECTRON_NAME
# @DEFAULT_UNSET
# @DESCRIPTION:
# Set by eclass, the binary name of the selected electron version.

# @ECLASS_VARIABLE: ELECTRON_KEYWORDS
# @DESCRIPTION:
# Package Keywords that are at least valid for Electron

ELECTRON_BDEPEND="
	app-misc/jq
	app-arch/unzip
"

if [[ ${ELECTRON_WVCUS} ]]; then
	ELECTRON_RDEPEND="dev-electron/electron-wvcus-bin:${ELECTRON_SLOT}="
	ELECTRON_KEYWORDS="~amd64"
	ELECTRON_NAME="electron-wvcus"
else
	ELECTRON_RDEPEND="dev-electron/electron-bin:${ELECTRON_SLOT}="
	ELECTRON_KEYWORDS="~amd64 ~arm ~arm64"
	ELECTRON_NAME="electron"
fi

# @FUNCTION: electron_binname
# @USAGE: electron_binname
# @DESCRIPTION:
# Gets the electron binary name and electron version
electron_binname() {
	ELECTRON_VER=$(best_version ${ELECTRON_RDEPEND})
	ELECTRON_VER=${ELECTRON_VER#*/*-} # reduce it to ${PV}-${PR}
	ELECTRON_VER=${ELECTRON_VER#wvcus-} # Remove the wvcus- suffix if it exists
	ELECTRON_VER=${ELECTRON_VER#bin-} # Remove the bin- suffix if it exists
	export ELECTRON_VER=${ELECTRON_VER%%[_-]*} # main version without beta/pre/patch/revision
	export ELECTRON_BIN_NAME="${ELECTRON_NAME}-${ELECTRON_VER}"
}

# @FUNCTION: electron_dobin
# @USAGE: electron_dobin asarpath name
# @DESCRIPTION:
# Builds a bin wrapper for an electron app
electron_dobin() {
	[[ ${EBUILD_PHASE} != install ]] &&
		die "${FUNCNAME} can only be used in src_install"
	[[ ${#} -eq 2 ]] || die "Usage: ${FUNCNAME} <path> <name>"

	electron_binname

	local asarpath=${1}
	local name=${2}
	cat > "electron-${name}" <<-EOF
#!/bin/sh

/usr/bin/${ELECTRON_BIN_NAME} "${asarpath}" "\$@"
EOF
	newbin "electron-${name}" "${name}"
}

# @FUNCTION: electron_patch_electron_builder
# @USAGE: electron_patch_electron_builder
# @DESCRIPTION:
# Patches electron-builder to not attempt to copy or rename electron files
electron_patch_electron_builder() {
	sed -i -e 's|await unpack|return; await unpack|' node_modules/app-builder-lib/out/electron/ElectronFramework.js || die "can't prevent electron from unpacking"
	sed -i -e 's|beforeCopyExtraFiles(options) {|beforeCopyExtraFiles(options) { return;|' node_modules/app-builder-lib/out/electron/ElectronFramework.js || die "can't prevent electron from renaming files"
}

electron_src_prepare() {
	default

	electron_binname

	echo "$(jq ".build.electronDist = \"/usr/share/electron/${ELECTRON_VER}\"" package.json)" > package.json
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

	if [[ -f package-lock.json ]]; then
		rm package-lock.json
	fi
}

EXPORT_FUNCTIONS src_prepare
