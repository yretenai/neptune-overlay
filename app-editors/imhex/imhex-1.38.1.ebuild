# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

LLVM_COMPAT=( {20..22} )

inherit cmake llvm-r2 toolchain-funcs flag-o-matic xdg-utils

DESCRIPTION="A hex editor for reverse engineers, programmers, and eyesight"
HOMEPAGE="https://github.com/WerWolv/ImHex"
SRC_URI="
	https://github.com/WerWolv/ImHex/releases/download/v${PV}/Full.Sources.tar.gz -> ${P}.gh.tar.gz
"
S="${WORKDIR}/ImHex"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE="+llvm test lto +desktop-portal lz4"
RESTRICT="!test? ( test )"

# Skip cmake version detection, as there are a lot of dependencies
# (that we do not use) that wants cmake < 3.5, so it prints a warning
CMAKE_QA_COMPAT_SKIP=yes

PATCHES=(
	# If virtual/dotnet-sdk is installed on your system, then cmake
	# will use it at some point and try to access internet.
	# Because it did not cause any issue, we can disable it
	"${FILESDIR}/imhex-1.38.1-remove_dotnet.patch"
	# Correct the cmake MbedTLS search call
	"${FILESDIR}/imhex-1.38.1-cmake_mbedtls.patch"
	# Remove -Werror
	"${FILESDIR}/imhex-1.38.1-remove_Werror.patch"
	# Fix LLVM Demangle include
	"${FILESDIR}/imhex-1.38.1-PR2680.patch"
	# optional imhex patterns
	"${FILESDIR}/imhex-1.38.1-optional-patterns.patch"
	# search lunasvg on pkgconfig if not exist
	"${FILESDIR}/imhex-1.38.1-pkgconfig-lunasvg.patch"
)

DOCS+=( LICENSE PLUGINS.md changelog.md )

DEPEND="
	app-arch/bzip2
	app-arch/xz-utils
	app-arch/zstd:=
	>=app-forensics/yara-4.2.0:=
	>=dev-cpp/nlohmann_json-3.10.2
	dev-libs/boost
	>=dev-libs/capstone-5.0.3:=
	<dev-libs/capstone-6
	dev-libs/md4c
	>=dev-libs/libfmt-11.0.2:=
	>=dev-libs/nativefiledialog-extended-1.2.1[desktop-portal?]
	media-libs/fontconfig
	media-libs/freetype
	>=media-libs/glfw-3.4[X]
	media-libs/glm
	media-libs/libglvnd
	media-libs/lunasvg
	net-libs/mbedtls:=
	net-misc/curl
	sys-apps/file
	virtual/zlib:=
	virtual/libiconv
	virtual/libintl
"
RDEPEND="
	${DEPEND}
	~dev-misc/imhex-patterns-${PV}
"
BDEPEND="
	app-admin/chrpath
	gnome-base/librsvg
	lz4? ( app-arch/lz4 )
	llvm? (
		$(llvm_gen_dep '
			llvm-core/llvm:${LLVM_SLOT}
		')
	)
"

pkg_pretend() {
	if tc-is-gcc && [[ $(gcc-major-version) -lt 14 ]]; then
		die "${PN} requires GCC 14 or newer"
	fi
}

src_configure() {
	# Building ImHex with -Werror=strict-aliasing gives a failed build
	# for tests/algorithms/source/endian.cpp, and ImHex usually has pretty
	# clean build (without warnings), so it should be safe to do
	filter-flags -Werror=strict-aliasing

	if use test; then
		sed -ie "s/tests EXCLUDE_FROM_ALL/tests ALL/" "${S}/CMakeLists.txt"
	fi

	local mycmakeargs=(
		-D IMHEX_STRIP_RELEASE=OFF \
		-D IMHEX_OFFLINE_BUILD=ON \
		-D IMHEX_IGNORE_BAD_CLONE=ON \
		-D IMHEX_PATTERNS_PULL_MASTER=OFF \
		-D IMHEX_IGNORE_BAD_COMPILER=OFF \
		-D IMHEX_USE_GTK_FILE_PICKER=$(usex !desktop-portal) \
		-D IMHEX_DISABLE_STACKTRACE=OFF \
		-D IMHEX_BUNDLE_DOTNET=OFF \
		-D IMHEX_ENABLE_LTO=$(usex lto) \
		-D IMHEX_USE_DEFAULT_BUILD_SETTINGS=OFF \
		-D IMHEX_BUILD_HARDENING=OFF \
		-D IMHEX_STRICT_WARNINGS=OFF \
		-D IMHEX_STATIC_LINK_PLUGINS=OFF \
		-D IMHEX_ENABLE_UNITY_BUILD=OFF \
		-D IMHEX_ENABLE_STD_ASSERTS=OFF \
		-D IMHEX_ENABLE_UNIT_TESTS=$(usex test) \
		-D IMHEX_ENABLE_PRECOMPILED_HEADERS=OFF \
		-D IMHEX_ENABLE_CXX_MODULES=OFF \
		-D IMHEX_ENABLE_CPPCHECK=OFF \
		-D IMHEX_BUNDLE_PLUGIN_SDK=ON \
		-D IMHEX_COMPRESS_DEBUG_INFO=OFF \
		-D IMHEX_VERSION="${PV}" \
		-D PROJECT_VERSION="${PV}" \
		-D LIBPL_ENABLE_TESTS=$(usex test) \
		-D LIBPL_ENABLE_EXAMPLE=ON \
		-D LIBWOLV_ENABLE_TESTS=$(usex test) \
		-D LIBWOLV_ENABLE_EXAMPLES=ON \
		-D USE_SYSTEM_BOOST=ON \
		-D USE_SYSTEM_CAPSTONE=ON \
		-D USE_SYSTEM_FMT=ON \
		-D USE_SYSTEM_LLVM=$(usex llvm) \
		-D USE_SYSTEM_MD4C=ON \
		-D USE_SYSTEM_NFD=ON \
		-D USE_SYSTEM_NLOHMANN_JSON=ON \
		-D USE_SYSTEM_YARA=ON \
		-D USE_SYSTEM_LUNASVG=ON \
	)

	cmake_src_configure
}

pkg_postinst() {
	xdg_desktop_database_update
	xdg_mimeinfo_database_update
}
pkg_postrm() {
	xdg_desktop_database_update
	xdg_mimeinfo_database_update
}
