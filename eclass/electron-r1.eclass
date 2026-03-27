# Copyright 2023-2025 Gentoo Authors
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

# @ECLASS_VARIABLE: ELECTRON_WIDEVINE
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

# @ECLASS_VARIABLE: ELECTRON_SUFFIX
# @DEFAULT_UNSET
# @DESCRIPTION:
# Set by eclass, the name suffix of the selected electron type.

# @ECLASS_VARIABLE: ELECTRON_NAME
# @DEFAULT_UNSET
# @DESCRIPTION:
# Set by eclass, the binary name of the selected electron type.

# @ECLASS_VARIABLE: KEYWORDS
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

# @ECLASS_VARIABLE: ELECTRON_APPNAME
# @DESCRIPTION:
# Name of the application, defaults to $PN

# @ECLASS_VARIABLE: ELECTRON_FLAGS
# @DEFAULT_UNSET
# @DESCRIPTION:
# The electron flags to be passed to the .desktop and launch file

# @ECLASS_VARIABLE: ELECTRON_ENABLE_FEATURES
# @DEFAULT_UNSET
# @DESCRIPTION:
# Comma separated (no spaces) list of features to enable

# @ECLASS_VARIABLE: ELECTRON_DISABLE_FEATURES
# @DEFAULT_UNSET
# @DESCRIPTION:
# Comma separated (no spaces) list of features to disable

# @ECLASS_VARIABLE: ELECTRON_UNSTABLE
# @DEFAULT_UNSET
# @DESCRIPTION:
# When set, disables the system installation of Electron for this package.
# Note: installation has to be handled manually.

# @ECLASS_VARIABLE: ELECTRON_SKIP_DIST
# @DEFAULT_UNSET
# @DESCRIPTION:
# When set, disables patching electron distribution path in packages.json

# @ECLASS_VARIABLE: ELECTRON_FUSES
# @DEFAULT_UNSET
# @DESCRIPTION:
# When set, copies the electron binary

ELECTRON_BDEPEND="
	app-misc/jq
	app-misc/yq
	app-arch/unzip
"

if [[ -z ${ELECTRON_APPNAME} ]]; then
	ELECTRON_APPNAME="${PN}"
fi

ELECTRON_DESTDIR="/usr/share/electron/apps/${P}"
ELECTRON_PREBUILT="
	${ELECTRON_DESTDIR}/resources/app.asar.unpacked/*
	${ELECTRON_DESTDIR}/${ELECTRON_APPNAME}
"

if [[ "${PV}" != *9999* ]]; then
	KEYWORDS="~amd64 ~arm64"
fi
ELECTRON_SUFFIX=""
ELECTRON_NAME="electron"
if [[ -z ${ELECTRON_UNSTABLE} ]]; then
	if [[ ${ELECTRON_WIDEVINE} ]]; then
		ELECTRON_RDEPEND="virtual/electron-widevine:${ELECTRON_SLOT}="
		if [[ "${PV}" != *9999* ]]; then
			KEYWORDS="~amd64"
		fi
		ELECTRON_SUFFIX="-wvcus"
		ELECTRON_NAME="electron-wvcus"
	else
		ELECTRON_RDEPEND="virtual/electron:${ELECTRON_SLOT}="
	fi
else
	ELECTRON_RDEPEND=""
fi

BDEPEND="${RDEPEND} ${ELECTRON_BDEPEND}"
RDEPEND="${RDEPEND} ${ELECTRON_RDEPEND}"
QA_PREBUILT+="${QA_PREBUILT} ${ELECTRON_PREBUILT}"
if [[ -z "${DESTDIR}" ]]; then
	DESTDIR="${ELECTRON_DESTDIR}"
fi
IUSE="${IUSE} wayland X +seccomp vulkan debug"
RESTRICT="${RESTRICT} dedupdebug splitdebug"
REQUIRED_USE="
	${REQUIRED_USE}
	^^ ( wayland X )
"

# @FUNCTION: electron-r1_fullver
# @USAGE: electron-r1_fullver
# @DESCRIPTION:
# Gets the full version of the installed electron target, rather than the slot version
electron-r1_fullver() {
	if [[ ${ELECTRON_WIDEVINE} ]]; then
		TARGET="dev-electron/electron-wvcus"
	else
		TARGET="dev-electron/electron"
	fi

	export ELECTRON_VER="$(best_version ${TARGET}:${ELECTRON_SLOT})"
	if [[ -z "${ELECTRON_VER}" ]]; then
		export ELECTRON_VER="$(best_version ${TARGET}-bin:${ELECTRON_SLOT})"
	fi
}

# @FUNCTION: electron-r1_binname
# @USAGE: electron-r1_binname
# @DESCRIPTION:
# Gets the electron binary name and electron version
electron-r1_binname() {
	electron-r1_fullver

	ELECTRON_VER=${ELECTRON_VER#*/*-} # reduce it to ${PV}-${PR}
	ELECTRON_VER=${ELECTRON_VER#wvcus-} # Remove the wvcus- suffix if it exists
	ELECTRON_VER=${ELECTRON_VER#bin-} # Remove the bin- suffix if it exists
	export ELECTRON_VER=${ELECTRON_VER%%[_-]*} # main version without beta/pre/patch/revision
	export ELECTRON_NORMATIVE_NAME="${ELECTRON_VER}${ELECTRON_SUFFIX}"
	export ELECTRON_PATH="${EPREFIX}/usr/share/electron/${ELECTRON_NORMATIVE_NAME}" # electron reference path
	export ELECTRON_BIN_NAME="electron${ELECTRON_SUFFIX}-${ELECTRON_VER}"
}

# @FUNCTION: electron-r1_execflags
# @USAGE: electron-r1_execflags
# @DESCRIPTION:
# Gets the electron launch flags
electron-r1_execflags() {
	name="${ELECTRON_APPNAME}"

	if [[ -n "${1}" ]] ; then
		name="${1}"
		shift
	fi

	local ELECTRON_FEATURES="AcceleratedVideoDecodeLinuxGL,VaapiVideoDecodeLinuxGL,AcceleratedVideoEncoder,VaapiIgnoreDriverChecks,VaapiOnNvidiaGPUs"
	ELECTRON_EXEC=""

	if ! use seccomp ; then
		ELECTRON_EXEC+=" --disable-seccomp-filter-sandbox"
	fi

	if use wayland ; then
		ELECTRON_EXEC+=" --ozone-platform-hint=wayland --enable-wayland-ime"
	fi

	if use X ; then
		ELECTRON_EXEC+=" --ozone-platform-hint=x11"
	fi

	if use vulkan ; then # this will make warnings on electron 34, but still enable proper GL contexts
		ELECTRON_EXEC+=" --use-gl=angle --use-angle=vulkan"
		ELECTRON_FEATURES+=",Vulkan,DefaultANGLEVulkan,VulkanFromANGLE"
	fi

	if [[ -n "${ELECTRON_FLAGS}" ]]; then
		ELECTRON_EXEC+=" ${ELECTRON_FLAGS}"
	fi

	if [[ -n "${ELECTRON_ENABLE_FEATURES}" ]]; then
		ELECTRON_FEATURES="${ELECTRON_FEATURES},${ELECTRON_ENABLE_FEATURES}"
	fi

	ELECTRON_FEATURES="--enable-features=${ELECTRON_FEATURES}"

	if [[ -n "${ELECTRON_DISABLE_FEATURES}" ]]; then
		ELECTRON_FEATURES+=" --disable-features=${ELECTRON_DISABLE_FEATURES}"
	fi

	ELECTRON_EXEC="${ELECTRON_FEATURES} ${ELECTRON_EXEC}"

	export ELECTRON_EXEC="${ELECTRON_EXEC}"
}

# @FUNCTION: electron-r1_prep
# @USAGE: electron-r1_prep
# @DESCRIPTION:
# copies electron to cwd
electron-r1_prep() {
	cp "${ELECTRON_PATH}/electron" "${ELECTRON_APPNAME}" || die
	chmod 0755 "${ELECTRON_APPNAME}"
}

# @FUNCTION: electron-r1_stage
# @USAGE: electron-r1_stage
# @DESCRIPTION:
# stages electron runtime files
electron-r1_stage() {
	[[ ${EBUILD_PHASE} != install ]] &&
		die "${FUNCNAME} can only be used in src_install"

	if [[ ! -z ${ELECTRON_UNSTABLE} ]]; then
		return
	fi

	electron-r1_binname

	for x in "${ELECTRON_PATH}"/*; do
		local filename="${x##*/}"
		if [[ "${filename}" == "resources" || "${filename}" == "version" || "${filename}" == "electron" || "${filename}" == "electron.debug" || "${filename}" == "locales" ]]; then
			continue
		fi

		dosym "../../${ELECTRON_NORMATIVE_NAME}/${filename}" "${ELECTRON_DESTDIR}/${filename}"
	done

	if [[ -f "${ELECTRON_PATH}/electron.debug" ]] && use debug; then
		dosym "../../${ELECTRON_NORMATIVE_NAME}/electron.debug" "${ELECTRON_DESTDIR}/${ELECTRON_APPNAME}.debug"
	fi

	mkdir "${ED}${ELECTRON_DESTDIR}/locales"

	for x in "${ELECTRON_PATH}/locales"/*; do
		local filename="${x##*/}"
		if [[ "${filename}" != *.pak ]]; then
			continue
		fi

		dosym "../../../${ELECTRON_NORMATIVE_NAME}/locales/${filename}" "${ELECTRON_DESTDIR}/locales/${filename}"
	done

	exeinto "${ELECTRON_DESTDIR}"
	if [[ -z ${ELECTRON_SKIP_DIST} && -z ${ELECTRON_FUSES} ]]; then
		# copy the actual electron binary so the appid/class and process name are proper
		cp "${ELECTRON_PATH}/electron" "${ELECTRON_APPNAME}" || die
		chmod +x "${ELECTRON_APPNAME}"
		doexe "${ELECTRON_APPNAME}"
	else
		# assumes we are in "resources"
		doexe "../${ELECTRON_APPNAME}"
	fi
}

# @FUNCTION: electron-r1_doasar
# @USAGE: electron-r1_doasar
# @DESCRIPTION:
# Installs asar resources
electron-r1_doasar() {
	[[ ${EBUILD_PHASE} != install ]] &&
		die "${FUNCNAME} can only be used in src_install"

	if [[ ! -z ${ELECTRON_UNSTABLE} ]]; then
		return
	fi

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

	appName="${ELECTRON_APPNAME}"

	if [[ -n "${1}" ]] ; then
		appName="${1}"
		shift
	fi

	electron-r1_execflags "${appName}"

	cat > "electron-${appName}" <<-EOF
#!/bin/sh

export ELECTRON_FORCE_IS_PACKAGED=1
cd "${ELECTRON_DESTDIR}"
"${ELECTRON_DESTDIR}"/${appName} ${ELECTRON_EXEC} \${${appName^^}_FLAGS} "\$@"
EOF
	newbin "electron-${appName}" "${appName}"
}

# @FUNCTION: electron-r1_patch_electron_builder
# @USAGE: electron-r1_patch_electron_builder
# @DESCRIPTION:
# Patches electron-builder to not attempt to copy or rename electron files
electron-r1_patch_electron_builder() {
	if [[ ! -z ${ELECTRON_UNSTABLE} ]]; then
		return
	fi

	if [[ ! -z ${ELECTRON_SKIP_DIST} ]]; then
		return
	fi

	find node_modules -iwholename "*/app-builder-lib/out/electron/ElectronFramework.js" -exec sed -i -e 's|.*await unpack|return; await unpack|' {} \; || die "can't prevent electron from unpacking"
	find node_modules -iwholename "*/app-builder-lib/out/electron/ElectronFramework.js" -exec sed -i -e 's|beforeCopyExtraFiles(options) {|beforeCopyExtraFiles(options) { return;|' {} \; || die "can't prevent electron from renaming files"
}

# @FUNCTION: electron-r1_prep_npm
# @USAGE: electron-r1_prep_npm
# @DESCRIPTION:
# Prepares package.json
electron-r1_prep_npm() {
	if [[ ! -z ${ELECTRON_UNSTABLE} ]]; then
		return
	fi

	electron-r1_binname

	if [[ -z ${ELECTRON_SKIP_DIST} ]]; then
		if [[ -f electron-builder.yml ]]; then
			echo "$(yq -y ".electronDist = \"${ELECTRON_PATH}\"" electron-builder.yml)" > electron-builder.yml
		else
			echo "$(jq ".build.electronDist = \"${ELECTRON_PATH}\"" package.json)" > package.json
		fi
	fi

	echo "$(jq 'del(.dependencies.electron)' package.json)" > package.json
	ELECTRON_NPM_VER="${ELECTRON_VER}"
	if [[ ${ELECTRON_WIDEVINE} ]]; then
		ELECTRON_NPM_VER="git+https://github.com/castlabs/electron-releases#v${ELECTRON_VER}+wvcus"
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

# @FUNCTION: electron-r1_target
# @DESCRIPTION:
# prints the distribution folder name for the current architecture
electron-r1_target() {
	if [[ "$ARCH" == "amd64" ]]; then
		echo -n "linux-unpacked"
	else
		echo -n "linux-${ARCH}-unpacked"
	fi
}
