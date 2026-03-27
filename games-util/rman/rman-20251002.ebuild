# Copyright 2023-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

DESCRIPTION="Set of CLI tools for Riot Manifest and Bundle files"
HOMEPAGE="https://github.com/moonshadow565/rman"

LICENSE="MIT"
SLOT="0"

if [[ 20240406 == *99999999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/moonshadow565/rman.git"
else
	SRC_URI="https://github.com/moonshadow565/rman/archive/refs/tags/2025-10-02-c1b8a9e.tar.gz -> ${P}.tar.gz"
	S="${WORKDIR}/${PN}-2025-10-02-c1b8a9e"
	KEYWORDS="~amd64 ~arm64"
fi

RESTRICT="mirror"

DEPEND="
	net-misc/curl
	app-arch/zstd[static-libs]
	dev-cpp/argparse
	dev-cpp/digestpp
	dev-cpp/json_struct
	dev-libs/libfmt:=
	dev-libs/miniz
	dev-libs/blake3
	sys-fs/fuse:=
"

RDEPEND="
	${DEPEND}
"

PATCHES="
	${FILESDIR}/${P}-deps.patch
"
