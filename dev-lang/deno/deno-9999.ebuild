# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{11..14} python3_{13..14}t )
RUST_MIN_VER="1.89.0"
RUST_MAX_VER="1.89.0"

inherit git-r3 cargo shell-completion python-any-r1

DESCRIPTION="Modern runtime for JavaScript and TypeScript"
HOMEPAGE="
	https://deno.com/
	https://github.com/denoland/deno/
"
EGIT_REPO_URI="https://github.com/denoland/deno.git"
S="${WORKDIR}/deno-9999/cli"

LICENSE="MIT"
# Dependent crate licenses
LICENSE+="
	Apache-2.0 Apache-2.0-with-LLVM-exceptions BSD-2 BSD Boost-1.0
	CC0-1.0 ISC MPL-2.0 Unicode-3.0 Unicode-DFS-2016 ZLIB
"
SLOT="0/9999"
# network access requried for rusty_v8
RESTRICT="test network-sandbox" # tests require /etc/hosts to be modified.

RDEPEND="
	dev-libs/glib
	!!dev-lang/deno-bin
"
DEPEND="${RDEPEND}"
BDEPEND="
	${PYTHON_DEPS}
"

src_unpack() {
	git-r3_src_unpack
	cargo_live_src_unpack
}

pkg_setup() {
	python-any-r1_pkg_setup
	rust_pkg_setup
}

src_compile() {
	export PYTHON="${EPYTHON}"

	if use debug; then
		export V8_FORCE_DEBUG=1
	fi

	cargo_src_compile

	DENO="${WORKDIR}/deno-${PV}/$(cargo_target_dir)/deno"
	${DENO} completions bash > "deno.bash" || die
	${DENO} completions zsh > "deno.zsh" || die
	${DENO} completions fish > "deno.fish" || die
}

src_install() {
	cargo_src_install
	dofishcomp deno.fish
	newzshcomp deno.zsh _deno
	newbashcomp deno.bash deno
}
