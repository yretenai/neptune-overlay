# Copyright 2023-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

CRATES="
	anstream@0.6.15
	anstyle-parse@0.2.5
	anstyle-query@1.1.1
	anstyle-wincon@3.0.4
	anstyle@1.0.8
	anyhow@1.0.86
	arrayref@0.3.8
	arrayvec@0.7.6
	bitflags@2.6.0
	cc@1.1.13
	cfg-if@1.0.0
	clap@4.5.16
	clap_builder@4.5.15
	clap_derive@4.5.13
	clap_lex@0.7.2
	colorchoice@1.0.2
	constant_time_eq@0.3.0
	crossbeam-deque@0.8.5
	crossbeam-epoch@0.9.18
	crossbeam-utils@0.8.20
	duct@0.13.7
	errno@0.3.9
	fastrand@2.1.0
	glob@0.3.1
	heck@0.5.0
	hex@0.4.3
	is_terminal_polyfill@1.70.1
	libc@0.2.158
	linux-raw-sys@0.4.14
	memmap2@0.9.4
	once_cell@1.19.0
	os_pipe@1.2.1
	proc-macro2@1.0.86
	quote@1.0.36
	rayon-core@1.12.1
	rustix@0.38.34
	shared_child@1.0.1
	shlex@1.3.0
	strsim@0.11.1
	syn@2.0.75
	tempfile@3.12.0
	terminal_size@0.3.0
	unicode-ident@1.0.12
	utf8parse@0.2.2
	wild@2.2.1
	windows-sys@0.48.0
	windows-sys@0.52.0
	windows-sys@0.59.0
	windows-targets@0.48.5
	windows-targets@0.52.6
	windows_aarch64_gnullvm@0.48.5
	windows_aarch64_gnullvm@0.52.6
	windows_aarch64_msvc@0.48.5
	windows_aarch64_msvc@0.52.6
	windows_i686_gnu@0.48.5
	windows_i686_gnu@0.52.6
	windows_i686_gnullvm@0.52.6
	windows_i686_msvc@0.48.5
	windows_i686_msvc@0.52.6
	windows_x86_64_gnu@0.48.5
	windows_x86_64_gnu@0.52.6
	windows_x86_64_gnullvm@0.48.5
	windows_x86_64_gnullvm@0.52.6
	windows_x86_64_msvc@0.48.5
	windows_x86_64_msvc@0.52.6
"

inherit cargo git-r3

DESCRIPTION="A simple one-file way to run various GGML models with KoboldAI's UI"
HOMEPAGE="https://github.com/BLAKE3-team/BLAKE3"

SRC_URI="${CARGO_CRATE_URIS}"
S="${WORKDIR}/${P}/b3sum"
LICENSE="|| ( Apache-2.0 Apache-2.0-with-LLVM-exceptions CC0-1.0 )"
# Dependent crate licenses
LICENSE+="
	BSD-2 MIT Unicode-DFS-2016
	|| ( Apache-2.0 CC0-1.0 MIT-0 )
"
SLOT="0"

EGIT_REPO_URI="https://github.com/BLAKE3-team/BLAKE3.git"

if [[ ${PV} != *9999* ]]; then
	EGIT_COMMIT="${PV}"
	KEYWORDS="~amd64"
fi

RESTRICT="test"

src_unpack() {
	git-r3_src_unpack
	cargo_src_unpack
}

src_configure() {
	cargo_src_configure --frozen
}
