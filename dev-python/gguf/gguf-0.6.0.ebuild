# Copyright 2023-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{8..13} )
DISTUTILS_USE_PEP517=poetry
inherit distutils-r1

DESCRIPTION="IO library for the GGUF (GGML Universal File) format."
HOMEPAGE="https://pypi.org/project/gguf"

SRC_URI="
	https://files.pythonhosted.org/packages/f3/ad/535c8afa732ee70ff4643d34655676db689fcf9b673470adb9faeac36937/${P}.tar.gz
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="bindist mirror"

DEPEND+="
	dev-python/numpy[${PYTHON_USEDEP}]
"

RDEPEND="
	${DEPEND}
"

PATCHES=(
	"${FILESDIR}/${P}-move-scripts.patch"
)

src_prepare() {
	distutils-r1_src_prepare
	mv scripts gguf/scripts
}
