# Copyright 2023-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit shell-completion

DESCRIPTION="Your CLI home video recorder"
HOMEPAGE="https://github.com/charmbracelet/vhs"

SRC_URI="
	amd64? ( https://github.com/charmbracelet/vhs/releases/download/v${PV}/vhs_${PV}_Linux_x86_64.tar.gz -> ${P}-amd64.tar.gz )
	x86? ( https://github.com/charmbracelet/vhs/releases/download/v${PV}/vhs_${PV}_Linux_i386.tar.gz -> ${P}-x86.tar.gz )
	arm64? ( https://github.com/charmbracelet/vhs/releases/download/v${PV}/vhs_${PV}_Linux_arm64.tar.gz -> ${P}-arm64.tar.gz )
	arm? ( https://github.com/charmbracelet/vhs/releases/download/v${PV}/vhs_${PV}_Linux_arm.tar.gz -> ${P}-arm.tar.gz )
"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

if [[ "$ARCH" == "amd64" ]]; then
	S="${WORKDIR}/vhs_${PV}_Linux_x86_64"
elif [[ "$ARCH" == "x86" ]]; then
	S="${WORKDIR}/vhs_${PV}_Linux_i386"
elif [[ "$ARCH" == "arm64" ]]; then
	S="${WORKDIR}/vhs_${PV}_Linux_arm64"
elif [[ "$ARCH" == "arm" ]]; then
	S="${WORKDIR}/vhs_${PV}_Linux_arm"
else
	S="${WORKDIR}/vhs_${PV}_Linux_x86_64"
fi

DEPEND="
	www-apps/ttyd
"

RDEPEND="
	${DEPEND}
"

BDEPEND="
	app-alternatives/gzip
"

RESTRICT="mirror strip"

QA_PREBUILT="*"

src_install() {
	dobin vhs
	gunzip manpages/vhs.1.gz
	doman manpages/vhs.1
	dofishcomp completions/vhs.fish
	newzshcomp completions/vhs.zsh _vhs
	newbashcomp completions/vhs.bash vhs
}
