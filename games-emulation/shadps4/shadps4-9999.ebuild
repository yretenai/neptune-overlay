# Copyright 2023-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake git-r3 flag-o-matic

DESCRIPTION="PS4 Emulator"
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
)

if [[ ${PV} != *9999* ]]; then
	EGIT_COMMIT="v.${PV}"
	KEYWORDS="~amd64 ~ppc64 ~x86"
fi

IUSE="+qt6 +hacks clang"

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
	media-gfx/renderdoc
	dev-util/glslang
	>=dev-cpp/robin-map-1.3.0
	>=dev-libs/xbyak-7.07.1[clang?]
	dev-cpp/toml11
	>=dev-libs/xxhash-0.8.2
	>=dev-libs/pugixml-1.14
	media-libs/vulkan-layers
	media-sound/sndio
	virtual/jack
	media-libs/openal
	>=dev-libs/zydis-5.0.0[clang?]
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
	sys-devel/clang
"

PATCHES=(
	"${FILESDIR}/install.patch"
	"${FILESDIR}/datadir.patch"
)

src_prepare() {
	eapply_user

	if use hacks; then
		eapply "${FILESDIR}/hacks.patch"
	fi

	cmake_src_prepare
}

src_configure() {
	if use clang; then
		CC="${CHOST}-clang"
		CXX="${CHOST}-clang++"
		AR=llvm-ar
		append-ldflags "-fuse-ld=lld"
	fi

	local mycmakeargs=(
		-D ENABLE_QT_GUI=$(usex qt6)
		-D SIRIT_USE_SYSTEM_SPIRV_HEADERS=ON
	)

	cmake_src_configure
}
