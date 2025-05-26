# Copyright 2023-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cargo git-r3 desktop xdg

DESCRIPTION="The Modrinth App is a desktop application for managing your Minecraft mods"
HOMEPAGE="https://github.com/modrinth/code"

S_HOME="${WORKDIR}/${P}"
S="${S_HOME}"
S_THESEUS="${S}/apps/app"
S_FRONTEND="${S}/apps/app-frontend"

LICENSE="GPL-3"
# Dependent crate licenses
LICENSE+="
	0BSD Apache-2.0 Apache-2.0-with-LLVM-exceptions BSD-2 BSD CC0-1.0
	ISC MIT MPL-2.0 MPL-2.0 Unicode-3.0
"
SLOT="0"

EGIT_REPO_URI="https://github.com/modrinth/code.git"

if [[ ${PV} != *9999* ]]; then
	EGIT_COMMIT="v${PV}"
	KEYWORDS="~amd64 ~arm64"
fi

# Requires network access (https) as long as NPM dependencies aren't packaged
RESTRICT="network-sandbox mirror test"

DEPEND="
	net-libs/webkit-gtk:4.1
	dev-libs/libayatana-appindicator
	gnome-base/librsvg
"

BDEPEND="
	>=net-libs/nodejs-20.6.1[npm]
	>=sys-apps/pnpm-bin-9.5.0
"

PATCHES=(
	"${FILESDIR}/modrinth-${PV}-disable-update-check.patch"
)

src_unpack() {
	# overriding S is necessary because cargo has no way to override where root is.
	if [[ ${PV} == *9999* ]]; then
		git-r3_src_unpack
		S="${S_THESEUS}" cargo_live_src_unpack
	else
		S="${S_THESEUS}" cargo_src_unpack
	fi

	export COREPACK_ENABLE_STRICT=0
	export BASE_URL="https://api.modrinth.com/v2/"
	export BROWSER_BASE_URL="https://api.modrinth.com/v2/"

	cd "${S_FRONTEND}"
	pnpm config set store-dir "${T}/pnpm" || die
	pnpm i --loglevel verbose --reporter append-only || die
}

src_prepare() {
	default
	sed -e "s|staging-api.modrinth.com|api.modrinth.com|" -i "packages/app-lib/src/config.rs" || die "can't patch api endpoint to be prod"
}

src_configure() {
	cd "${S_THESEUS}"
	cargo_src_configure --frozen
}

src_compile() {
	export BASE_URL="https://api.modrinth.com/v2/"
	export BROWSER_BASE_URL="https://api.modrinth.com/v2/"

	cd "${S_FRONTEND}"
	pnpm build || die

	cd "${S_THESEUS}"
	cargo_src_compile
}

src_install() {
	# cargo_src_install # fucks up because codegen regenerates a frozen file. i love rust, truly.
	newbin "$(cargo_target_dir)/theseus_gui" modrinth
	make_desktop_entry modrinth "Modrinth App" modrinth Game "MimeType=application/zip+mrpack;x-scheme-handler/modrinth"
	newicon "apps/app/icons/icon.png" modrinth.png
}

pkg_postinst() {
	xdg_pkg_postinst
}

pkg_postrm() {
	xdg_pkg_postrm
}
