# Copyright 2023-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

NUGET_PVS="8.0.16 8.0.15 8.0.14 8.0.13 8.0.12 8.0.11 8.0.10 8.0.8 8.0.7 8.0.6 8.0.5 8.0.4 8.0.3 8.0.2 8.0.1 8.0.0 "
for NUGET_PV in $NUGET_PVS; do
	NUGETS+="
		microsoft.netcore.app.host.linux-arm@${NUGET_PV}
		microsoft.netcore.app.host.linux-arm64@${NUGET_PV}
		microsoft.netcore.app.host.linux-musl-arm@${NUGET_PV}
		microsoft.netcore.app.host.linux-musl-arm64@${NUGET_PV}
		microsoft.netcore.app.host.linux-musl-x64@${NUGET_PV}
		microsoft.netcore.app.host.linux-x64@${NUGET_PV}
		microsoft.netcore.app.ref@${NUGET_PV}
		microsoft.netcore.app.runtime.linux-arm@${NUGET_PV}
		microsoft.netcore.app.runtime.linux-arm64@${NUGET_PV}
		microsoft.netcore.app.runtime.linux-musl-arm@${NUGET_PV}
		microsoft.netcore.app.runtime.linux-musl-arm64@${NUGET_PV}
		microsoft.netcore.app.runtime.linux-musl-x64@${NUGET_PV}
		microsoft.netcore.app.runtime.linux-x64@${NUGET_PV}
	"
done

inherit unpacker nuget

DESCRIPTION="dotnet runtime nugets"
HOMEPAGE="https://github.com/dotnet/runtime"
SRC_URI="
	${NUGET_URIS}
"

S="${WORKDIR}"
LICENSE="MIT"
SLOT="$(ver_cut 1-2)"
KEYWORDS="~amd64 ~arm64"
RESTRICT="bindist mirror strip test"

QA_PREBUILT="*"

src_unpack() {
	return
}

src_install() {
	insinto "opt/neptune-dotnet/library-packs"
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
