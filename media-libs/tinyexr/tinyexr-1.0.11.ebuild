# Copyright 2023-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit meson

DESCRIPTION="Tiny OpenEXR image loader/saver library"
HOMEPAGE="https://github.com/syoyo/tinyexr"

TINYDNG_PV="0534fd3cba56f2f00428f78ec6905b7595df71ec"

SRC_URI="
	https://github.com/syoyo/tinyexr/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz
	https://github.com/syoyo/tinydng/archive/${TINYDNG_PV}.tar.gz -> tinydng-${TINYDNG_PV}.tar.gz
"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

IUSE="+miniz zlib zlib-ng nanozlib stb examples gl gtk exrview openmp threads zfp +piz cpu_flags_x86_f16c"

REQUIRED_USE="
	^^ ( miniz zlib zlib-ng nanozlib stb )
	exrview? ( gl )
	gl? ( examples )
	gtk? ( exrview )
"

DEPEND="
	miniz? ( dev-libs/miniz )
	zlib? ( sys-libs/zlib )
	zlib-ng? ( sys-libs/zlib-ng )
	stb? ( dev-libs/stb:= )
	zfp? (
		dev-libs/zfp:=
	)
	examples? (
		dev-libs/cxxopts:=
		dev-libs/stb:=
		dev-libs/miniz
	)
	gl? (
		virtual/opengl
		media-libs/glu
		media-libs/freeglut
	)
	exrview? (
		media-libs/glew
		x11-libs/libX11
	)
	gtk? (
		x11-libs/gtk+:3
	)
	openmp? (
		llvm-runtimes/openmp
	)
"
RDEPEND="${DEPEND}"

PATCHES=(
	"${FILESDIR}/${PN}-1.0.10-main.patch"
	"${FILESDIR}/${PN}-1.0.10-zlibng.patch"
	"${FILESDIR}/${PN}-1.0.11-examples.patch"
)

src_prepare() {
	cp "${FILESDIR}/${PN}-1.0.10-meson.build" "${S}/meson.build" || die
	cp "${FILESDIR}/${PN}-1.0.10-meson.options" "${S}/meson.options" || die
	cp "${WORKDIR}/tinydng-${TINYDNG_PV}/tiny_dng_writer.h" "examples/exr2fptiff/tiny_dng_writer.h" || die
	sed -s "s/__PV__/${PV}/" -i "${S}/meson.build" || die
	sed -s "s/register int/int/" -i "${S}/examples/deepview/trackball.cc" || die

	default
}

src_configure() {
	local zlib_flavor="error"
	if use miniz; then
		zlib_flavor="miniz"
	elif use nanozlib; then
		zlib_flavor="nanozlib"
	elif use stb; then
		zlib_flavor="stb"
	elif use zlib-ng; then
		zlib_flavor="zlib-ng"
	elif use zlib; then
		zlib_flavor="zlib"
	fi

	local emesonargs=(
		$(meson_feature cpu_flags_x86_f16c with_fp16)
		$(meson_feature openmp with_openmp)
		$(meson_feature threads with_threads)
		$(meson_feature zfp with_zfp)
		$(meson_feature piz with_piz)
		$(meson_use examples build_examples)
		$(meson_use gl build_gl_examples)
		$(meson_use exrview build_exrview)
		-Dzlib_impl="${zlib_flavor}"
	)

	meson_src_configure
}
