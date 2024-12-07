# Copyright 2023-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake git-r3 flag-o-matic

DESCRIPTION="shadPS4 is an early PlayStation 4 emulator"
HOMEPAGE="https://github.com/shadps4-emu/shadPS4"
LICENSE="GPL-2"
SLOT="0"

EGIT_REPO_URI="https://github.com/shadps4-emu/shadPS4.git"
EGIT_SUBMODULES=(
	"externals/dear_imgui"
	"externals/tracy"
	"externals/vma"
	"externals/sdl3"
	"externals/fmt"
	"externals/sirit"
	"externals/discord-rpc"
	"externals/LibAtrac9"
)

if [[ ${PV} != *9999* ]]; then
	EGIT_COMMIT="v.${PV}"
	KEYWORDS="~amd64"
fi

IUSE="+qt6 clang"

# missing dependencies:
# fmt 10.2.0 or newer is required
# sdl3 -- wait on gentoo
# vma

# mandatory bundled:
# sirit
# tracy
# imgui

DEPEND="
	dev-libs/boost
	dev-libs/crypto++
	>=media-video/ffmpeg-5.1.2
	sys-libs/zlib-ng
	sys-libs/zlib
	media-gfx/renderdoc
	dev-util/glslang:0/15
	>=dev-cpp/robin-map-1.3.0
	>=dev-libs/xbyak-7.07.1[clang?]
	dev-cpp/toml11
	>=dev-libs/xxhash-0.8.2
	>=dev-libs/pugixml-1.14
	media-libs/vulkan-layers
	media-sound/sndio
	virtual/jack
	media-libs/openal
	dev-libs/half
	>=dev-libs/zydis-5.0.0_alpha[clang?]
	qt6? (
		dev-qt/qtbase:6[widgets,vulkan,concurrent,network]
		dev-qt/qtmultimedia:6[ffmpeg,vulkan]
		dev-qt/qttools:6[linguist]
	)
"

RDEPEND="
	${DEPEND}
"

BDEPEND="
	dev-util/spirv-headers
	dev-util/vulkan-headers
	>=dev-cpp/magic_enum-0.9.6
	clang? (
		sys-devel/clang:19
	)
	>=sys-devel/gcc-14:*
"

PATCHES=(
	"${FILESDIR}/${PN}-install.patch"
	"${FILESDIR}/${PN}-half.patch"
)

src_configure() {
	if use clang; then
		CC="${CHOST}-clang"
		CXX="${CHOST}-clang++"
		AR=llvm-ar
		append-ldflags "-fuse-ld=lld"
	fi

	local mycmakeargs=(
		-D ENABLE_QT_GUI=$(usex qt6)
		-D ENABLE_UPDATER=OFF
		-D SIRIT_USE_SYSTEM_SPIRV_HEADERS=ON
	)

	cmake_src_configure
}


pkg_setup() {
	[[ ${MERGE_TYPE} == binary ]] && return

	if tc-is-gcc && ver_test $(gcc-version) -lt 13 ; then
		eerror "shadps4 requires >=sys-devel/gcc-14 to build"
		eerror "Please upgrade GCC."
		eerror "\temerge -v1 sys-devel/gcc"
		eerror "and select GCC-14 or newer with gcc-config"
		die "GCC version is too old to compile shadps4!"
	fi
}


pkg_postinst() {
	elog
	elog "shadPS4 currently relies on vulkan extensions which may not be"
	elog "supported by AMD's open source Radeon drivers."
	elog "If you encounter graphical glitches, please install:"
	elog "\tamdgpu-pro-drivers"
	elog "and run with vk_pro shadps4"
	elog

	ewarn
	ewarn "shadPS4 is observed to have buggy behavior when "
	ewarn "launching a game binary directly."
	if ! use qt6; then
		ewarn "if you observe issues, compile with the qt6 USE flag"
		ewarn "and launching the game via the Qt GUI"
	else
		ewarn "if you observe issues, try launching via the QT GUI"
	fi
	ewarn
}
