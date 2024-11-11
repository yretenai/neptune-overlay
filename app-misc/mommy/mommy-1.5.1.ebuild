# Copyright 2023-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit git-r3 shell-completion flag-o-matic

DESCRIPTION="mommy's here to support you ❤️"
HOMEPAGE="https://github.com/FWDekker/mommy"
LICENSE="Unlicense"
SLOT="0"

EGIT_REPO_URI="https://github.com/FWDekker/mommy.git"
if [[ ${PV} != *9999* ]]; then
	EGIT_COMMIT="v${PV}"
	KEYWORDS="~amd64"
fi

IUSE="test man"
RESTRICT="!test? ( test )"

BDEPEND="
	test? (
		dev-util/shellspec
	)
"

src_test() {
	strip-flags
	PATH="${S}/shellspec/:$PATH" emake --jobs 1 system=1 test
}

src_configure() {
	sed -e "s|@gzip|#@gzip|" -i GNUmakefile || die
}

src_compile() {
	strip-flags
	emake --jobs 1 build
}

src_install() {
	dobin build/bin/mommy
	if use man; then
		doman build/man/man1/mommy.1
	fi
	dofishcomp build/completions/fish/mommy.fish
	dozshcomp build/completions/fish/mommy.fish
}
