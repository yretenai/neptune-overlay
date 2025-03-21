# Copyright 2023-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake flag-o-matic toolchain-funcs

DESCRIPTION="shadPS4 is an early PlayStation 4 emulator"
HOMEPAGE="https://github.com/shadps4-emu/shadPS4"
LICENSE="GPL-2"
SLOT="0"

if [[ ${PV} == *9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/shadps4-emu/shadPS4.git"
	EGIT_SUBMODULES=(
		"externals/dear_imgui"
		"externals/vma"
		"externals/sdl3"
		"externals/fmt"
		"externals/sirit"
		"externals/discord-rpc"
		"externals/LibAtrac9"
	)
else
	VULKANMEMORYALLOCATOR_COMMIT=5a53a198945ba8260fbc58fadb788745ce6aa263
	EXT_DISCORD_RPC_COMMIT=51b09d426a4a1bcfa6ee6d4894e57d669f4a2e65
	EXT_FMT_COMMIT=8ee89546ffcf046309d1f0d38c0393f02fde56c8
	EXT_IMGUI_COMMIT=636cd4a7d623a2bc9bf59bb3acbb4ca075befba3
	EXT_LIBATRAC9_COMMIT=9640129dc6f2afbca6ceeca3019856e8653a5fb2
	EXT_SDL_COMMIT=a336b62d8b0b97b09214e053203e442e2b6e2be5
	SIRIT_COMMIT=d6f3c0d99862ab2ff8f95e9ac221560f1f97e29a

	SRC_URI="
		https://github.com/shadps4-emu/shadPS4/archive/v.${PV}.tar.gz -> ${P}.tar.gz
		https://github.com/GPUOpen-LibrariesAndSDKs/VulkanMemoryAllocator/archive/${VULKANMEMORYALLOCATOR_COMMIT}.tar.gz -> VulkanMemoryAllocator-${VULKANMEMORYALLOCATOR_COMMIT}.tar.gz
		https://github.com/shadps4-emu/ext-discord-rpc/archive/${EXT_DISCORD_RPC_COMMIT}.tar.gz -> ext-discord-rpc-${EXT_DISCORD_RPC_COMMIT}.tar.gz
		https://github.com/shadps4-emu/ext-fmt/archive/${EXT_FMT_COMMIT}.tar.gz -> ext-fmt-${EXT_FMT_COMMIT}.tar.gz
		https://github.com/shadps4-emu/ext-imgui/archive/${EXT_IMGUI_COMMIT}.tar.gz -> ext-imgui-${EXT_IMGUI_COMMIT}.tar.gz
		https://github.com/shadps4-emu/ext-LibAtrac9/archive/${EXT_LIBATRAC9_COMMIT}.tar.gz -> ext-LibAtrac9-${EXT_LIBATRAC9_COMMIT}.tar.gz
		https://github.com/shadps4-emu/ext-SDL/archive/${EXT_SDL_COMMIT}.tar.gz -> ext-SDL-${EXT_SDL_COMMIT}.tar.gz
		https://github.com/shadps4-emu/sirit/archive/${SIRIT_COMMIT}.tar.gz -> sirit-${SIRIT_COMMIT}.tar.gz
	"
	KEYWORDS="~amd64"
	S="${WORKDIR}/shadPS4-v.${PV}"
fi

IUSE="+qt6 clang tracing"

# missing dependencies:
# fmt 10.2.0 or newer is required
# sdl3 -- wait on gentoo
# vma

# mandatory bundled:
# sirit
# imgui

DEPEND="
	dev-libs/boost
	dev-libs/crypto++
	>=media-video/ffmpeg-5.1.2
	sys-libs/zlib-ng
	sys-libs/zlib
	media-gfx/renderdoc
	>=dev-util/glslang-1.3.296
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
	dev-cpp/tracy:=
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
		llvm-core/clang:19
	)
"

PATCHES=(
	"${FILESDIR}/${PN}-0.4.0-install.patch"
	"${FILESDIR}/${PN}-0.4.0-half.patch"
	"${FILESDIR}/${PN}-0.4.0-tracy.patch"
	"${FILESDIR}/${PN}-0.5.0-compat.patch"
)

src_unpack() {
	default

	if [[ "${PV}" == *9999* ]]; then
		git-r3_src_unpack
	else
		rmdir "${S}/externals/dear_imgui"; mv "${WORKDIR}/ext-imgui-${EXT_IMGUI_COMMIT}" "${S}/externals/dear_imgui" || die "Cannot move ext-imgui"
		rmdir "${S}/externals/discord-rpc"; mv "${WORKDIR}/ext-discord-rpc-${EXT_DISCORD_RPC_COMMIT}" "${S}/externals/discord-rpc" || die "Cannot move ext-discord-rpc"
		rmdir "${S}/externals/fmt"; mv "${WORKDIR}/ext-fmt-${EXT_FMT_COMMIT}" "${S}/externals/fmt" || die "Cannot move ext-fmt"
		rmdir "${S}/externals/LibAtrac9"; mv "${WORKDIR}/ext-LibAtrac9-${EXT_LIBATRAC9_COMMIT}" "${S}/externals/LibAtrac9" || die "Cannot move ext-LibAtrac9"
		rmdir "${S}/externals/sdl3"; mv "${WORKDIR}/ext-SDL-${EXT_SDL_COMMIT}" "${S}/externals/sdl3" || die "Cannot move ext-SDL"
		rmdir "${S}/externals/sirit"; mv "${WORKDIR}/sirit-${SIRIT_COMMIT}" "${S}/externals/sirit" || die "Cannot move sirit"
		rmdir "${S}/externals/vma"; mv "${WORKDIR}/VulkanMemoryAllocator-${VULKANMEMORYALLOCATOR_COMMIT}" "${S}/externals/vma" || die "Cannot move VulkanMemoryAllocator"
	fi
}

src_prepare() {
	eapply_user

	find src \( -iname "*.cpp" -or -iname "*.h" \) -exec sed -e "s|#include <magic_enum/|#include <|" -i "{}" \; || die
	sed -e "s|magic_enum .* CONFIG|magic_enum CONFIG|" -i CMakeLists.txt || die
	sed -e "s|g_signal_connect_data|g_signal_connect_data_tmp|" -i externals/sdl3/src/tray/unix/SDL_tray.c || die
	sed -e "s|g_object_unref|g_object_unref_tmp|" -i externals/sdl3/src/tray/unix/SDL_tray.c || die

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
		-D ENABLE_UPDATER=OFF
		-D SIRIT_USE_SYSTEM_SPIRV_HEADERS=ON
		-D TRACY_ENABLE=$(usex tracing)
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
