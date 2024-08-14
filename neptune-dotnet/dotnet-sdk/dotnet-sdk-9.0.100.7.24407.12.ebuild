# Copyright 2023-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

MY_PV="${PV/-r*/}"
DN_PV="9.0.100-preview.7.24407.12"

inherit unpacker

DESCRIPTION="dotnet sdk"
HOMEPAGE="https://github.com/dotnet/sdk"
SRC_URI="
	amd64? (
		elibc_glibc? ( https://dotnetcli.azureedge.net/dotnet/Sdk/${DN_PV}/dotnet-sdk-${DN_PV}-linux-x64.tar.gz )
		elibc_musl? ( https://dotnetcli.azureedge.net/dotnet/Sdk/${DN_PV}/dotnet-sdk-${DN_PV}-linux-musl-x64.tar.gz )
	)
	arm? (
		elibc_glibc? ( https://dotnetcli.azureedge.net/dotnet/Sdk/${DN_PV}/dotnet-sdk-${DN_PV}-linux-arm.tar.gz )
		elibc_musl? ( https://dotnetcli.azureedge.net/dotnet/Sdk/${DN_PV}/dotnet-sdk-${DN_PV}-linux-musl-arm.tar.gz )
	)
	arm64? (
		elibc_glibc? ( https://dotnetcli.azureedge.net/dotnet/Sdk/${DN_PV}/dotnet-sdk-${DN_PV}-linux-arm64.tar.gz )
		elibc_musl? ( https://dotnetcli.azureedge.net/dotnet/Sdk/${DN_PV}/dotnet-sdk-${DN_PV}-linux-musl-arm64.tar.gz )
	)
"

S="${WORKDIR}"
LICENSE="MIT"
SDK_SLOT="$(ver_cut 1-2)"
RUNTIME_SLOT="${SDK_SLOT}.0"
SLOT="${SDK_SLOT}/${RUNTIME_SLOT}"
KEYWORDS="~amd64 ~arm ~arm64 -*"
RESTRICT="bindist mirror strip test"

QA_PREBUILT="*"

RDEPEND="
	neptune-dotnet/netstandard
	>=neptune-dotnet/dotnet-cli-bin-${SDK_SLOT}
	!neptune-dotnet/dotnet-aspnetcore-runtime:${SLOT}
	!neptune-dotnet/dotnet-runtime:${SLOT}
"

src_install() {
	# install into existing dotnet env
	local dest="opt/neptune-dotnet"
	dodir "${dest%/*}"
	insinto "${dest}"

	# Create a magic workloads file, bug #841896
	local featureband="$(( $(ver_cut 3) / 100 * 100 ))"       # e.g. 404 -> 400
	local workloads="metadata/workloads/${SDK_SLOT}.${featureband}"

	mkdir -p "${S}/${workloads}" || die
	touch "${S}/${workloads}/userlocal" || die

	# remove netstandard
	rm -rf packs/NETStandard.Library.Ref

	# install dotnet packs
	doins -r host packs sdk sdk-manifests shared templates
}
