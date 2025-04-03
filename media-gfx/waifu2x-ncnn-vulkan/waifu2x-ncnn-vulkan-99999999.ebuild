# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

DESCRIPTION="waifu2x converter using ncnn and vulkan"
HOMEPAGE="https://github.com/nihui/waifu2x-ncnn-vulkan"
LICENSE="MIT"
SLOT="0"

if [[ ${PV} == *99999999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/nihui/waifu2x-ncnn-vulkan.git"
	EGIT_SUBMODULES=( '-*' 'src/ncnn' )
else
	NCNN_COMMIT=b4ba207c18d3103d6df890c0e3a97b469b196b26
	GLSLANG_COMMIT=86ff4bca1ddc7e2262f119c16e7228d0efb67610
	SRC_URI="
		https://github.com/nihui/waifu2x-ncnn-vulkan/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz
		https://github.com/Tencent/ncnn/archive/${NCNN_COMMIT}.tar.gz -> ${PN}-ncnn-${NCNN_COMMIT}.tar.gz
		https://github.com/KhronosGroup/glslang/archive/${GLSLANG_COMMIT}.tar.gz -> ${PN}-glslang-${GLSLANG_COMMIT}.tar.gz
	"
	KEYWORDS="~amd64"
fi

RDEPEND="
	media-libs/libwebp:=
	media-libs/vulkan-loader
"
DEPEND="
	${RDEPEND}
	dev-util/vulkan-headers
"
BDEPEND="
	dev-util/glslang:=
"

PATCHES=(
	"${FILESDIR}"/${PN}-20210521-no-lto.patch
)

src_unpack() {
	default

	if [[ ${PV} != *99999999* ]]; then
		rmdir "${S}/src/ncnn" || die
		mv "${WORKDIR}/ncnn-${NCNN_COMMIT}" "${S}/src/ncnn" || die

		rmdir "${S}/src/ncnn/glslang" || die
		mv "${WORKDIR}/glslang-${GLSLANG_COMMIT}" "${S}/src/ncnn/glslang" || die
	fi
}

src_prepare() {
	CMAKE_USE_DIR=${S}/src
	cmake_src_prepare

	# Update all paths to match installation for models.
	sed "/PATHSTR\|model path/s|models-|${EPREFIX}/usr/share/${PN}/models-|" \
		-i src/main.cpp || die
}

src_configure() {
	local mycmakeargs=(
		-DBUILD_SHARED_LIBS=NO
		-DUSE_SYSTEM_NCNN=NO
		-DUSE_SYSTEM_WEBP=YES
	)

	cmake_src_configure
}

src_install() {
	dobin "${BUILD_DIR}"/waifu2x-ncnn-vulkan

	insinto /usr/share/${PN}
	doins -r models/.

	einstalldocs
}
