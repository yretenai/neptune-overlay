# Copyright 2023-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit shell-completion flag-o-matic

DESCRIPTION="mommy's here to support you ❤️"
HOMEPAGE="https://github.com/FWDekker/mommy"
LICENSE="Unlicense"
SLOT="0"

if [[ ${PV} == *9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/FWDekker/mommy.git"
else
	SRC_URI="https://github.com/FWDekker/mommy/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~arm64"
fi

IUSE="man"
RESTRICT="test"

src_compile() {
	strip-flags
	emake --jobs 1 build/gentoo
}

src_install() {
	dobin build/bin/mommy
	if use man; then
		doman build/man/man1/mommy.1
	fi
	dofishcomp build/completions/fish/mommy.fish
	dozshcomp build/completions/fish/mommy.fish
}
