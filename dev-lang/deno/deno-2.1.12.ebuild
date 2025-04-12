# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{11..13} python3_13t )
RUST_MIN_VER="1.82.0"

inherit cargo shell-completion python-any-r1

DESCRIPTION="Modern runtime for JavaScript and TypeScript"
HOMEPAGE="
	https://deno.com/
	https://github.com/denoland/deno/
"

RUST_V8_VER="130.0.7"
SRC_URI="
	https://github.com/denoland/deno/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz
	https://github.com/yretenai/neptune-overlay/releases/download/deps/deno-2.1.11-crates.tar.xz
	amd64? (
		debug? ( https://github.com/denoland/rusty_v8/releases/download/v${RUST_V8_VER}/librusty_v8_debug_x86_64-unknown-linux-gnu.a.gz -> ${PN}-rustyv8-${RUST_V8_VER}-amd64-debug.a.gz )
		!debug? ( https://github.com/denoland/rusty_v8/releases/download/v${RUST_V8_VER}/librusty_v8_release_x86_64-unknown-linux-gnu.a.gz -> ${PN}-rustyv8-${RUST_V8_VER}-amd64-release.a.gz )
	)
	arm64? (
		debug? ( https://github.com/denoland/rusty_v8/releases/download/v${RUST_V8_VER}/librusty_v8_debug_aarch64-unknown-linux-gnu.a.gz -> ${PN}-rustyv8-${RUST_V8_VER}-arm64-debug.a.gz )
		!debug? ( https://github.com/denoland/rusty_v8/releases/download/v${RUST_V8_VER}/librusty_v8_release_aarch64-unknown-linux-gnu.a.gz -> ${PN}-rustyv8-${RUST_V8_VER}-arm64-release.a.gz )
	)
"
S="${WORKDIR}/deno-${PV}/cli"

LICENSE="MIT"
# Dependent crate licenses
LICENSE+="
	Apache-2.0 Apache-2.0-with-LLVM-exceptions BSD-2 BSD Boost-1.0
	CC0-1.0 ISC MPL-2.0 Unicode-3.0 Unicode-DFS-2016 ZLIB
"
SLOT="0/$(ver_cut 0-2)"
KEYWORDS="~amd64 ~arm64"
RESTRICT="test" # requires network access, and /etc/hosts to be modified.

BDEPEND="
	${PYTHON_DEPS}
"

pkg_setup() {
	python-any-r1_pkg_setup
	rust_pkg_setup
}

src_compile() {
	export PYTHON="${EPYTHON}"

	if use debug; then
		export RUSTY_V8_ARCHIVE="${WORKDIR}/${PN}-rustyv8-${RUST_V8_VER}-${ARCH}-debug.a"
	else
		export RUSTY_V8_ARCHIVE="${WORKDIR}/${PN}-rustyv8-${RUST_V8_VER}-${ARCH}-release.a"
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
