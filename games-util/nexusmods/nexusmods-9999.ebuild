# Copyright 2023-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DOTNET_PKG_COMPAT=9.0
DOTNET_NEPTUNE_TARGETS="9.0"

inherit desktop neptune-dotnet xdg

DESCRIPTION="Nexus Mods App is a mod manager for games"
HOMEPAGE="
	https://nexus-mods.github.io/NexusMods.App/
	https://github.com/Nexus-Mods/NexusMods.App
"

if [[ "${PV}" == *9999* ]]; then
	GIT_LFS=1
	inherit git-r3
	EGIT_REPO_URI="https://github.com/Nexus-Mods/NexusMods.App.git"
else
	NEXUSDOCS_PV="fe4e8b1b26d2c2917b404b0b091bfa31f135e337"
	SMAPI_PV="4.1.10"

	SRC_URI="
		https://github.com/Nexus-Mods/NexusMods.App/archive/refs/tags/v${PV}.tar.gz -> ${PN}-${PV}.tar.gz
		https://github.com/Pathoschild/SMAPI/archive/refs/tags/${SMAPI_PV}.tar.gz -> SMAPI-${SMAPI_PV}.tar.gz
		https://github.com/Nexus-Mods/NexusMods.MkDocsMaterial.Themes.Next/archive/${NEXUSDOCS_PV}.tar.gz -> NexusMods.MkDocsMaterial.Themes.Next-${NEXUSDOCS_PV}.tar.gz
		${NUGET_URIS}
	"
	S="${WORKDIR}/NexusMods.App-${PV}"
	KEYWORDS="~amd64"
fi

LICENSE="GPL-3 Apache-2.0 BSD-2 BSD MIT"
SLOT="0"

IUSE="p7zip"
RESTRICT="${RESTRICT} mirror"

# jemalloc causes a TLS issue?
RDEPEND="
	>=dev-libs/rocksdb-8.11.3[-jemalloc]
	!p7zip? ( app-arch/7zip )
	p7zip? ( app-arch/p7zip )
	app-arch/brotli
	dev-libs/elfutils
	dev-libs/expat
	dev-libs/libxml2
	media-gfx/graphite2
	media-libs/fontconfig
	media-libs/freetype
	media-libs/harfbuzz
	media-libs/libglvnd
	media-libs/libpng
	x11-libs/libICE
	x11-libs/libSM
	x11-libs/libX11
	x11-libs/libXau
	x11-libs/libXcursor
	x11-libs/libXdmcp
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXi
	x11-libs/libXrandr
	x11-libs/libXrender
	x11-libs/libdrm
	x11-libs/libxcb
	x11-libs/libxshmfence
"

BDEPEND="
	app-text/dos2unix
"

DOTNET_PKG_PROJECTS=(
	"src/NexusMods.App/NexusMods.App.csproj"
)

DOTNET_PKG_BUILD_EXTRA_ARGS+=(
	"-p:TieredCompilation=true"
	"-p:DefineConstants=\"INSTALLATION_METHOD_PACKAGE_MANAGER\""
	"-p:UseSystemExtractor=true"
)

DOTNET_PKG_TEST_EXTRA_ARGS+=(
	"--filter \"RequiresNetworking==True\""
)

PATCHES=(
	"${FILESDIR}/${PN}-SMAPI.patch"
)

src_unpack() {
	dotnet-pkg_src_unpack
	if [[ "${PV}" == *9999* ]]; then
		git-r3_src_unpack
	fi
}

src_prepare() {
	if [[ "${PV}" != *9999* ]]; then
		rm -d "${S}/extern/SMAPI"
		rm -d "${S}/docs/Nexus"
		mv "${WORKDIR}/SMAPI-${SMAPI_PV}" "${S}/extern/SMAPI"
		mv "${WORKDIR}/NexusMods.MkDocsMaterial.Themes.Next-${NEXUSDOCS_PV}" "${S}/docs/Nexus"
	fi

	rm src/src.sln

	dos2unix src/Games/NexusMods.Games.StardewValley.SMAPI/NexusMods.Games.StardewValley.SMAPI.csproj
	neptune-dotnet_src_prepare
}

src_install() {
	rm -fv "${DOTNET_PKG_OUTPUT}/librocksdb.so" \
		"${DOTNET_PKG_OUTPUT}/librocksdb-musl.so" \
		"${DOTNET_PKG_OUTPUT}/librocksdb-jemalloc.so"
	dotnet-pkg-base_install
	neptune-dotnet_dolauncher "/usr/share/${P}/NexusMods.App" "nexusmods"

	doicon -s scalable src/NexusMods.App.UI/Assets/nexus-logo.svg
	domenu "${FILESDIR}/${PN}-nxm.desktop"
	domenu "${FILESDIR}/${PN}.desktop"
}

pkg_postrm() {
	einfo ""
	einfo "NexusMods.App stores full copies of game archives for repairing."
	einfo "You may want to remove the following directories:"
	einfo "\t\$\{XDG_STATE_HOME:-\$HOME/.local/state\}/NexusMods.App"
	einfo "\t\$\{XDG_DATA_HOME:-\$HOME/.local/share\}/NexusMods.App"
	einfo "It may contain (significant) debris."
	einfo ""
}

pkg_postinst() {
	if has_version "<${CATEGORY}/${P}"; then
		ewarn ""
		ewarn "NexusMods.App at the moment may require a clean install when updating"
		ewarn "You may want to remove the following directories:"
		ewarn "\t\$\{XDG_STATE_HOME:-\$HOME/.local/state\}/NexusMods.App"
		ewarn "\t\$\{XDG_DATA_HOME:-\$HOME/.local/share\}/NexusMods.App"
		ewarn "If you experience issues"
		ewarn ""
	fi
}
