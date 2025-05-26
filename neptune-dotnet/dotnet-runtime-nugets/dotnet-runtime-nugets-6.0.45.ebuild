# Copyright 2023-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

NUGET_PVS="6.0.36 6.0.35 6.0.33 6.0.32 6.0.31 6.0.30 6.0.29 6.0.28 6.0.27 6.0.26 6.0.25 6.0.24 6.0.23 6.0.22 6.0.21 6.0.20 6.0.19 6.0.18 6.0.16 6.0.15 6.0.14 6.0.13 6.0.12 6.0.11 6.0.10 6.0.9 6.0.8 6.0.7 6.0.6 6.0.5 6.0.4 6.0.3 6.0.2 6.0.1 6.0.0 "
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
