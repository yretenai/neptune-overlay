# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

MY_PV="${PV/-r*/}"

inherit unpacker

DESCRIPTION="dotnet cli utility"
HOMEPAGE="https://github.com/dotnet/runtime"
SRC_URI="
	amd64? (
		elibc_glibc? ( https://dotnetcli.azureedge.net/dotnet/aspnetcore/Runtime/${PV}/aspnetcore-runtime-${PV}-linux-x64.tar.gz )
		elibc_musl? ( https://dotnetcli.azureedge.net/dotnet/aspnetcore/Runtime/${PV}/aspnetcore-runtime-${PV}-linux-musl-x64.tar.gz )
	)
	arm? (
		elibc_glibc? ( https://dotnetcli.azureedge.net/dotnet/aspnetcore/Runtime/${PV}/aspnetcore-runtime-${PV}-linux-arm.tar.gz )
		elibc_musl? ( https://dotnetcli.azureedge.net/dotnet/aspnetcore/Runtime/${PV}/aspnetcore-runtime-${PV}-linux-musl-arm.tar.gz )
	)
	arm64? (
		elibc_glibc? ( https://dotnetcli.azureedge.net/dotnet/aspnetcore/Runtime/${PV}/aspnetcore-runtime-${PV}-linux-arm64.tar.gz )
		elibc_musl? ( https://dotnetcli.azureedge.net/dotnet/aspnetcore/Runtime/${PV}/aspnetcore-runtime-${PV}-linux-musl-arm64.tar.gz )
	)
"

LICENSE="MIT"
SDK_SLOT="$(ver_cut 1-2)"
RUNTIME_SLOT="${SDK_SLOT}.0"
SLOT="${SDK_SLOT}/${RUNTIME_SLOT}"
KEYWORDS="amd64 arm arm64"
RESTRICT="bindist mirror strip test"

QA_PREBUILT="*"
S="${WORKDIR}"

RDEPEND="
	ada-dotnet/dotnet-cli-bin
	ada-dotnet/dotnet-runtime:${SLOT}
"

src_install() {
	# install into existing dotnet env
	local dest="opt/ada-dotnet"
	dodir "${dest%/*}"
	insinto "${dest}/shared"
	
	# install aspnet pack
	doins -r shared/Microsoft.AspNetCore.App
}
