# Copyright 2023-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

MY_PV="${PV/-r*/}"
DOTNET_PV="${PV}"

inherit unpacker

NUGETS="
	microsoft.aspnetcore.app.runtime.linux-arm@${PV}
	microsoft.aspnetcore.app.runtime.linux-arm64@${PV}
	microsoft.aspnetcore.app.runtime.linux-musl-arm@${PV}
	microsoft.aspnetcore.app.runtime.linux-musl-arm64@${PV}
	microsoft.aspnetcore.app.runtime.linux-musl-x64@${PV}
	microsoft.aspnetcore.app.runtime.linux-x64@${PV}
	microsoft.netcore.app.host.linux-arm@${PV}
	microsoft.netcore.app.host.linux-arm64@${PV}
	microsoft.netcore.app.host.linux-musl-arm@${PV}
	microsoft.netcore.app.host.linux-musl-arm64@${PV}
	microsoft.netcore.app.host.linux-musl-x64@${PV}
	microsoft.netcore.app.host.linux-x64@${PV}
	microsoft.netcore.app.runtime.linux-arm@${PV}
	microsoft.netcore.app.runtime.linux-arm64@${PV}
	microsoft.netcore.app.runtime.linux-musl-arm@${PV}
	microsoft.netcore.app.runtime.linux-musl-arm64@${PV}
	microsoft.netcore.app.runtime.linux-musl-x64@${PV}
	microsoft.netcore.app.runtime.linux-x64@${PV}
"

DESCRIPTION="dotnet aspnet core runtime"
HOMEPAGE="https://github.com/dotnet/aspnetcore"
SRC_URI="
	amd64? (
		elibc_glibc? ( https://dotnetcli.azureedge.net/dotnet/aspnetcore/Runtime/${DOTNET_PV}/aspnetcore-runtime-${DOTNET_PV}-linux-x64.tar.gz )
		elibc_musl? ( https://dotnetcli.azureedge.net/dotnet/aspnetcore/Runtime/${DOTNET_PV}/aspnetcore-runtime-${DOTNET_PV}-linux-musl-x64.tar.gz )
	)
	arm64? (
		elibc_glibc? ( https://dotnetcli.azureedge.net/dotnet/aspnetcore/Runtime/${DOTNET_PV}/aspnetcore-runtime-${DOTNET_PV}-linux-arm64.tar.gz )
		elibc_musl? ( https://dotnetcli.azureedge.net/dotnet/aspnetcore/Runtime/${DOTNET_PV}/aspnetcore-runtime-${DOTNET_PV}-linux-musl-arm64.tar.gz )
	)
"

S="${WORKDIR}"
LICENSE="MIT"
SDK_SLOT="$(ver_cut 1-2)"
RUNTIME_SLOT="${SDK_SLOT}.0"
SLOT="${SDK_SLOT}/${RUNTIME_SLOT}"
KEYWORDS="~amd64 ~arm64"
RESTRICT="bindist mirror strip test"

QA_PREBUILT="*"

RDEPEND="
	>=neptune-dotnet/dotnet-cli-bin-${SDK_SLOT}
	!neptune-dotnet/dotnet-sdk:${SLOT}
	!neptune-dotnet/dotnet-runtime:${SLOT}
"

src_install() {
	# install into existing dotnet env
	local dest="opt/neptune-dotnet"
	dodir "${dest%/*}"

	insinto "${dest}"

	# install dotnet packs
	TARGETS="host shared"
	for DIRECTORY in $TARGETS; do
		if [ -d "${DIRECTORY}" ]; then
			doins -r "${DIRECTORY}"
		fi
	done
}
