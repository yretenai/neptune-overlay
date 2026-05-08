# Copyright 2023-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{11..14} )
DISTUTILS_USE_PEP517=setuptools
inherit distutils-r1

DESCRIPTION="A cross-version Python bytecode decompiler"
HOMEPAGE="https://github.com/rocky/python-uncompyle6"
LICENSE="MIT"
SLOT="0"

if [[ "${PV}" == *9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/rocky/python-uncompyle6.git"
else
	inherit pypi
	KEYWORDS="~amd64 ~arm64"
fi

IUSE="test"

RDEPEND="
	${PYTHON_DEPS}
	$(python_gen_cond_dep '
		dev-python/click[${PYTHON_USEDEP}]
		>=dev-python/xdis-6.2.0[${PYTHON_USEDEP}]
		dev-python/spark-parser[${PYTHON_USEDEP}]
		dev-python/configobj[${PYTHON_USEDEP}]
	')
"

DEPEND="
	${RDEPEND}
"

RESTRICT="test"

