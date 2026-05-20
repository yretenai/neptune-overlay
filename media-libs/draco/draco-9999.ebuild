# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# Notes:
# - We don't add USE flags for ccache and distcc, because the library builds
#   in minimal time (a few seconds)

EAPI=8

inherit cmake edo

DESCRIPTION="Library for compressing and decompressing 3D geometric objects"
HOMEPAGE="https://google.github.io/draco/ https://github.com/google/draco"

if [[ ${PV} =~ 9999 ]] ; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/google/draco.git"
	EGIT_BRANCH="main"
	EGIT_SUBMODULES=(
		'*'
		'-third_party/eigen'
	)
else
	GTEST_PV="1.17.0"
	FILESYSTEM_PV="a07ddedeae722c09e819895e1c31ae500e9abad6"
	TINYGLTF_PV="a11f6e19399f6af67d7c57909e8ce99d20beb369"
	SRC_URI="
		https://github.com/google/draco/archive/${PV}.tar.gz -> ${P}.tar.gz
		https://github.com/google/googletest/archive/refs/tags/v${GTEST_PV}.tar.gz
			-> gtest-${GTEST_PV}.tar.gz
		https://github.com/gulrak/filesystem/archive/${FILESYSTEM_PV}.tar.gz -> ${P}-filesystem.tar.gz
		https://github.com/syoyo/tinygltf/archive/${TINYGLTF_PV}.zip -> ${P}}-tinygltf.tar.gz
	"
	KEYWORDS="~amd64 ~x86 ~arm64"
fi

LICENSE="Apache-2.0"

SLOT="0/9"

IUSE="+compat debug gltf transcoder test"

RDEPEND="
	dev-cpp/eigen:=
"

DEPEND="${RDEPEND}
	virtual/pkgconfig
"
# Testing needs the dev-cpp/gtest source code to be available in a
# side-directory of the draco sources, therefore we restrict test for now.
RESTRICT="!test? ( test ) mirror"
DOCS=( AUTHORS CONTRIBUTING.md README.md )

PATCHES=(
	"${FILESDIR}/draco-fix-include-cstdint.patch"
	"${FILESDIR}/${PN}-9999-gltf-cstdint.patch"
	"${FILESDIR}/${PN}-9999-gtest-cstdint.patch"
	"${FILESDIR}/${PN}-9999-fix-reader-file-collision.patch"
	"${FILESDIR}/${PN}-9999-deduplication.patch"
)

src_unpack() {
	if [[ ${PV} =~ 9999 ]] ; then
		git-r3_fetch
		git-r3_checkout
	else
		default

		rmdir "${S}/third_party/googletest" || die
		mv "${WORKDIR}/googletest-${GTEST_PV}" "${S}/third_party/googletest" || die

		rmdir "${S}/third_party/filesystem" || die
		mv "${WORKDIR}/filesystem-${FILESYSTEM_PV}" "${S}/third_party/filesystem" || die

		rmdir "${S}/third_party/tinygltf" || die
		mv "${WORKDIR}/tinygltf-${TINYGLTF_PV}" "${S}/third_party/tinygltf" || die
	fi
}

src_configure() {
	: "${CMAKE_BUILD_TYPE:=$(usex debug 'Debug' 'Release')}"
	EMSCRIPTEN=
	local mycmakeargs=(
		-DCMAKE_CXX_STANDARD=17
		-DDRACO_EIGEN_PATH="${EPREFIX}/usr/include/eigen3"
		-DDRACO_ANIMATION_ENCODING="no"
		-DDRACO_WASM="no"
		-DDRACO_GLTF_BITSTREAM="$(usex gltf)"
		# -DDRACO_MAYA_PLUGIN="no" # default
		-DBUILD_SHARED_LIBS="yes"
		# -DDRACO_UNITY_PLUGIN="no" # default (FIXME?)
		-DBUILD_USD_PLUGIN="no"
		-DDRACO_BACKWARDS_COMPATIBILITY="$(usex compat)"
		-DDRACO_TRANSCODER_SUPPORTED="$(usex transcoder)"
		-DENABLE_DECODER_ATTRIBUTE_DEDUPLICATION="no"
		-DENABLE_EXTRA_SPEED="no" # don't use -O3 optimization
		# -DENABLE_EXTRA_WARNINGS="no"
		-DDRACO_MESH_COMPRESSION="yes" # default
		-DDRACO_POINT_CLOUD_COMPRESSION="yes" # default
		-DDRACO_PREDICTIVE_EDGEBREAKER="yes" # default
		-DDRACO_STANDARD_EDGEBREAKER="yes" # default
		-DDRACO_DECODER_ATTRIBUTE_DEDUPLICATION="yes"
		-DDRACO_TESTS="$(usex test)"
		-DDRACO_VERBOSE="$(usex debug 3 0)"
		# -DENABLE_WERROR="no" # default
		# -DENABLE_WEXTRA="no" # add extra compiler warnings
	)

	cmake_src_configure
}

src_test() {
	cd "${BUILD_DIR}" || die
	edo "${BUILD_DIR}/draco_tests" --gtest_brief=1
	edo "${BUILD_DIR}/draco_factory_tests" --gtest_brief=1
}
