# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

DESCRIPTION="TOML for Modern C++"
HOMEPAGE="https://github.com/ToruNiina/toml11"

if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/ToruNiina/${PN}.git"
	KEYWORDS=""
else
	SRC_URI="https://github.com/ToruNiina/${PN}/archive/refs/tags/v${PV}.tar.gz -> ${P}.gh.tar.gz"
	KEYWORDS="amd64 ~arm"
fi

LICENSE="MIT"
SLOT="0"

DEPEND=""
RDEPEND=""
BDEPEND=""
