# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

MY_PV="${PV/-r*/}"

inherit unpacker

DESCRIPTION="dotnet aspnet core runtime"
HOMEPAGE="https://github.com/dotnet/aspnetcore"
SRC_URI="
	amd64? (
		elibc_glibc? ( https://dotnetcli.azureedge.net/dotnet/aspnetcore/Runtime/9.0.0-preview.2.24128.4/aspnetcore-runtime-9.0.0-preview.2.24128.4-linux-x64.tar.gz )
		elibc_musl? ( https://dotnetcli.azureedge.net/dotnet/aspnetcore/Runtime/9.0.0-preview.2.24128.4/aspnetcore-runtime-9.0.0-preview.2.24128.4-linux-musl-x64.tar.gz )
	)
	arm? (
		elibc_glibc? ( https://dotnetcli.azureedge.net/dotnet/aspnetcore/Runtime/9.0.0-preview.2.24128.4/aspnetcore-runtime-9.0.0-preview.2.24128.4-linux-arm.tar.gz )
		elibc_musl? ( https://dotnetcli.azureedge.net/dotnet/aspnetcore/Runtime/9.0.0-preview.2.24128.4/aspnetcore-runtime-9.0.0-preview.2.24128.4-linux-musl-arm.tar.gz )
	)
	arm64? (
		elibc_glibc? ( https://dotnetcli.azureedge.net/dotnet/aspnetcore/Runtime/9.0.0-preview.2.24128.4/aspnetcore-runtime-9.0.0-preview.2.24128.4-linux-arm64.tar.gz )
		elibc_musl? ( https://dotnetcli.azureedge.net/dotnet/aspnetcore/Runtime/9.0.0-preview.2.24128.4/aspnetcore-runtime-9.0.0-preview.2.24128.4-linux-musl-arm64.tar.gz )
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
	>=neptune-dotnet/dotnet-cli-bin-${SDK_SLOT}
	neptune-dotnet/dotnet-runtime:${SLOT}
"

src_install() {
	# install into existing dotnet env
	local dest="opt/neptune-dotnet"
	dodir "${dest%/*}"
	insinto "${dest}/shared"
	
	# install aspnet pack
	doins -r shared/Microsoft.AspNetCore.App
}
