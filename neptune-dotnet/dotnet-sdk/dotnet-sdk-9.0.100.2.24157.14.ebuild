# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

MY_PV="${PV/-r*/}"

inherit unpacker

DESCRIPTION="dotnet sdk"
HOMEPAGE="https://github.com/dotnet/sdk"
SRC_URI="
	amd64? (
		elibc_glibc? ( https://dotnetcli.azureedge.net/dotnet/Sdk/9.0.100-preview.2.24157.14/dotnet-sdk-9.0.100-preview.2.24157.14-linux-x64.tar.gz )
		elibc_musl? ( https://dotnetcli.azureedge.net/dotnet/Sdk/9.0.100-preview.2.24157.14/dotnet-sdk-9.0.100-preview.2.24157.14-linux-musl-x64.tar.gz )
	)
	arm? (
		elibc_glibc? ( https://dotnetcli.azureedge.net/dotnet/Sdk/9.0.100-preview.2.24157.14/dotnet-sdk-9.0.100-preview.2.24157.14-linux-arm.tar.gz )
		elibc_musl? ( https://dotnetcli.azureedge.net/dotnet/Sdk/9.0.100-preview.2.24157.14/dotnet-sdk-9.0.100-preview.2.24157.14-linux-musl-arm.tar.gz )
	)
	arm64? (
		elibc_glibc? ( https://dotnetcli.azureedge.net/dotnet/Sdk/9.0.100-preview.2.24157.14/dotnet-sdk-9.0.100-preview.2.24157.14-linux-arm64.tar.gz )
		elibc_musl? ( https://dotnetcli.azureedge.net/dotnet/Sdk/9.0.100-preview.2.24157.14/dotnet-sdk-9.0.100-preview.2.24157.14-linux-musl-arm64.tar.gz )
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
	neptune-dotnet/dotnet-aspnetcore-runtime:${SLOT}
	neptune-dotnet/netstandard:2.1
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

	# install sdk packs
	rm -rf packs/NETStandard.Library.Ref
	doins -r packs sdk-manifests sdk templates metadata
}
