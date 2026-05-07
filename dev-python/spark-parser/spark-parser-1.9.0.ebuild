# Copyright 2023-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{11..14} python3_{13..14}t )
DISTUTILS_USE_PEP517=setuptools
inherit distutils-r1

DESCRIPTION="An Earley-Algorithm Context-free grammar Parser Toolkit"
HOMEPAGE="https://github.com/rocky/python-spark"
LICENSE="MIT"
SLOT="0"

if [[ "${PV}" == *9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/rocky/python-spark.git"
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

