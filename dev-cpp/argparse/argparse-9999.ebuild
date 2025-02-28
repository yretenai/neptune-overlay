# Copyright 2023-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

DESCRIPTION="Argument Parser for Modern C++"
HOMEPAGE="https://github.com/p-ranav/argparse"

LICENSE="MIT"
SLOT="0"

if [[ ${PV} == *9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/p-ranav/argparse.git"
else
	SRC_URI="https://github.com/p-ranav/argparse/archive/refs/tags/v${PV}.tar.gz -> ${PN}-${PV}.tar.gz"
	KEYWORDS="~amd64"
fi
RESTRICT="mirror"
