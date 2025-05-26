# Copyright 2023-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Your CLI home video recorder"
HOMEPAGE="https://github.com/charmbracelet/freeze"

SRC_URI="
	amd64? ( https://github.com/charmbracelet/freeze/releases/download/v${PV}/freeze_${PV}_Linux_x86_64.tar.gz -> ${P}-amd64.tar.gz )
	x86? ( https://github.com/charmbracelet/freeze/releases/download/v${PV}/freeze_${PV}_Linux_i386.tar.gz -> ${P}-x86.tar.gz )
	arm64? ( https://github.com/charmbracelet/freeze/releases/download/v${PV}/freeze_${PV}_Linux_arm64.tar.gz -> ${P}-arm64.tar.gz )
	arm? ( https://github.com/charmbracelet/freeze/releases/download/v${PV}/freeze_${PV}_Linux_arm.tar.gz -> ${P}-arm.tar.gz )
"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~x86"

if [[ "$ARCH" == "amd64" ]]; then
	S="${WORKDIR}/freeze_${PV}_Linux_x86_64"
elif [[ "$ARCH" == "x86" ]]; then
	S="${WORKDIR}/freeze_${PV}_Linux_i386"
elif [[ "$ARCH" == "arm64" ]]; then
	S="${WORKDIR}/freeze_${PV}_Linux_arm64"
elif [[ "$ARCH" == "arm" ]]; then
	S="${WORKDIR}/freeze_${PV}_Linux_arm"
else
	S="${WORKDIR}/freeze_${PV}_Linux_x86_64"
fi

BDEPEND="
	app-alternatives/gzip
"

RESTRICT="mirror strip"

QA_PREBUILT="*"

src_install() {
	dobin freeze
}
