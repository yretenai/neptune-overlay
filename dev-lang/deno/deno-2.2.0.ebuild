# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

LLVM_COMPAT=(19)
RUST_MAX_VER="1.82.100"
RUST_MIN_VER="1.82.0"
RUST_NEEDS_LLVM=1
# RUST_REQ_USE="clippy,rustfmt"

inherit cargo shell-completion

DESCRIPTION="Modern runtime for JavaScript and TypeScript"
HOMEPAGE="
	https://deno.com/
	https://github.com/denoland/deno/
"
SRC_URI="
	https://github.com/denoland/deno/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz
	https://github.com/yretenai/neptune-overlay/releases/download/deps/deno-2.2.0-crates.tar.xz
"
S="${WORKDIR}/deno-${PV}/cli"

LICENSE="MIT"
# Dependent crate licenses
LICENSE+="
	Apache-2.0 Apache-2.0-with-LLVM-exceptions BSD-2 BSD Boost-1.0
	CC0-1.0 ISC MPL-2.0 Unicode-3.0 Unicode-DFS-2016 ZLIB
"
SLOT="0/$(ver_cut 0-1)"
KEYWORDS="~amd64 ~arm64"
RESTRICT="test" # requires network access, and /etc/hosts to be modified.

src_compile() {
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
