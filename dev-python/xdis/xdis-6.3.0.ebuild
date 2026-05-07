# Copyright 2023-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{11..14} )
DISTUTILS_USE_PEP517=setuptools
inherit distutils-r1

DESCRIPTION=" Python cross-version bytecode library and disassembler"
HOMEPAGE="https://github.com/rocky/python-xdis"
LICENSE="MIT"
SLOT="0"

if [[ "${PV}" == *9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/rocky/python-xdis.git"
else
	inherit pypi
	KEYWORDS="~amd64 ~arm64"
fi

IUSE="test"

RDEPEND="
	${PYTHON_DEPS}
"

DEPEND="
	${RDEPEND}
"

RESTRICT="test"

