# Copyright 2023-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

MY_PV="${PV/-r*/}"
DN_PV="${PV}"

RUNTIME_PV="9.0.3"
ASP_PV="9.0.3"

NUGETS="
	microsoft.aspnetcore.app.ref@${ASP_PV}
	microsoft.aspnetcore.app.runtime.linux-arm@${ASP_PV}
	microsoft.aspnetcore.app.runtime.linux-arm64@${ASP_PV}
	microsoft.aspnetcore.app.runtime.linux-musl-arm@${ASP_PV}
	microsoft.aspnetcore.app.runtime.linux-musl-arm64@${ASP_PV}
	microsoft.aspnetcore.app.runtime.linux-musl-x64@${ASP_PV}
	microsoft.aspnetcore.app.runtime.linux-x64@${ASP_PV}
	microsoft.netcore.app.host.linux-arm@${RUNTIME_PV}
	microsoft.netcore.app.host.linux-arm64@${RUNTIME_PV}
	microsoft.netcore.app.host.linux-musl-arm@${RUNTIME_PV}
	microsoft.netcore.app.host.linux-musl-arm64@${RUNTIME_PV}
	microsoft.netcore.app.host.linux-musl-x64@${RUNTIME_PV}
	microsoft.netcore.app.host.linux-x64@${RUNTIME_PV}
	microsoft.netcore.app.ref@${RUNTIME_PV}
	microsoft.netcore.app.runtime.linux-arm@${RUNTIME_PV}
	microsoft.netcore.app.runtime.linux-arm64@${RUNTIME_PV}
	microsoft.netcore.app.runtime.linux-musl-arm@${RUNTIME_PV}
	microsoft.netcore.app.runtime.linux-musl-arm64@${RUNTIME_PV}
	microsoft.netcore.app.runtime.linux-musl-x64@${RUNTIME_PV}
	microsoft.netcore.app.runtime.linux-x64@${RUNTIME_PV}
"

inherit unpacker nuget

DESCRIPTION="dotnet sdk"
HOMEPAGE="https://github.com/dotnet/sdk"
SRC_URI="
	amd64? (
		elibc_glibc? ( https://dotnetcli.azureedge.net/dotnet/Sdk/${DN_PV}/dotnet-sdk-${DN_PV}-linux-x64.tar.gz )
		elibc_musl? ( https://dotnetcli.azureedge.net/dotnet/Sdk/${DN_PV}/dotnet-sdk-${DN_PV}-linux-musl-x64.tar.gz )
	)
	arm64? (
		elibc_glibc? ( https://dotnetcli.azureedge.net/dotnet/Sdk/${DN_PV}/dotnet-sdk-${DN_PV}-linux-arm64.tar.gz )
		elibc_musl? ( https://dotnetcli.azureedge.net/dotnet/Sdk/${DN_PV}/dotnet-sdk-${DN_PV}-linux-musl-arm64.tar.gz )
	)
	${NUGET_URIS}
"

S="${WORKDIR}"
LICENSE="MIT"
SDK_SLOT="$(ver_cut 1-2)"
RUNTIME_SLOT="${SDK_SLOT}.0"
SLOT="${SDK_SLOT}/${RUNTIME_SLOT}"
KEYWORDS="~amd64"
RESTRICT="bindist mirror strip test"

QA_PREBUILT="*"

RDEPEND="
	neptune-dotnet/netstandard
	>=neptune-dotnet/dotnet-cli-bin-${SDK_SLOT}
	!neptune-dotnet/dotnet-aspnetcore-runtime:${SLOT}
	!neptune-dotnet/dotnet-runtime:${SLOT}
"

src_unpack() {
	nuget_unpack-non-nuget-archives
}

src_install() {
	# install into existing dotnet env
	local dest="opt/neptune-dotnet"
	dodir "${dest%/*}"
	insinto "${dest}"

	# Create a magic workloads file, bug #841896
	local featureband="$(( $(ver_cut 3) / 100 * 100 ))" # e.g. 404 -> 400
	local workloads="metadata/workloads/${SDK_SLOT}.${featureband}"

	mkdir -p "${S}/${workloads}" || die
	touch "${S}/${workloads}/userlocal" || die

	# remove netstandard
	rm -rf packs/NETStandard.Library.Ref

	# remove stray manifests
	find sdk-manifests/ -maxdepth 1 -type d \( -not -iname "${SDK_SLOT}*" -and -not -iname "sdk-manifests" \) -exec rm -rv {} \;

	# install dotnet packs
	TARGETS="host packs sdk sdk-manifests shared templates metadata"
	for DIRECTORY in $TARGETS; do
		if [ -d "${DIRECTORY}" ]; then
			doins -r "${DIRECTORY}"
		fi
	done

	insinto "${dest}/library-packs"
	local archive
	for archive in ${A} ; do
		case "${archive}" in
			*.nupkg )
				doins "${DISTDIR}/${archive}"
				;;
			* )
				:
				;;
		esac
	done
}
