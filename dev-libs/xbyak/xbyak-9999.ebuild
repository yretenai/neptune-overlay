# Copyright 2023-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

DESCRIPTION="JIT assembler for x86(IA-32)/x64(AMD64, x86-64)"
HOMEPAGE="https://github.com/herumi/xbyak"
LICENSE="BSD"
SLOT="0"

if [[ ${PV} == *9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/herumi/xbyak.git"
else
	SRC_URI="
		https://github.com/herumi/xbyak/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz
	"
	KEYWORDS="~amd64"
fi
