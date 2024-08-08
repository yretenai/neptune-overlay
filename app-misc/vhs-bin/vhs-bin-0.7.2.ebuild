# Copyright 2023-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Your CLI home video recorder"
HOMEPAGE="https://github.com/charmbracelet/vhs"
SRC_URI="
	amd64? ( https://github.com/charmbracelet/vhs/releases/download/v${PV}/vhs_${PV}_Linux_x86_64.tar.gz -> ${P}-amd64.tar.gz )
	x86? ( https://github.com/charmbracelet/vhs/releases/download/v${PV}/vhs_${PV}_Linux_i386.tar.gz -> ${P}-x86.tar.gz )
	arm64? ( https://github.com/charmbracelet/vhs/releases/download/v${PV}/vhs_${PV}_Linux_arm64.tar.gz -> ${P}-arm64.tar.gz )
	arm? ( https://github.com/charmbracelet/vhs/releases/download/v${PV}/vhs_${PV}_Linux_arm.tar.gz -> ${P}-arm.tar.gz )
"

IUSE="fish-completion zsh-completion bash-completion"

if [[ "$ARCH" == "amd64" ]]; then
	S="${WORKDIR}/vhs_${PV}_Linux_x86_64"
elif [[ "$ARCH" == "x86" ]]; then
	S="${WORKDIR}/vhs_${PV}_Linux_i386"
elif [[ "$ARCH" == "arm64" ]]; then
	S="${WORKDIR}/vhs_${PV}_Linux_arm64"
elif [[ "$ARCH" == "arm" ]]; then
	S="${WORKDIR}/vhs_${PV}_Linux_arm"
else
	die "invalid ARCH (${ARCH})"
fi

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~x86 ~arm -*"

BDEPEND="
	app-alternatives/gzip
"

RESTRICT="mirror strip"

QA_PREBUILT="*"

src_install() {
	dobin vhs
	gunzip manpages/vhs.1.gz
	doman manpages/vhs.1

	if use fish-completion; then
		insinto /etc/fish/completions/
		doins completions/vhs.fish
	fi

	if use zsh-completion; then
		insinto /usr/share/zsh/site-functions/
		newins completions/vhs.zsh _vhs
	fi

	if use bash-completion; then
		insinto /usr/share/bash-completion/completions/
		newins completions/vhs.zsh vhs
	fi
}
