# Copyright 2020-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{11..13} python3_13t )
DISTUTILS_SINGLE_IMPL=1
inherit distutils-r1

DESCRIPTION="A free and open-source replacement for the Epic Games Launcher"
HOMEPAGE="
	https://github.com/Heroic-Games-Launcher/legendary.git
"

MY_PN=legendary

if [[ ${PV} == *9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/Heroic-Games-Launcher/${MY_PN}.git"
else
	SRC_URI="https://github.com/Heroic-Games-Launcher/${MY_PN}/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64"
	S="${WORKDIR}/${MY_PN}-${PV}"
fi

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	$(python_gen_cond_dep '
		dev-python/filelock[${PYTHON_USEDEP}]
		<dev-python/requests-3.0[${PYTHON_USEDEP}]
	')
	!!games-util/legendary
"
DEPEND="${RDEPEND}"

PATCHES=(
	"${FILESDIR}/legendary-0.20.34-PR701.patch"
)
