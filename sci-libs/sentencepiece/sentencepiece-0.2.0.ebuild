# Copyright 2023-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_EXT=1
DISTUTILS_OPTIONAL=1
DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{8..13} )
inherit distutils-r1 git-r3 cmake

DESCRIPTION="Unsupervised text tokenizer for Neural Network-based text generation."
HOMEPAGE="https://github.com/google/sentencepiece"

EGIT_REPO_URI="https://github.com/google/sentencepiece.git"
ABSEIL_EGIT_REPO_URI="https://github.com/abseil/abseil-cpp.git"
ABSEIL_EGIT_COMMIT="20240116.2"

if [[ ${PV} != *9999* ]]; then
	EGIT_COMMIT="v${PV}"
	KEYWORDS="~amd64"
fi

LICENSE="Apache-2.0"
SLOT="0"
IUSE="python"

DEPEND+="
	python? (
		${PYTHON_DEPS}
	)
"

RDEPEND="
	${DEPEND}
"

BDEPEND+="
	>=dev-build/cmake-3.8.0
	virtual/pkgconfig
	python? (
		${PYTHON_DEPS}
	)
"

REQUIRED_USE="
	python? ( ${PYTHON_REQUIRED_USE} )
"

PATCHES=(
	"${FILESDIR}/${P}-remove-fetchcontent.patch"
	"${FILESDIR}/${P}-pass-flags.patch"
	"${FILESDIR}/${P}-no-strip.patch"
)

pkg_setup() {
	if use python ; then
		python_setup
	fi
}

src_prepare() {
	cmake_src_prepare
	if use python ; then
		cd "${S}/python" || die
		distutils-r1_src_prepare
	fi
}

src_unpack() {
	git-r3_fetch "${ABSEIL_EGIT_REPO_URI}" "${ABSEIL_EGIT_COMMIT}"
	git-r3_checkout "${ABSEIL_EGIT_REPO_URI}" "${S}/third_party/abseil-cpp"
	git-r3_src_unpack
}

src_configure() {
	local mycmakeargs=(
		-DSPM_PROTOBUF_PROVIDER="internal" # "package" is outdated -> needs 26.1
		-DSPM_ABSL_PROVIDER="module" # "package" is oudated -> needs >= 20240000
		-DSPM_ENABLE_SHARED=OFF # will fail as long as absl is outdated
		-DBUILD_SHARED_LIBS=OFF # ""
	)
	
	cmake_src_configure

	if use python ; then
		cd "${S}/python" || die
		distutils-r1_src_configure
	fi
}

src_compile() {
	cmake_src_compile
	if use python ; then
		cd "${S}/python" || die
		distutils-r1_src_compile
	fi
}

src_install() {
	cmake_src_install

	if use python ; then
		cd "${S}/python" || die
		distutils-r1_src_install
	fi
}
