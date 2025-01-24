# Copyright 2023-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: electron-r1.eclass
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

# @ECLASS_VARIABLE: ELECTRON_DESTDIR
# @DESCRIPTION:
# Electron app directory for this ebuild

# @ECLASS_VARIABLE: ELECTRON_PREBUILT
# @DESCRIPTION:
# Expected QA path for prebuilt files

# @ECLASS_VARIABLE: DESTDIR
# @DESCRIPTION:
# Set to ELECTRON_DESTDIR if unset

# @ECLASS_VARIABLE: QA_PREBUILT
# @DESCRIPTION:
# Appends ELECTRON_PREBUILT

ELECTRON_BDEPEND="
	app-misc/jq
	app-arch/unzip
"

ELECTRON_DESTDIR="/usr/share/electron/apps/${P}"
ELECTRON_PREBUILT="usr/share/electron/apps/${P}/resources/app.asar.unpacked/*"

if [[ ${ELECTRON_WVCUS} ]]; then
	ELECTRON_RDEPEND="dev-electron/electron-wvcus-bin:${ELECTRON_SLOT}="
	ELECTRON_KEYWORDS="~amd64"
	ELECTRON_NAME="electron-wvcus"
else
	ELECTRON_RDEPEND="dev-electron/electron-bin:${ELECTRON_SLOT}="
	ELECTRON_KEYWORDS="~amd64 ~arm ~arm64"
	ELECTRON_NAME="electron"
fi

BDEPEND+="${ELECTRON_BDEPEND}"
RDEPEND+="${ELECTRON_RDEPEND}"
QA_PREBUILT+="${ELECTRON_PREBUILT}"
if [[ -z "${DESTDIR}" ]]; then
	DESTDIR="${ELECTRON_DESTDIR}"
fi

# @FUNCTION: electron-r1_binname
# @USAGE: electron-r1_binname
# @DESCRIPTION:
# Gets the electron binary name and electron version
electron-r1_binname() {
	ELECTRON_VER=$(best_version ${ELECTRON_RDEPEND})
	ELECTRON_VER=${ELECTRON_VER#*/*-} # reduce it to ${PV}-${PR}
	ELECTRON_VER=${ELECTRON_VER#wvcus-} # Remove the wvcus- suffix if it exists
	ELECTRON_VER=${ELECTRON_VER#bin-} # Remove the bin- suffix if it exists
	export ELECTRON_VER=${ELECTRON_VER%%[_-]*} # main version without beta/pre/patch/revision
	export ELECTRON_BIN_NAME="${ELECTRON_NAME}-${ELECTRON_VER}"
}

# @FUNCTION: electron-r1_stage
# @USAGE: electron-r1_stage name
# @DESCRIPTION:
# stages electron runtime files
electron-r1_stage() {
	[[ ${EBUILD_PHASE} != install ]] &&
		die "${FUNCNAME} can only be used in src_install"

	electron-r1_binname

	local name="${PN}"
	if [[ ${#} -eq 1 ]]; then
		name="${1}"
	fi

	for x in "${EPREFIX}/usr/share/${ELECTRON_NAME}/${ELECTRON_VER}"/*; do
		local filename="${x##*/}"
		if [[ "${filename}" == "resources" || "${filename}" == "electron" ]]; then
			continue
		fi

		dosym "${x}" "${ELECTRON_DESTDIR}/${filename}"
	done

	exeinto "${ELECTRON_DESTDIR}"
	newexe "${EPREFIX}/usr/share/${ELECTRON_NAME}/${ELECTRON_VER}/electron" "${name}"
}

# @FUNCTION: electron-r1_doasar
# @USAGE: electron-r1_doasar
# @DESCRIPTION:
# Installs asar resources
electron-r1_doasar() {
	[[ ${EBUILD_PHASE} != install ]] &&
		die "${FUNCNAME} can only be used in src_install"

	insinto "${ELECTRON_DESTDIR}/resources"
	doins app.asar
	if [ -d "app.asar.unpacked" ]; then
		doins -r app.asar.unpacked
	fi
}

# @FUNCTION: electron-r1_dobin
# @USAGE: electron-r1_dobin [name]
# @DESCRIPTION:
# Builds a bin wrapper for an electron app
electron-r1_dobin() {
	[[ ${EBUILD_PHASE} != install ]] &&
		die "${FUNCNAME} can only be used in src_install"

	electron-r1_binname

	local name="${PN}"
	if [[ ${#} -eq 1 ]]; then
		name="${1}"
	fi

	cat > "electron-${name}" <<-EOF
#!/bin/sh

export ELECTRON_FORCE_IS_PACKAGED=1
cd "${ELECTRON_DESTDIR}"
"${ELECTRON_DESTDIR}"/${name} "\$@"
EOF
	newbin "electron-${name}" "${name}"
}

# @FUNCTION: electron-r1_patch_electron_builder
# @USAGE: electron-r1_patch_electron_builder
# @DESCRIPTION:
# Patches electron-builder to not attempt to copy or rename electron files
electron-r1_patch_electron_builder() {
	find node_modules -iwholename "*/app-builder-lib/out/electron/ElectronFramework.js" -exec sed -i -e 's|await unpack|return; await unpack|' {} \; || die "can't prevent electron from unpacking"
	find node_modules -iwholename "*/app-builder-lib/out/electron/ElectronFramework.js" -exec sed -i -e 's|beforeCopyExtraFiles(options) {|beforeCopyExtraFiles(options) { return;|' {} \; || die "can't prevent electron from renaming files"
}

electron-r1_src_prepare() {
	default

	electron-r1_binname

	echo "$(jq ".build.electronDist = \"/usr/share/${ELECTRON_NAME}/${ELECTRON_VER}\"" package.json)" > package.json
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

electron-r1_src_compile() {
	./node_modules/.bin/electron-builder --dir -p never || die "can't build electron"
}

electron-r1_src_install() {
	electron-r1_stage
	electron-r1_doasar
	electron-r1_dobin
}

EXPORT_FUNCTIONS src_prepare
