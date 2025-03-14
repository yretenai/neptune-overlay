# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: swift.eclass
# @SUPPORTED_EAPIS: 8
# @BLURB: Eclass for swift build process
# @MAINTAINER:
# Ada <ada@chronovore.dev>
# @AUTHOR:
# Ada <ada@chronovore.dev>

# @ECLASS_VARIABLE: SWIFT_CHECKOUT
# @PRE_INHERIT
# @DEFAULT_UNSET
# @DESCRIPTION:
# The dependencies the eclass should process for this package.

# @ECLASS_VARIABLE: SWIFT_ARTIFACT
# @PRE_INHERIT
# @DEFAULT_UNSET
# @DESCRIPTION:
# The build artifacts the project emits, to install later.

# @ECLASS_VARIABLE: SWIFT_BUILD_TARGET
# @PRE_INHERIT
# @DESCRIPTION:
# The build target for this package, defaults to "release."

# @ECLASS_VARIABLE: SWIFT_WORKDIR
# @PRE_INHERIT
# @DESCRIPTION:
# The work directory for this package, defaults to "${S}"

# @ECLASS_VARIABLE: SWIFT_URIS
# @DEFAULT_UNSET
# @OUTPUT_VARIABLE
# @DESCRIPTION:
# Sets the SRC_URI values for dependencies
#
# This variable is set automatically the eclass.

# @ECLASS_VARIABLE: SWIFT_PV
# @PRE_INHERIT
# @DESCRIPTION:
# Determines which version of swift to use.

if [[ -z ${_SWIFT_ECLASS} ]]; then
_SWIFT_ECLASS=1

DEPEND="
	>=dev-lang/swift-${SWIFT_PV}:=
"

BDEPEND="
	>=dev-lang/swift-${SWIFT_PV}
	app-portage/pyswiftebuild
"

SWIFT_URIS=""
for SWIFT_CHECKOUT in "${SWIFT_CHECKOUTS[@]}"; do
	checkout=($SWIFT_CHECKOUT)
	SWIFT_URIS+="${checkout[1]}/archive/${checkout[2]}.tar.gz -> ${checkout[0]}-${checkout[2]}.tar.gz "
done

unset SWIFT_CHECKOUT

if [[ -z "${SWIFT_WORKDIR}" ]]; then
	SWIFT_WORKDIR="${S}"
fi

if [[ -z "${SWIFT_BUILD_TARGET}" ]]; then
	SWIFT_BUILD_TARGET="release"
fi

# @FUNCTION: eswift
# @USAGE: eswift args
# @DESCRIPTION:
# Calls the Swift driver with the arguments
eswift() {
	local version="$(best_version ">=dev-lang/swift-${SWIFT_PV}")"
	local swiftpath=$(which "swift-${version#*/*-}")
	local SWIFTC="${EPREFIX}/usr/$(get_libdir)/swift-${version#*/*-}/usr/bin/swift"
	${SWIFTC} $@ || die "could not build"
}

# @FUNCTION: _swift_checkout_dep
# @USAGE: _swift_checkout_dep path/to/dep checkout-name
# @DESCRIPTION:
# Links a dependency to the checkouts directory
_swift_checkout_dep() {
	local path="$1"
	local target="${SWIFT_WORKDIR}/.build/checkouts/$2"
	ln -s "$path" "$target" || die "could not link dependency"
}

swift_src_prepare() {
	default

	mkdir -p "${SWIFT_WORKDIR}/.build/checkouts/" || die "could not make checkouts directory"
	for SWIFT_CHECKOUT in "${SWIFT_CHECKOUTS[@]}"; do
		local checkout=($SWIFT_CHECKOUT)
		_swift_checkout_dep "${WORKDIR}/${checkout[0]}-${checkout[2]}" "${checkout[0]}-${checkout[2]}"
	done
}

swift_src_configure() {
	pyswiftebuild --workdir "${SWIFT_WORKDIR}" --state
}

swift_src_compile() {
	addpredict "${EPREFIX}/var/lib/portage/home/.swiftpm"
	eswift build --disable-automatic-resolution --disable-dependency-cache --disable-local-rpath --disable-build-manifest-caching --disable-prefetching -c "${SWIFT_BUILD_TARGET}" ${SWIFTARGS} ${SWIFT_BUILD_ARGS}
}

# @FUNCTION: _swift_src_install_direct
# @USAGE: _swift_src_install_direct
# @DESCRIPTION:
# Installs swift artifacts
_swift_src_install_direct() {
	for SWIFT_ARTIFACT in "${SWIFT_ARTIFACTS[@]}"; do
		local artifact=($SWIFT_ARTIFACT)
		case "${artifact[0]}" in
			"exe")
				doexe ".build/${SWIFT_BUILD_TARGET}/${artifact[1]}"
				;;
			"so")
				dolib.so ".build/${SWIFT_BUILD_TARGET}/${artifact[1]}"
				;;
			"a")
				dolib.a ".build/${SWIFT_BUILD_TARGET}/${artifact[1]}"
				;;
			*);;
		esac
	done
}

# @FUNCTION: _swift_src_install_bundle
# @USAGE: _swift_src_install_bundle
# @DESCRIPTION:
# Installs swift artifacts to /usr/share/swift/${PN}
# This is technically bad, as the resources will need to be copied over for library users
_swift_src_install_bundle() {
	exeinto "/usr/share/swift/${PN}"
	insinto "/usr/share/swift/${PN}"

	_swift_src_install_direct

	for SWIFT_ARTIFACT in "${SWIFT_ARTIFACTS[@]}"; do
		local artifact=($SWIFT_ARTIFACT)
		case "${artifact[0]}" in
			"exe")
				dosym "../share/swift/${PN}/${artifact[1]}" "/usr/bin/${artifact[1]}"
				;;
			*);;
		esac
	done

	doins -r "${SWIFT_WORKDIR}/.build/${SWIFT_BUILD_TARGET}/"*.resources
}

swift_src_install() {
	if [[ "${SWIFT_HAS_RESOURCES}" -eq 1 ]]; then
		_swift_src_install_bundle
	else
		_swift_src_install_direct
	fi
}

EXPORT_FUNCTIONS src_prepare src_configure src_compile src_install
fi
