# Copyright 2023-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{8..13} )
DISTUTILS_USE_PEP517=setuptools
inherit distutils-r1 git-r3

DESCRIPTION="A modern and customizable python UI-library based on Tkinter"
HOMEPAGE="https://github.com/TomSchimansky/CustomTkinter"

EGIT_REPO_URI="https://github.com/TomSchimansky/CustomTkinter.git"
if [[ ${PV} != *9999* ]]; then
	EGIT_COMMIT="v${PV}"
	KEYWORDS="~amd64"
fi

LICENSE="MIT"
SLOT="0"

DEPEND+="
	dev-python/darkdetect[${PYTHON_USEDEP}]
	dev-python/typing-extensions[${PYTHON_USEDEP}]
	dev-python/packaging[${PYTHON_USEDEP}]
"

RDEPEND="
	${DEPEND}
"

RESTRICT="test"
