# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake git-r3

DESCRIPTION="Image file loading library"
HOMEPAGE="https://www.libsdl.org/projects/SDL_image/"
EGIT_SUBMODULES=()
EGIT_REPO_URI="https://github.com/libsdl-org/SDL_shadercross.git"
LICENSE="ZLIB"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE="test"
RESTRICT="!test? ( test )"

RDEPEND="
	>=media-libs/libsdl3-3.1.3
	media-libs/vulkan-loader
	app-emulation/vkd3d-native[spirv-tools]
	dev-util/spirv-cross
	dev-util/spirv-tools
"
DEPEND="
	${RDEPEND}
"
BDEPEND="
	dev-util/patchelf
	dev-util/vulkan-headers
	dev-util/spirv-headers
"

src_configure() {
	local mycmakeargs=(
		-DSDLSHADERCROSS_DXC=off # todo: package https://github.com/microsoft/DirectXShaderCompiler/ (?!)
		-DSDLSHADERCROSS_SPIRVCROSS_SHARED=off
		-DSDLSHADERCROSS_STATIC=on
		-DSDLSHADERCROSS_SHARED=on
	)

	cmake_src_configure
}

src_install() {
	dodoc README.txt
	cd "${BUILD_DIR}"
	dobin shadercross
	dolib.so libSDL3_shadercross.so libSDL3_shadercross.so.0 libSDL3_shadercross.so.0.0.0
	dolib.a libSDL3_shadercross.a
}
