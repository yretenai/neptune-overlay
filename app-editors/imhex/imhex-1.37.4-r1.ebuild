# Copyright 2023-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PLUTOVG_PV="0.0.12"

DOTNET_PKG_COMPAT=8.0
DOTNET_NEPTUNE_TARGETS=( 8.0 )
LLVM_COMPAT=( {16..20} )

inherit neptune-dotnet cmake llvm-r1 toolchain-funcs desktop vcs-clean

DESCRIPTION="A hex editor for reverse engineers, programmers, and eyesight"
HOMEPAGE="https://github.com/WerWolv/ImHex"

PLUTOVG_COMMIT=3e6f922f453da1c9e7d1d7f66cac1d9724a18b47
SRC_URI="
	https://github.com/sammycage/plutovg/archive/${PLUTOVG_COMMIT}.tar.gz -> plutovg-${PLUTOVG_COMMIT}.tar.gz
"

if [[ ${PV} == *9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/WerWolv/ImHex.git"
	EGIT_SUBMODULES=( 
		"*"
		-lib/third_party/nativefiledialog
		-lib/third_party/yara/yara
		-lib/third_party/fmt
		-lib/third_party/capstone
		-lib/external/pattern_language/external/fmt
		-lib/external/disassembler/external/fmt
	 )
else
	JTHREAD_COMMIT=0fa8d394254886c555d6faccd0a3de819b7d47f8
	EDLIB_COMMIT=42aa8fa7051fb2aa1c4f144c5eda22a0e753f026
	LUNASVG_COMMIT=5e968bd546edd2a82fdb67834c99e38fac40f39d # todo: neptune packages this
	DISASSEMBLER_COMMIT=a2217dd3bca9e3bdc284b163a35eb7d300937728
	HASHLIBPLUS_COMMIT=1823dd116244b035c540e3079ba7862b406086c0
	LIBROMFS_COMMIT=4f42f099b2f83e444e570acee42ac1003804ee38
	LIBWOLV_COMMIT=00021679c250ae92f9d0bc139f4cea3d2ca6b12f
	PATTERNLANGUAGE_COMMIT=9833500589b8bd49ac05e96a56c6d968ff896ea3
	XDGPP_COMMIT=f01f810714443d0f10c333d4d1d9c0383be41375
	CLI11_COMMIT=6c7b07a878ad834957b98d0f9ce1dbe0cb204fc9 # todo: gentoo packages this
	THROWING_PTR_COMMIT=cd28490ebf9be803497a9fff733de62295d8288e
	SRC_URI+="
		https://github.com/WerWolv/ImHex/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz
		https://github.com/josuttis/jthread/archive/${JTHREAD_COMMIT}.tar.gz -> jthread-${JTHREAD_COMMIT}.tar.gz
		https://github.com/Martinsos/edlib/archive/${EDLIB_COMMIT}.tar.gz -> edlib-${EDLIB_COMMIT}.tar.gz
		https://github.com/sammycage/lunasvg/archive/${LUNASVG_COMMIT}.tar.gz -> lunasvg-${LUNASVG_COMMIT}.tar.gz
		https://github.com/WerWolv/Disassembler/archive/${DISASSEMBLER_COMMIT}.tar.gz -> Disassembler-${DISASSEMBLER_COMMIT}.tar.gz
		https://github.com/WerWolv/HashLibPlus/archive/${HASHLIBPLUS_COMMIT}.tar.gz -> HashLibPlus-${HASHLIBPLUS_COMMIT}.tar.gz
		https://github.com/WerWolv/libromfs/archive/${LIBROMFS_COMMIT}.tar.gz -> libromfs-${LIBROMFS_COMMIT}.tar.gz
		https://github.com/WerWolv/libwolv/archive/${LIBWOLV_COMMIT}.tar.gz -> libwolv-${LIBWOLV_COMMIT}.tar.gz
		https://github.com/WerWolv/PatternLanguage/archive/${PATTERNLANGUAGE_COMMIT}.tar.gz -> PatternLanguage-${PATTERNLANGUAGE_COMMIT}.tar.gz
		https://github.com/WerWolv/xdgpp/archive/${XDGPP_COMMIT}.tar.gz -> xdgpp-${XDGPP_COMMIT}.tar.gz
		https://github.com/CLIUtils/CLI11/archive/${CLI11_COMMIT}.tar.gz -> CLI11-${CLI11_COMMIT}.tar.gz
		https://github.com/rockdreamer/throwing_ptr/archive/${THROWING_PTR_COMMIT}.tar.gz -> throwing_ptr-${THROWING_PTR_COMMIT}.tar.gz
		${NUGET_URIS}
	"
	S="${WORKDIR}/ImHex-${PV}"
	KEYWORDS="~amd64"
fi

LICENSE="GPL-2"
SLOT="0"
IUSE="+system-llvm lto"
RESTRICT="mirror"

DEPEND="
	app-forensics/yara
	>=dev-cpp/nlohmann_json-3.10.2
	dev-libs/capstone
	>=dev-libs/nativefiledialog-extended-1.2.0
	dev-libs/libfmt:=
	media-libs/freetype
	media-libs/glfw
	media-libs/glm
	net-libs/libssh2
	net-libs/mbedtls
	net-misc/curl
	sys-apps/dbus
	sys-apps/file
	sys-apps/xdg-desktop-portal
	virtual/libiconv
	virtual/libintl
"
RDEPEND="
	${DEPEND}
	${DOTNET_PKG_RDEPS}
"
BDEPEND="
	system-llvm? (
		$(llvm_gen_dep '
			llvm-core/clang:${LLVM_SLOT}=
			llvm-core/llvm:${LLVM_SLOT}=
		')
	)
	app-admin/chrpath
	gnome-base/librsvg
	llvm-core/lld
	${DOTNET_PKG_BDEPS}
"

DOTNET_PKG_PROJECTS=( "${S}/plugins/script_loader/support/dotnet/AssemblyLoader/AssemblyLoader.csproj" )

pkg_pretend() {
	if tc-is-gcc && [[ $(gcc-major-version) -lt 12 ]]; then
		die "${PN} requires GCC 12 or newer"
	fi
}

# never gets called
pkg_setup() {
	dotnet-pkg-base_setup
}

src_unpack() {
	if [[ "${PV}" == *9999* ]]; then
		default
		git-r3_src_unpack
		egit_clean "${S}/lib"
	fi

	neptune-dotnet_src_unpack

	if [[ "${PV}" != *9999* ]]; then
		rmdir "${S}/lib/third_party/jthread/jthread"; mv "${WORKDIR}/jthread-${JTHREAD_COMMIT}" "${S}/lib/third_party/jthread/jthread" || die "Cannot move jthread"
		rmdir "${S}/lib/third_party/edlib"; mv "${WORKDIR}/edlib-${EDLIB_COMMIT}" "${S}/lib/third_party/edlib" || die "Cannot move edlib"
		rmdir "${S}/lib/third_party/lunasvg"; mv "${WORKDIR}/lunasvg-${LUNASVG_COMMIT}" "${S}/lib/third_party/lunasvg" || die "Cannot move lunasvg"
		rmdir "${S}/lib/external/disassembler"; mv "${WORKDIR}/Disassembler-${DISASSEMBLER_COMMIT}" "${S}/lib/external/disassembler" || die "Cannot move Disassembler"
		rmdir "${S}/lib/third_party/HashLibPlus"; mv "${WORKDIR}/HashLibPlus-${HASHLIBPLUS_COMMIT}" "${S}/lib/third_party/HashLibPlus" || die "Cannot move HashLibPlus"
		rmdir "${S}/lib/external/libromfs"; mv "${WORKDIR}/libromfs-${LIBROMFS_COMMIT}" "${S}/lib/external/libromfs" || die "Cannot move libromfs"
		rmdir "${S}/lib/external/libwolv"; mv "${WORKDIR}/libwolv-${LIBWOLV_COMMIT}" "${S}/lib/external/libwolv" || die "Cannot move libwolv"
		rmdir "${S}/lib/external/pattern_language"; mv "${WORKDIR}/PatternLanguage-${PATTERNLANGUAGE_COMMIT}" "${S}/lib/external/pattern_language" || die "Cannot move PatternLanguage"
		rmdir "${S}/lib/third_party/xdgpp"; mv "${WORKDIR}/xdgpp-${XDGPP_COMMIT}" "${S}/lib/third_party/xdgpp" || die "Cannot move xdgpp"

		rmdir "${S}/lib/external/pattern_language/external/libwolv"; ln -s "${S}/lib/external/libwolv" "${S}/lib/external/pattern_language/external/libwolv" || die "Cannot link libwolv to PatternLanguage"
		rmdir "${S}/lib/external/disassembler/external/libwolv"; ln -s "${S}/lib/external/libwolv" "${S}/lib/external/disassembler/external/libwolv" || die "Cannot link libwolv to Disassembler"

		rmdir "${S}/lib/external/pattern_language/external/cli11"; mv "${WORKDIR}/CLI11-${CLI11_COMMIT}" "${S}/lib/external/pattern_language/external/cli11" || die "Cannot move CLI11"
		rmdir "${S}/lib/external/pattern_language/external/throwing_ptr"; mv "${WORKDIR}/throwing_ptr-${THROWING_PTR_COMMIT}" "${S}/lib/external/pattern_language/external/throwing_ptr" || die "Cannot move throwing_ptr"
	fi

	rmdir "${S}/lib/third_party/lunasvg/plutovg";  mv "${WORKDIR}/plutovg-${PLUTOVG_COMMIT}" "${S}/lib/third_party/lunasvg/plutovg" || die "Cannot move plutovg"
}

src_prepare() {
	sed -e "s| -Werror||g" -i cmake/build_helpers.cmake || die
	sed -e "s| -Werror||g" -i lib/external/pattern_language/lib/CMakeLists.txt || die
	sed -e "s| -Werror||g" -i lib/external/pattern_language/cli/CMakeLists.txt || die
	sed -e "s|^add_dotnet_assembly|#|g" -i plugins/script_loader/support/dotnet/CMakeLists.txt || die
	sed -e "s|add_dependencies|#|g" -i plugins/script_loader/CMakeLists.txt || die

	cmake_src_prepare
	neptune-dotnet_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-D CMAKE_BUILD_TYPE="Release" \
		-D CMAKE_SKIP_RPATH=OFF \
		-D IMHEX_BUNDLE_DOTNET=OFF \
		-D IMHEX_DISABLE_STACKTRACE=OFF \
		-D IMHEX_ENABLE_LTO=$(usex lto) \
		-D IMHEX_ENABLE_UNITY_BUILD=OFF \
		-D IMHEX_IGNORE_BAD_CLONE=ON \
		-D IMHEX_IGNORE_BAD_COMPILER=OFF \
		-D IMHEX_OFFLINE_BUILD=ON \
		-D IMHEX_PATTERNS_PULL_MASTER=OFF \
		-D IMHEX_PLUGINS_IN_SHARE=ON \
		-D IMHEX_STRICT_WARNINGS=OFF \
		-D IMHEX_STRIP_RELEASE=OFF \
		-D IMHEX_USE_DEFAULT_BUILD_SETTINGS=OFF \
		-D IMHEX_USE_GTK_FILE_PICKER=OFF \
		-D IMHEX_VERSION="${PV}" \
		-D PROJECT_VERSION="${PV}" \
		-D USE_SYSTEM_CAPSTONE=ON \
		-D USE_SYSTEM_FMT=ON \
		-D USE_SYSTEM_LLVM=$(use system-llvm) \
		-D USE_SYSTEM_NFD=ON \
		-D USE_SYSTEM_NLOHMANN_JSON=ON \
		-D USE_SYSTEM_YARA=ON \
		-D FETCHCONTENT_FULLY_DISCONNECTED=ON
	)

	cmake_src_configure
	neptune-dotnet_src_configure
}

# again, calling both because dotnet will never be called apparently?
src_compile() {
	cmake_src_compile
	dotnet-pkg_src_compile
}

src_install() {
	cmake_src_install
	dotnet-pkg-base_install "/usr/share/imhex/plugins/"
	domenu "${S}/dist/${PN}.desktop"
}
