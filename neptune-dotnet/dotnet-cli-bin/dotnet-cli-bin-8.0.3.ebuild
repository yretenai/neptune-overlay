# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

MY_PV="${PV/-r*/}"

inherit unpacker

DESCRIPTION="dotnet cli utility"
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

LICENSE="MIT"
SLOT="0"
KEYWORDS="amd64 arm arm64"
RESTRICT="bindist mirror strip test"

RDEPEND="
	app-crypt/mit-krb5:0/0
	dev-libs/icu
	dev-util/lttng-ust:0/2.12
	sys-libs/zlib:0/1
"

QA_PREBUILT="*"
S="${WORKDIR}"

src_install() {
	local dest="opt/neptune-dotnet"
	dodir "${dest%/*}" "${dest%/*}/metadata" "${dest%/*}/"
	exeinto "${dest}"
	doexe dotnet
	insinto "${dest}"
	doins LICENSE.txt ThirdPartyNotices.txt
	echo "DOTNET_ROOT=\"/${dest}\"" > 99neptune-dotnet
	doenvd 99neptune-dotnet
	dosym "../../${dest}/dotnet" "/usr/bin/neptune-dotnet"
}
