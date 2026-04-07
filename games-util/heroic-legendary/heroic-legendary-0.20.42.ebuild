# Copyright 2020-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_SINGLE_IMPL=1
inherit distutils-r1

DESCRIPTION="A free and open-source replacement for the Epic Games Launcher"
HOMEPAGE="
	https://github.com/Heroic-Games-Launcher/legendary.git
"

if [[ ${PV} == *9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/Heroic-Games-Launcher/legendary.git"
else
	SRC_URI="https://github.com/Heroic-Games-Launcher/legendary/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~arm64"
	S="${WORKDIR}/legendary-${PV}"
fi

LICENSE="GPL-3+"
SLOT="0"

RDEPEND="
	$(python_gen_cond_dep '
		dev-python/filelock[${PYTHON_USEDEP}]
		dev-python/requests[${PYTHON_USEDEP}]
		dev-python/requests-futures[${PYTHON_USEDEP}]
	')
	!!games-util/legendary
"
DEPEND="${RDEPEND}"

PATCHES=(
	"${FILESDIR}/legendary-0.20.34-PR701.patch"
)
