# Copyright 2023-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit shell-completion

MY_PV="${PV}"
IS_BETA=0
if [[ ${PV} == *_beta* ]]; then
	MY_PV="$(ver_cut 1-3)-0"
else
	KEYWORDS="-* ~amd64 ~arm64"
fi

DESCRIPTION="Fast, disk space efficient package manager, alternative to npm and yarn"
HOMEPAGE="https://pnpm.io"
SRC_URI="
	elibc_musl? (
		amd64? ( https://github.com/pnpm/pnpm/releases/download/v${MY_PV}/pnpm-linux-x64.tar.gz -> ${P}-amd64-musl.tar.gz )
		arm64? ( https://github.com/pnpm/pnpm/releases/download/v${MY_PV}/pnpm-linux-arm64.tar.gz -> ${P}-arm64-musl.tar.gz )
	)
	elibc_glibc? (
		amd64? ( https://github.com/pnpm/pnpm/releases/download/v${MY_PV}/pnpm-linux-x64.tar.gz -> ${P}-amd64-glibc.tar.gz )
		arm64? ( https://github.com/pnpm/pnpm/releases/download/v${MY_PV}/pnpm-linux-arm64.tar.gz -> ${P}-arm64-glibc.tar.gz )
	)
"

S="${WORKDIR}"

LICENSE="MIT"
SLOT="0"

RESTRICT="strip"

QA_PREBUILT="usr/opt/pnpm-bin/*"

src_prepare() {
	default
	rm -rfv dist/vendor dist/node_modules/.bin
}

src_install() {
	insinto "/usr/opt/pnpm-bin"
	doins -r "${S}/dist"
	exeinto "/usr/opt/pnpm-bin"
	doexe "${S}/pnpm"
	dosym "../opt/pnpm-bin/pnpm" /usr/bin/pnpm
	newbashcomp "${S}/dist/templates/completion.bash" pnpm
	newfishcomp "${S}/dist/templates/completion.fish" pnpm
	newzshcomp "${S}/dist/templates/completion.zsh" pnpm
}
