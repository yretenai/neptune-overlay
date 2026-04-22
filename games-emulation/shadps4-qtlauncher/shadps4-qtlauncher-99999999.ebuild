# Copyright 2023-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

DESCRIPTION="Qt based launcher for shadPS4"
HOMEPAGE="https://github.com/shadps4-emu/shadps4-qtlauncher"
LICENSE="GPL-2"
SLOT="0"

if [[ ${PV} == *99999999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/shadps4-emu/shadps4-qtlauncher.git"
	EGIT_SUBMODULES=(
		"externals/fmt"
		"externals/spdlog"
	)
else
	COMMIT=
	EXT_FMT_COMMIT=
	SPDLOG_COMMIT=

	SRC_URI="
		https://github.com/shadps4-emu/shadps4-qtlauncher/archive/${COMMIT}.tar.gz -> ${P}.tar.gz
		https://github.com/shadps4-emu/ext-fmt/archive/${EXT_FMT_COMMIT}.tar.gz -> ${PN}-ext-fmt-${EXT_FMT_COMMIT}.tar.gz
			https://github.com/gabime/spdlog/archive/${SPDLOG_COMMIT}.tar.gz -> ${PN}-spdlog-${SPDLOG_COMMIT}.tar.gz
	"
	S="${WORKDIR}/shadps4-qtlauncher-${COMMIT}"
	KEYWORDS="~amd64"
fi

# missing dependencies:
# fmt 10.2.0 or newer is required
# sdl3

DEPEND="
	media-libs/libsdl3
	dev-util/volk
	dev-cpp/toml11
	>=dev-libs/pugixml-1.14
	dev-qt/qtbase:6[widgets,vulkan,concurrent,network]
	dev-qt/qtmultimedia:6[ffmpeg,vulkan]
	dev-qt/qttools:6[linguist]
"

RDEPEND="
	${DEPEND}
"

BDEPEND="
	dev-cpp/nlohmann_json
	>=dev-util/vulkan-headers-1.4.324
"

PATCHES=(
	"${FILESDIR}/${PN}-20251102-compat.patch"
	"${FILESDIR}/${PN}-20251102-system-install.patch"
)

src_unpack() {
	default

	if [[ "${PV}" == *9999* ]]; then
		git-r3_src_unpack
	else
		rmdir "${S}/externals/fmt"; mv "${WORKDIR}/ext-fmt-${EXT_FMT_COMMIT}" "${S}/externals/fmt" || die "Cannot move ext-fmt"
		rmdir "${S}/externals/spdlog"; mv "${WORKDIR}/spdlog-${SPDLOG_COMMIT}" "${S}/externals/spdlog" || die "Cannot move spdlog"
	fi
}

src_prepare() {
	default
	cmake_prepare

	sed -e "s|add_subdirectory(volk)||g" -i externals/CMakeLists.txt || die
	sed -e "s|add_subdirectory(json)||g" -i externals/CMakeLists.txt || die
	sed -e "s|volk_headers||g" -i CMakeLists.txt || die
	sed -e "s|nlohmann_json::nlohmann_json||g" -i CMakeLists.txt || die
}

src_configure() {
	local mycmakeargs=(
		-D ENABLE_UPDATER=OFF
	)

	cmake_src_configure
}
