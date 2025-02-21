# Copyright 2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Modern runtime for JavaScript and TypeScript"
HOMEPAGE="
	https://deno.com/
	https://github.com/denoland/deno/
"
SRC_URI="
	amd64? (
		https://github.com/denoland/deno/releases/download/v${PV}/deno-x86_64-unknown-linux-gnu.zip -> ${P}-amd64.zip
	)
	arm64? (
		https://github.com/denoland/deno/releases/download/v${PV}/deno-aarch64-unknown-linux-gnu.zip -> ${P}-arm64.zip
	)
"
S="${WORKDIR}"

LICENSE="MIT"
SLOT="0/$(ver_cut 0-1)"
KEYWORDS="~amd64 ~arm64"

BDEPEND="
	app-arch/unzip
"

QA_PREBUILT="*"

src_install() {
	newbin deno deno-bin
}
