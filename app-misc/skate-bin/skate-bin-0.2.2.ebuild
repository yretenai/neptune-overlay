# Copyright 2023-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION=" A personal key value store"
HOMEPAGE="https://github.com/charmbracelet/skate"
SRC_URI="
	amd64? ( https://github.com/charmbracelet/skate/releases/download/v${PV}/skate_${PV}_Linux_x86_64.tar.gz -> ${P}-amd64.tar.gz )
	x86? ( https://github.com/charmbracelet/skate/releases/download/v${PV}/skate_${PV}_Linux_i386.tar.gz -> ${P}-x86.tar.gz )
	arm64? ( https://github.com/charmbracelet/skate/releases/download/v${PV}/skate_${PV}_Linux_arm64.tar.gz -> ${P}-arm64.tar.gz )
	arm? ( https://github.com/charmbracelet/skate/releases/download/v${PV}/skate_${PV}_Linux_armv7.tar.gz -> ${P}-arm.tar.gz )
"

IUSE="fish-completion zsh-completion bash-completion"

S="${WORKDIR}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~x86 ~arm -*"

BDEPEND="
	app-alternatives/gzip
"

RESTRICT="mirror strip"

QA_PREBUILT="*"

src_install() {
	dobin skate
	gunzip manpages/skate.1.gz
	doman manpages/skate.1

	if use fish-completion; then
		insinto /etc/fish/completions/
		doins completions/skate.fish
	fi

	if use zsh-completion; then
		insinto /usr/share/zsh/site-functions/
		newins completions/skate.zsh _skate
	fi

	if use bash-completion; then
		insinto /usr/share/bash-completion/completions/
		newins completions/skate.zsh skate
	fi
}
