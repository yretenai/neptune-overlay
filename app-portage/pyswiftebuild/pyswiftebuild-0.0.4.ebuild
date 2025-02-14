# Copyright 2022-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
PYTHON_COMPAT=( python3_{11..13} pypy3 )

inherit distutils-r1 pypi

DESCRIPTION="A generator and build tool for Swift ebuilds."
HOMEPAGE="
	https://github.com/yretenai/pyswiftebuild/
"

SRC_URI="
	https://github.com/yretenai/pyswiftebuild/archive/refs/tags/v${PV}.tar.gz -> ${PN}-${PV}.tar.gz
"

LICENSE="EUPL-1.2"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	dev-python/license-expression[${PYTHON_USEDEP}]
"
