# Copyright 2023-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

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
	amd64? ( https://github.com/pnpm/pnpm/releases/download/v${MY_PV}/pnpm-linux-x64 -> ${P}-amd64 )
	arm64? ( https://github.com/pnpm/pnpm/releases/download/v${MY_PV}/pnpm-linux-arm64 -> ${P}-arm64 )
"

S="${WORKDIR}"

LICENSE="MIT"
SLOT="0"

RESTRICT="strip"

QA_PREBUILT="usr/bin/pnpm"

src_install() {
	newbin "${DISTDIR}/${P}-${ARCH}" pnpm
}
