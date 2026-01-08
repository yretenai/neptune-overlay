# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake flag-o-matic toolchain-funcs

DESCRIPTION="Lossless Scaling Frame Generation on Linux via DXVK/Vulkan"
HOMEPAGE="https://github.com/PancakeTAS/lsfg-vk"
LICENSE="GPL-3.0"
SLOT="0"
IUSE="+gui"

if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/PancakeTAS/lsfg-vk"
else
	SRC_URI="
		https://github.com/PancakeTAS/lsfg-vk/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz
	"
	KEYWORDS="~amd64"
fi

VULKAN_PV="1.4.328"

BDEPEND="
	>=dev-util/spirv-headers-${VULKAN_PV}
	>=dev-util/vulkan-headers-${VULKAN_PV}
"
DEPEND="
	>=media-libs/vulkan-loader-${VULKAN_PV}
	gui? (
		dev-qt/qtbase:6
		dev-qt/qtquick3d:6[vulkan]
	)
"
RDEPEND="${DEPEND}"

src_configure() {
	tc-is-gcc && filter-lto # LTO with gcc causes segfaults at runtime

	local mycmakeargs=(
		-DLSFGVK_BUILD_VK_LAYER=ON
		-DLSFGVK_BUILD_UI=$(usex gui)
		-DLSFGVK_BUILD_CLI=ON
		-DLSFGVK_INSTALL_DEVELOP=ON
		-DLSFGVK_INSTALL_XDG_FILES=ON
	)

	cmake_src_configure
}
