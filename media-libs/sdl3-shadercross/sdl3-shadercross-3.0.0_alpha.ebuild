# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake flag-o-matic

DESCRIPTION="Image file loading library"
HOMEPAGE="https://www.libsdl.org/projects/SDL_image/"
COMMIT="816fe3628b9c6be934033cf0dc2a70467d163256"
SRC_URI="
	https://github.com/libsdl-org/SDL_shadercross/archive/${COMMIT}.zip
	
"
S="${WORKDIR}/SDL_shadercross-${COMMIT}"

LICENSE="ZLIB"
SLOT="0"
KEYWORDS="~amd64"
IUSE="test"
RESTRICT="!test? ( test )"

RDEPEND="
	>=media-libs/libsdl3-3.1.3[static-libs]
	media-libs/vulkan-loader
	app-emulation/vkd3d-native[spirv-tools]
	dev-util/spirv-cross
"
DEPEND="
	${RDEPEND}
"
BDEPEND="
	dev-util/patchelf
"

src_configure() {
	local mycmakeargs=(
		-DSDLSHADERCROSS_DXC=off # todo: package https://github.com/microsoft/DirectXShaderCompiler/ (?!)
		-DSDLSHADERCROSS_SPIRVCROSS_SHARED=off
		-DBUILD_SHARED_LIBS=off
		-DSDLSHADERCROSS_STATIC=on
		-DSDLSHADERCROSS_SHARED=off
	)

	cmake_src_configure
}

src_install() {
	newbin "${BUILD_DIR}/shadercross" shadercross3
	dodoc README.txt
}
