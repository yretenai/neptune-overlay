# Copyright 2023-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DOTNET_PKG_COMPAT="8.0"
CMAKE_BUILD_TYPE="Release"
CMAKE_MAKEFILE_GENERATOR="emake"
NUGETS=""
LLVM_COMPAT=( {16..18} )

inherit dotnet-pkg cmake llvm-r1 toolchain-funcs desktop vcs-clean

DESCRIPTION="A hex editor for reverse engineers, programmers, and eyesight"
HOMEPAGE="https://github.com/WerWolv/ImHex"

SRC_URI="${NUGET_URIS}"
LICENSE="GPL-2"
SLOT="0"

inherit git-r3
EGIT_REPO_URI="https://github.com/WerWolv/ImHex.git"

if [[ ${PV} != *9999* ]]; then
	EGIT_COMMIT="v${PV}"
	KEYWORDS="~amd64 ~arm64"
fi

IUSE="+system-llvm lto"
RESTRICT="mirror"

DEPEND="
	app-forensics/yara
	dev-libs/pattern-language
	>=dev-cpp/nlohmann_json-3.10.2
	dev-libs/capstone
	dev-libs/nativefiledialog-extended
	>=dev-libs/libfmt-8.0.0:=
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
			sys-devel/clang:${LLVM_SLOT}=
			sys-devel/llvm:${LLVM_SLOT}=
		')
	)
	app-admin/chrpath
	gnome-base/librsvg
	sys-devel/lld
	${DOTNET_PKG_BDEPS}
"

PATCHES=(
	"${FILESDIR}/yara-shared.patch"
)

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
	git-r3_src_unpack
	dotnet-pkg_src_unpack
	egit_clean "${S}/lib"
}

src_prepare() {
	sed -e "s| -Werror||g" -i cmake/build_helpers.cmake || die
	sed -e "s| -Werror||g" -i lib/external/pattern_language/lib/CMakeLists.txt || die
	sed -e "s| -Werror||g" -i lib/external/pattern_language/cli/CMakeLists.txt || die
	sed -e "s|^add_dotnet_assembly|#|g" -i plugins/script_loader/support/dotnet/CMakeLists.txt || die
	sed -e "s|add_dependencies|#|g" -i plugins/script_loader/CMakeLists.txt || die

	cmake_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-D CMAKE_BUILD_TYPE="Release" \
		-D CMAKE_C_FLAGS="-fuse-ld=lld ${CFLAGS}" \
		-D CMAKE_CXX_FLAGS="-fuse-ld=lld ${CXXFLAGS}" \
		-D CMAKE_SKIP_RPATH=ON \
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
		-D USE_SYSTEM_YARA=ON
	)

	cmake_src_configure
	dotnet-pkg_src_configure
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
