# Copyright 2023-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{11..13} )
DISTUTILS_USE_PEP517=setuptools
inherit distutils-r1

DESCRIPTION="Simple interface to edit audio file metadata."
HOMEPAGE="https://github.com/KristoforMaynard/music-tag"
LICENSE="MIT"
SLOT="0"

if [[ "${PV}" == *9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/KristoforMaynard/music-tag/${PN}.git"
else
	SRC_URI="https://github.com/KristoforMaynard/music-tag/archive/refs/tags/${PV}.tar.gz -> ${PN}-${PV}.tar.gz"
	KEYWORDS="~amd64"
fi

IUSE="test"
RESTRICT="!test? ( test )"

RDEPEND="
	${PYTHON_DEPS}
	$(python_gen_cond_dep '
		media-libs/mutagen[${PYTHON_USEDEP}]
		dev-python/pillow[${PYTHON_USEDEP}]
	')
"

DEPEND="
	${RDEPEND}
"
