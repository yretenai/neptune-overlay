# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

MY_PV="${PV/-r*/}"

inherit unpacker

DESCRIPTION="dotnet runtime"
HOMEPAGE="https://github.com/dotnet/runtime"
SRC_URI="
	amd64? (
		elibc_glibc? ( https://dotnetcli.azureedge.net/dotnet/Runtime/${PV}/dotnet-runtime-${PV}-linux-x64.tar.gz )
		elibc_musl? ( https://dotnetcli.azureedge.net/dotnet/Runtime/${PV}/dotnet-runtime-${PV}-linux-musl-x64.tar.gz )
	)
	arm? (
		elibc_glibc? ( https://dotnetcli.azureedge.net/dotnet/Runtime/${PV}/dotnet-runtime-${PV}-linux-arm.tar.gz )
		elibc_musl? ( https://dotnetcli.azureedge.net/dotnet/Runtime/${PV}/dotnet-runtime-${PV}-linux-musl-arm.tar.gz )
	)
	arm64? (
		elibc_glibc? ( https://dotnetcli.azureedge.net/dotnet/Runtime/${PV}/dotnet-runtime-${PV}-linux-arm64.tar.gz )
		elibc_musl? ( https://dotnetcli.azureedge.net/dotnet/Runtime/${PV}/dotnet-runtime-${PV}-linux-musl-arm64.tar.gz )
	)
"

S="${WORKDIR}"
LICENSE="MIT"
SDK_SLOT="$(ver_cut 1-2)"
RUNTIME_SLOT="${SDK_SLOT}.0"
SLOT="${SDK_SLOT}/${RUNTIME_SLOT}"
KEYWORDS="~amd64 ~arm ~arm64"
RESTRICT="bindist mirror strip test"

QA_PREBUILT="*"

RDEPEND="
	neptune-dotnet/dotnet-cli-bin
"

src_install() {
	# install into existing dotnet env
	local dest="opt/neptune-dotnet"
	dodir "${dest%/*}"
	insinto "${dest}"

	# install dotnet packs
	doins -r host shared
}
