# Copyright 2022-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
PYTHON_COMPAT=( python3_{11..14} pypy3 pypy3_11 )

inherit distutils-r1

DESCRIPTION="A generator and build tool for Swift ebuilds."
HOMEPAGE="
	https://github.com/neptuwunium/pyswiftebuild/
"

if [[ "${PV}" == *9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/neptuwunium/pyswiftebuild.git"
else
	SRC_URI="https://github.com/neptuwunium/pyswiftebuild/archive/refs/tags/v${PV}.tar.gz -> ${PN}-${PV}.tar.gz"
	KEYWORDS="~amd64 ~arm64"
fi

LICENSE="EUPL-1.2"
SLOT="0"

RDEPEND="
	dev-python/license-expression[${PYTHON_USEDEP}]
"
