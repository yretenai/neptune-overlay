# Copyright 2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit shell-completion

DESCRIPTION="Modern runtime for JavaScript and TypeScript"
HOMEPAGE="
	https://deno.com/
	https://github.com/denoland/deno/
"
SRC_URI="
	amd64? (
		https://github.com/denoland/deno/releases/download/v${PV}/deno-x86_64-unknown-linux-gnu.zip -> ${PN}-${PV}-amd64.tar.xz
	)
	arm64? (
		https://github.com/denoland/deno/releases/download/v${PV}/deno-aarch64-unknown-linux-gnu.zip -> ${PN}-${PV}-arm64.tar.xz
	)
"
S="${WORKDIR}"

LICENSE="MIT"
SLOT="0/$(ver_cut 1-2)"
KEYWORDS="~amd64"

BDEPEND="
	app-arch/unzip
	!dev-lang/deno
"

QA_PREBUILT="*"

src_compile() {
	./deno completions bash > "deno.bash" || die
	./deno completions zsh  > "deno.zsh"  || die
	./deno completions fish  > "deno.fish"  || die
}

src_install() {
	dobin deno
	dofishcomp deno.fish
	newzshcomp deno.zsh _deno
	newbashcomp deno.bash deno
}
