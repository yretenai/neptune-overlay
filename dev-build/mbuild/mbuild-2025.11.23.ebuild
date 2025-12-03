# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{9..14} python3_{13..14}t )

inherit distutils-r1

DESCRIPTION="python-based build system used for building XED"
HOMEPAGE="https://github.com/intelxed/mbuild"
SRC_URI="https://github.com/intelxed/mbuild/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

PATCHES=(
	"${FILESDIR}/${PN}-2024.11.04-fix-comment.patch"
)
