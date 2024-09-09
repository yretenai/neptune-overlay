# Copyright 2023-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

CRATES="
"

inherit cargo git-r3

DESCRIPTION="The Modrinth App is a desktop application for managing your Minecraft mods"
HOMEPAGE="https://github.com/modrinth/code"

SRC_URI="
	${CARGO_CRATE_URIS}
"

EGIT_REPO_URI="https://github.com/modrinth/code.git"

if [[ ${PV} != *9999* ]]; then
	EGIT_COMMIT="v${PV}"
	KEYWORDS="~amd64"
fi

S="${WORKDIR}/${P}/apps/app"
S_FRONTEND="${WORKDIR}/${P}/apps/app-frontend"

LICENSE="GPL-3"
# Dependent crate licenses
LICENSE+="
	Apache-2.0 Apache-2.0-with-LLVM-exceptions BSD CC0-1.0 ISC MIT
	MPL-2.0 Unicode-DFS-2016
"

SLOT="0"
# Requires network access (https) as long as NPM dependencies aren't packaged
RESTRICT="network-sandbox mirror test"

BDEPEND="
	>=net-libs/nodejs-20.6.1[npm]
	>=sys-apps/pnpm-bin-9.5.0
"

src_prepare() {
	default
	sed -e "s|name = \"theseus_gui\"|name = \"modrinth\"|" -i "Cargo.toml" || die "can't patch theseus_gui name"
}

src_configure() {
	cargo_src_configure
	cd "${S_FRONTEND}"
	export COREPACK_ENABLE_STRICT=0
	pnpm config set store-dir "${T}/pnpm" || die
	pnpm i || die
}

src_compile() {
	cd "${S_FRONTEND}"
	pnpm build || die
	cd "${S}"
	cargo_src_compile
}

src_unpack() {
	git-r3_src_unpack
	if [[ ${PV} != *9999* ]]; then
		cargo_src_unpack
	else
		cargo_live_src_unpack
	fi
}
