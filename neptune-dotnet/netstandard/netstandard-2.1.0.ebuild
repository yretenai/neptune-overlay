# Copyright 2023-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

MY_PV="${PV/-r*/}"
DOTNET_PV="8.0.403"

inherit unpacker

DESCRIPTION="dotnet standard"
HOMEPAGE="https://github.com/dotnet/standard"
SRC_URI="
	amd64? (
		elibc_glibc? ( https://dotnetcli.azureedge.net/dotnet/Sdk/${DOTNET_PV}/dotnet-sdk-${DOTNET_PV}-linux-x64.tar.gz )
		elibc_musl? ( https://dotnetcli.azureedge.net/dotnet/Sdk/${DOTNET_PV}/dotnet-sdk-${DOTNET_PV}-linux-musl-x64.tar.gz )
	)
	arm? (
		elibc_glibc? ( https://dotnetcli.azureedge.net/dotnet/Sdk/${DOTNET_PV}/dotnet-sdk-${DOTNET_PV}-linux-arm.tar.gz )
		elibc_musl? ( https://dotnetcli.azureedge.net/dotnet/Sdk/${DOTNET_PV}/dotnet-sdk-${DOTNET_PV}-linux-musl-arm.tar.gz )
	)
	arm64? (
		elibc_glibc? ( https://dotnetcli.azureedge.net/dotnet/Sdk/${DOTNET_PV}/dotnet-sdk-${DOTNET_PV}-linux-arm64.tar.gz )
		elibc_musl? ( https://dotnetcli.azureedge.net/dotnet/Sdk/${DOTNET_PV}/dotnet-sdk-${DOTNET_PV}-linux-musl-arm64.tar.gz )
	)
"

S="${WORKDIR}"
LICENSE="MIT"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm ~arm64"
RESTRICT="bindist mirror strip test"

QA_PREBUILT="*"

RDEPEND="
	neptune-dotnet/dotnet-cli-bin
"

src_install() {
	# install into existing dotnet env
	local dest="opt/neptune-dotnet"
	dodir "${dest%/*}/packs"
	insinto "${dest}/packs"

	# install netstandard pack
	doins -r packs/NETStandard.Library.Ref
}
