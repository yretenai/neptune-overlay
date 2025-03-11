# Copyright 2022-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{10..13} )
inherit flag-o-matic meson python-any-r1

if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/doitsujin/dxvk.git"
	S="${WORKDIR}/dxvk"
else
	HASH_SPIRV=8b246ff75c6615ba4532fe4fde20f1be090c3764
	HASH_VULKAN=46dc0f6e514f5730784bb2cac2a7c731636839e8
	HASH_DISPLAYINFO=275e6459c7ab1ddd4b125f28d0440716e4888078
	HASH_HEADERS=9df86f2341616ef1888ae59919feaa6d4fad693d
	SRC_URI="
		https://github.com/doitsujin/dxvk/archive/refs/tags/v${PV}.tar.gz
			-> ${P}.tar.gz
		https://github.com/KhronosGroup/SPIRV-Headers/archive/${HASH_SPIRV}.tar.gz
			-> spirv-headers-${HASH_SPIRV}.tar.gz
		https://github.com/KhronosGroup/Vulkan-Headers/archive/${HASH_VULKAN}.tar.gz
			-> vulkan-headers-${HASH_VULKAN}.tar.gz
		https://github.com/misyltoad/mingw-directx-headers/archive/${HASH_HEADERS}.tar.gz
			-> mingw-directx-headers-${HASH_HEADERS}.tar.gz
		https://gitlab.freedesktop.org/frog/libdisplay-info/-/archive/${HASH_DISPLAYINFO}/libdisplay-info-${HASH_DISPLAYINFO}.tar.bz2
	"
	S="${WORKDIR}/dxvk-${PV}"
	KEYWORDS="-* amd64 x86"
fi

DESCRIPTION="Vulkan-based implementation of D3D9, D3D10 and D3D11 for Linux / Wine"
HOMEPAGE="https://github.com/doitsujin/dxvk/"

LICENSE="ZLIB Apache-2.0 MIT"
SLOT="0"
IUSE="+d3d8 +d3d9 +d3d10 +d3d11 +dxgi"
REQUIRED_USE="
	|| ( d3d8 d3d9 d3d10 d3d11 dxgi )
	d3d8? ( d3d9 )
	d3d10? ( d3d11 )
	d3d11? ( dxgi )
"

BDEPEND="
	${PYTHON_DEPS}
	dev-util/glslang
"

src_prepare() {
	if [[ ${PV} != 9999 ]]; then
		rmdir include/{spirv,vulkan} include/native/directx subprojects/libdisplay-info || die
		mv ../SPIRV-Headers-${HASH_SPIRV} include/spirv || die
		mv ../Vulkan-Headers-${HASH_VULKAN} include/vulkan || die
		mv ../mingw-directx-headers-${HASH_HEADERS} include/native/directx || die
		mv ../libdisplay-info-${HASH_DISPLAYINFO} subprojects/libdisplay-info || die
	fi

	default
}

src_configure() {
	# random segfaults been reported with LTO in some games, filter as
	# a safety (note that optimizing this further won't really help
	# performance, GPU does the actual work)
	filter-lto

	local emesonargs=(
		$(meson_use {,enable_}d3d8)
		$(meson_use {,enable_}d3d9)
		$(meson_use {,enable_}d3d10)
		$(meson_use {,enable_}d3d11)
		$(meson_use {,enable_}dxgi)
	)

	meson_src_configure
}

src_install() {
	dodoc README.md dxvk.conf

	meson_src_install
}
