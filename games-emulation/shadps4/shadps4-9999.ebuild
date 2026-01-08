# Copyright 2023-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake toolchain-funcs

DESCRIPTION="shadPS4 is an early PlayStation 4 emulator"
HOMEPAGE="https://github.com/shadps4-emu/shadPS4"
LICENSE="GPL-2"
SLOT="0"

if [[ ${PV} == *9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/shadps4-emu/shadPS4.git"
	EGIT_SUBMODULES=(
		"externals/dear_imgui"
		"externals/fmt"
		"externals/sirit"
		"externals/discord-rpc"
		"externals/LibAtrac9"
		"externals/ext-libusb"
		"externals/hwinfo"
		"externals/aacdec/fdk-aac"
	)
else
	VULKANMEMORYALLOCATOR_COMMIT=
	EXT_DISCORD_RPC_COMMIT=
	EXT_FMT_COMMIT=
	EXT_IMGUI_COMMIT=
	EXT_LIBATRAC9_COMMIT=
	EXT_LIBUSB_COMMIT= # todo: this exists as a package
	EXT_HWINFO_COMMIT= # todo: this exists as a package
	SIRIT_COMMIT=
	FDK_AAC_COMMIT= # todo: this exists as a package

	SRC_URI="
		https://github.com/shadps4-emu/shadPS4/archive/v.${PV}.tar.gz -> ${P}.tar.gz
		https://github.com/GPUOpen-LibrariesAndSDKs/VulkanMemoryAllocator/archive/${VULKANMEMORYALLOCATOR_COMMIT}.tar.gz -> ${PN}-VulkanMemoryAllocator-${VULKANMEMORYALLOCATOR_COMMIT}.tar.gz
		https://github.com/shadps4-emu/ext-discord-rpc/archive/${EXT_DISCORD_RPC_COMMIT}.tar.gz -> ${PN}-ext-discord-rpc-${EXT_DISCORD_RPC_COMMIT}.tar.gz
		https://github.com/shadps4-emu/ext-fmt/archive/${EXT_FMT_COMMIT}.tar.gz -> ${PN}-ext-fmt-${EXT_FMT_COMMIT}.tar.gz
		https://github.com/shadps4-emu/ext-imgui/archive/${EXT_IMGUI_COMMIT}.tar.gz -> ${PN}-ext-imgui-${EXT_IMGUI_COMMIT}.tar.gz
		https://github.com/shadps4-emu/ext-LibAtrac9/archive/${EXT_LIBATRAC9_COMMIT}.tar.gz -> ${PN}-ext-LibAtrac9-${EXT_LIBATRAC9_COMMIT}.tar.gz
		https://github.com/shadps4-emu/ext-libusb/archive/${EXT_LIBUSB_COMMIT}.tar.gz -> ${PN}-ext-libusb-${EXT_LIBUSB_COMMIT}.tar.gz
		https://github.com/shadps4-emu/ext-hwinfo/archive/${EXT_HWINFO_COMMIT}.tar.gz -> ${PN}-ext-hwinfo-${EXT_HWINFO_COMMIT}.tar.gz
		https://github.com/shadps4-emu/sirit/archive/${SIRIT_COMMIT}.tar.gz -> ${PN}-sirit-${SIRIT_COMMIT}.tar.gz
		https://android.googlesource.com/platform/external/aac/+archive/${FDK_AAC_COMMIT}.tar.gz -> ${PN}-aacedc-{$FDK_AAC_COMMIT}.tar.gz
	"
	S="${WORKDIR}/shadPS4-v.${PV}"
	KEYWORDS="~amd64"
fi

IUSE="tracing"

# mandatory bundled:
# fmt
# sirit
# imgui

DEPEND="
	media-libs/libsdl3
	media-libs/sdl3-mixer[vorbis]
	media-libs/VulkanMemoryAllocator
	dev-libs/boost
	dev-libs/crypto++
	>=media-video/ffmpeg-5.1.2
	virtual/zlib
	virtual/zlib
	media-gfx/renderdoc
	>=dev-util/glslang-1.3.296
	>=dev-cpp/robin-map-1.3.0
	>=dev-libs/xbyak-7.07.1
	dev-cpp/toml11
	>=dev-libs/xxhash-0.8.2
	>=dev-libs/pugixml-1.14
	media-libs/vulkan-layers
	media-sound/sndio
	virtual/jack
	media-libs/openal
	dev-libs/half
	>=dev-libs/zydis-5.0.0_alpha
	dev-cpp/tracy:=
	dev-libs/libusb
	dev-libs/cereal
	dev-libs/miniz
"

RDEPEND="
	${DEPEND}
"

BDEPEND="
	dev-cpp/nlohmann_json
	dev-util/spirv-headers
	>=dev-util/vulkan-headers-1.4.324
	>=dev-cpp/magic_enum-0.9.7
"

PATCHES=(
	"${FILESDIR}/${PN}-0.4.0-install.patch"
	"${FILESDIR}/${PN}-0.4.0-half.patch"
	"${FILESDIR}/${PN}-0.8.0-tracy.patch"
	"${FILESDIR}/${PN}-9999-deps.patch"
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
		rmdir "${S}/externals/ext-libusb"; mv "${WORKDIR}/ext-libusb-${EXT_LIBUSB_COMMIT}" "${S}/externals/ext-libusb" || die "Cannot move ext-libusb"
		rmdir "${S}/externals/hwinfo"; mv "${WORKDIR}/ext-hwinfo-${EXT_LIBUSB_COMMIT}" "${S}/externals/hwinfo" || die "Cannot move ext-hwinfo"
		rmdir "${S}/externals/sirit"; mv "${WORKDIR}/sirit-${SIRIT_COMMIT}" "${S}/externals/sirit" || die "Cannot move sirit"
		rmdir "${S}/externals/aacdec/fdk-aac"; mv "${WORKDIR}/sirit-${FDK_AAC_COMMIT}" "${S}/externals/aacdec/fdk-aac" || die "Cannot move fdk-aac"
	fi
}

src_prepare() {
	eapply_user

	sed -e "s|find_package(fmt|#|" -i CMakeLists.txt || die
	sed -e "s|find_package(glslang|find_package(glslang CONFIG)#|" -i CMakeLists.txt || die
	sed -e "s|nlohmann_json::nlohmann_json||" -i CMakeLists.txt || die
	sed -e "s|<miniz.h>|<miniz/miniz.h>|" -i src/video_core/cache_storage.cpp || die

	cmake_src_prepare
}

src_configure() {
	local mycmakeargs=(
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
