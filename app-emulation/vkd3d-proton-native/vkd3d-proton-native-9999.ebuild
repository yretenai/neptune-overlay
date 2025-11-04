# Copyright 2022-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit flag-o-matic meson

if [[ ${PV} == *9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/HansKristian-Work/vkd3d-proton.git"
	EGIT_SUBMODULES=(
		# uses hacks / recent features and easily breaks, keep bundled headers
		# (also cross-compiled and -I/usr/include is troublesome)
		khronos/{SPIRV,Vulkan}-Headers
		subprojects/dxil-spirv
		subprojects/dxil-spirv/third_party/spirv-headers # skip cross/tools
	)
else
	HASH_VKD3D= # match tag on bumps
	HASH_DXIL=
	HASH_SPIRV=
	HASH_SPIRV_DXIL=
	HASH_VULKAN=
	SRC_URI="
		https://github.com/HansKristian-Work/vkd3d-proton/archive/refs/tags/v${PV}.tar.gz
			-> ${P}.tar.gz
		https://github.com/HansKristian-Work/dxil-spirv/archive/${HASH_DXIL}.tar.gz
			-> dxil-spirv-${HASH_DXIL}.tar.gz
		https://github.com/KhronosGroup/SPIRV-Headers/archive/${HASH_SPIRV}.tar.gz
			-> spirv-headers-${HASH_SPIRV}.tar.gz
		https://github.com/KhronosGroup/SPIRV-Headers/archive/${HASH_SPIRV_DXIL}.tar.gz
			-> spirv-headers-${HASH_SPIRV_DXIL}.tar.gz
		https://github.com/KhronosGroup/Vulkan-Headers/archive/${HASH_VULKAN}.tar.gz
			-> vulkan-headers-${HASH_VULKAN}.tar.gz
	"
	S="${WORKDIR}/vkd3d-proton-${PV}"
	KEYWORDS="-* ~amd64 ~x86"
fi

DESCRIPTION="Fork of VKD3D, development branches for Proton's Direct3D 12 implementation"
HOMEPAGE="https://github.com/HansKristian-Work/vkd3d-proton/"

LICENSE="LGPL-2.1+ Apache-2.0 MIT"
SLOT="0"
IUSE="debug extras profiling descriptor_qa renderdoc"

DEPEND="
	extras? (
		x11-libs/libxcb
		x11-libs/xcb-util-keysyms
	)
"

BDEPEND="
	dev-util/glslang
"

PATCHES=(
	"${FILESDIR}/${PN}-2.14.1-demos.patch"
)

src_prepare() {
	if [[ ${PV} != *9999* ]]; then
		rmdir khronos/{SPIRV,Vulkan}-Headers subprojects/dxil-spirv || die
		mv ../dxil-spirv-${HASH_DXIL} subprojects/dxil-spirv || die
		mv ../SPIRV-Headers-${HASH_SPIRV} khronos/SPIRV-Headers || die
		mv ../Vulkan-Headers-${HASH_VULKAN} khronos/Vulkan-Headers || die

		rmdir subprojects/dxil-spirv/third_party/spirv-headers || die
		# dxil and vkd3d's spirv headers sometime mismatch and are incompatible
		if [[ ${HASH_SPIRV} == "${HASH_SPIRV_DXIL}" ]]; then
			ln -s ../../../khronos/SPIRV-Headers \
				subprojects/dxil-spirv/third_party/spirv-headers || die
		else
			mv ../SPIRV-Headers-${HASH_SPIRV_DXIL} \
				subprojects/dxil-spirv/third_party/spirv-headers || die
		fi
	fi

	default

	if [[ ${PV} != *9999* ]]; then
		# without .git, meson sets vkd3d_build as 0x${PV} leading to failure
		sed -i "s/@VCS_TAG@/${HASH_VKD3D::15}/" vkd3d_build.h.in || die
		sed -i "s/@VCS_TAG@/${HASH_VKD3D::7}/" vkd3d_version.h.in || die
	fi
}

src_configure() {
	# random segfaults been reported with LTO in some games, filter as
	# a safety (note that optimizing this further won't really help
	# performance, GPU does the actual work)
	filter-lto

	local emesonargs=(
		$(meson_use {,enable_}extras)
		$(meson_use {,enable_}profiling)
		$(meson_use {,enable_}renderdoc)
		$(meson_use {,enable_}descriptor_qa)
		$(meson_use debug enable_trace)
		-Denable_tests=false # needs wine/vulkan and is intended for manual use
	)

	meson_src_configure
}
