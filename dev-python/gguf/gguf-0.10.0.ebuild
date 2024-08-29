# Copyright 2023-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{8..13} )
DISTUTILS_USE_PEP517=poetry
inherit distutils-r1

DESCRIPTION="IO library for the GGUF (GGML Universal File) format."
HOMEPAGE="https://pypi.org/project/gguf"

SRC_URI="
	https://files.pythonhosted.org/packages/0e/c4/a159e9f842b0e8b8495b2689af6cf3426f002cf01207ca8134db82fc4088/${P}.tar.gz
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="bindist mirror"

DEPEND+="
	>=dev-python/numpy-1.17[${PYTHON_USEDEP}]
	>=dev-python/tqdm-4.27[${PYTHON_USEDEP}]
	>=dev-python/pyyaml-5.1[${PYTHON_USEDEP}]
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
