# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# change this to 1 when llvm-20 is released.
# this is a switch because v8 will use llvm-21 alpha because they're sickos.
DENO_V8_LLVM_SUPPORTED=0

if [[ ${DENO_V8_LLVM_SUPPORTED} > 0 ]]; then
	LLVM_COMPAT=(20)
fi
PYTHON_COMPAT=( python3_{11..13} )
RUST_MAX_VER="1.82.100"
RUST_MIN_VER="1.82.0"
RUST_REQ_USE="clippy,rustfmt"

inherit cargo shell-completion python-any-r1

if [[ ${DENO_V8_LLVM_SUPPORTED} > 0 ]]; then
	inherit llvm-r1
fi

DESCRIPTION="Modern runtime for JavaScript and TypeScript"
HOMEPAGE="
	https://deno.com/
	https://github.com/denoland/deno/
"

SRC_URI="
	https://github.com/denoland/deno/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz
	https://github.com/yretenai/neptune-overlay/releases/download/deps/${P}-crates.tar.xz
"
S="${WORKDIR}/deno-${PV}/cli"

if [[ ${DENO_V8_LLVM_SUPPORTED} == 0 ]]; then
	RUST_V8_VER="134.4.0"
	SRC_URI+="
		amd64? (
			debug? ( https://github.com/denoland/rusty_v8/releases/download/v${RUST_V8_VER}/librusty_v8_debug_x86_64-unknown-linux-gnu.a.gz -> ${P}-rustyv8-amd64-debug.a.gz )
			!debug? ( https://github.com/denoland/rusty_v8/releases/download/v${RUST_V8_VER}/librusty_v8_release_x86_64-unknown-linux-gnu.a.gz -> ${P}-rustyv8-amd64-release.a.gz )
		)
		arm64? (
			debug? ( https://github.com/denoland/rusty_v8/releases/download/v${RUST_V8_VER}/librusty_v8_debug_aarch64-unknown-linux-gnu.a.gz -> ${P}-rustyv8-arm64-debug.a.gz )
			!debug? ( https://github.com/denoland/rusty_v8/releases/download/v${RUST_V8_VER}/librusty_v8_release_aarch64-unknown-linux-gnu.a.gz -> ${P}-rustyv8-arm64-release.a.gz )
		)
	"
fi

LICENSE="MIT"
# Dependent crate licenses
LICENSE+="
	Apache-2.0 Apache-2.0-with-LLVM-exceptions BSD-2 BSD Boost-1.0
	CC0-1.0 ISC MPL-2.0 Unicode-3.0 Unicode-DFS-2016 ZLIB
"
SLOT="0/$(ver_cut 0-1)"
KEYWORDS="~amd64 ~arm64"
RESTRICT="test" # requires network access, and /etc/hosts to be modified.

BDEPEND="
	${PYTHON_DEPS}
"

if [[ ${DENO_V8_LLVM_SUPPORTED} > 0 ]]; then
	BDEPEND+="
		dev-build/gn
		dev-build/cmake
		dev-build/ninja
	"
fi

pkg_setup() {
	if [[ ${DENO_V8_LLVM_SUPPORTED} > 0 ]]; then
		llvm-r1_pkg_setup
	fi
	python-any-r1_pkg_setup
	rust_pkg_setup
}

src_prepare() {
	default
	if [[ ${DENO_V8_LLVM_SUPPORTED} > 0 ]]; then
		cp -rfvs "$(get_llvm_prefix -b)" "$T/llvm-merged"
		mkdir "$T/llvm-merged/lib/clang"
		ln -s "${BROOT}/usr/lib/clang/${LLVM_SLOT}" "$T/llvm-merged/lib/clang/${LLVM_SLOT}"
	fi
}

src_compile() {
	export PYTHON="${EPYTHON}"

	if [[ ${DENO_V8_LLVM_SUPPORTED} > 0 ]]; then
		export V8_FROM_SOURCE=1
		export CLANG_BASE_PATH="$T/llvm-merged"
	else
		if use debug; then
			export RUSTY_V8_ARCHIVE="${WORKDIR}/${P}-rustyv8-${ARCH}-debug.a"
		else
			export RUSTY_V8_ARCHIVE="${WORKDIR}/${P}-rustyv8-${ARCH}-release.a"
		fi
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
