# Copyright 2023-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

RUST_MIN_VER="1.80.1"

inherit cargo git-r3 desktop xdg

DESCRIPTION="The Modrinth App is a desktop application for managing your Minecraft mods"
HOMEPAGE="https://github.com/modrinth/code"

S_ROOT="${WORKDIR}/${P}"
S="${S_ROOT}/apps/app"
S_FRONTEND="${S_ROOT}/apps/app-frontend"

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
	KEYWORDS="~amd64"
fi

# Requires network access (https) as long as NPM dependencies aren't packaged
RESTRICT="network-sandbox mirror test"

BDEPEND="
	>=net-libs/nodejs-20.6.1[npm]
	>=sys-apps/pnpm-bin-9.5.0
"

PATCHES=(
	"${FILESDIR}/modrinth-${PV}-disable-update-check.patch"
)

src_unpack() {
	git-r3_src_unpack

	cd "${S}"
	cargo generate-lockfile
	if [[ ${PV} != *9999* ]]; then
		cargo_src_unpack
	else
		cargo_live_src_unpack
	fi
}

src_prepare() {
	cd "${S_ROOT}"
	default
	sed -e "s|staging-api.modrinth.com|api.modrinth.com|" -i "packages/app-lib/src/config.rs" || die "can't patch api endpoint to be prod"
}

src_configure() {
	export COREPACK_ENABLE_STRICT=0
	export BASE_URL="https://api.modrinth.com/v2/"
	export BROWSER_BASE_URL="https://api.modrinth.com/v2/"

	cd "${S_FRONTEND}"
	pnpm config set store-dir "${T}/pnpm" || die
	pnpm i --loglevel verbose --reporter append-only || die

	cd "${S}"
	cargo_src_configure
}

src_compile() {
	export BASE_URL="https://api.modrinth.com/v2/"
	export BROWSER_BASE_URL="https://api.modrinth.com/v2/"

	cd "${S_FRONTEND}"
	pnpm build || die

	cd "${S}"
	cargo_src_compile
}

src_install() {
	# cargo_src_install # fucks up because codegen regenerates a frozen file. i love rust, truly.
	cd "${S_ROOT}"

	if [[ "$ARCH" == "amd64" ]]; then
		R_TARGET="$(usex elibc_musl "x86_64-unknown-linux-musl" "x86_64-unknown-linux-gnu")"
	elif [[ "$ARCH" == "x86" ]]; then
		R_TARGET="i686-unknown-linux-gnu"
	elif [[ "$ARCH" == "arm64" ]]; then
		R_TARGET="$(usex elibc_musl "aarch64-unknown-linux-musl" "aarch64-unknown-linux-gnu")"
	elif [[ "$ARCH" == "arm" ]]; then
		R_TARGET="armv7-unknown-linux-gnueabihf"
	else
		die "invalid ARCH (${ARCH})"
	fi

	newbin "target/${R_TARGET}/release/theseus_gui" modrinth
	make_desktop_entry modrinth "Modrinth App" modrinth Game "MimeType=application/zip+mrpack;x-scheme-handler/modrinth"
	newicon "apps/app/icons/icon.png" modrinth.png
}

pkg_postinst() {
	xdg_pkg_postinst
}

pkg_postrm() {
	xdg_pkg_postrm
}
