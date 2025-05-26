# Copyright 2023-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{11..14} python3_{13..14}t )
DISTUTILS_USE_PEP517=setuptools
inherit distutils-r1

DESCRIPTION="A modern and customizable python UI-library based on Tkinter"
HOMEPAGE="https://github.com/TomSchimansky/CustomTkinter"
LICENSE="MIT"
SLOT="0"

if [[ ${PV} == *9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/zyantific/zycore-c.git"
else
	inherit pypi
	KEYWORDS="~amd64 ~arm64"
fi

DEPEND+="
	$(python_gen_cond_dep '
		dev-python/darkdetect[${PYTHON_USEDEP}]
		dev-python/typing-extensions[${PYTHON_USEDEP}]
		dev-python/packaging[${PYTHON_USEDEP}]
	')
"

RDEPEND="
	${DEPEND}
"

RESTRICT="test"
