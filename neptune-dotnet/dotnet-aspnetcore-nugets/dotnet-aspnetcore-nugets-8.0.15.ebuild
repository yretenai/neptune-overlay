# Copyright 2023-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

RUNTIME_PV="8.0.15"

NUGETS="
	microsoft.aspnetcore.app.ref@${RUNTIME_PV}
	microsoft.aspnetcore.app.runtime.linux-arm@${RUNTIME_PV}
	microsoft.aspnetcore.app.runtime.linux-arm64@${RUNTIME_PV}
	microsoft.aspnetcore.app.runtime.linux-musl-arm@${RUNTIME_PV}
	microsoft.aspnetcore.app.runtime.linux-musl-arm64@${RUNTIME_PV}
	microsoft.aspnetcore.app.runtime.linux-musl-x64@${RUNTIME_PV}
	microsoft.aspnetcore.app.runtime.linux-x64@${RUNTIME_PV}
"

inherit unpacker nuget

DESCRIPTION="dotnet aspnet core runtime nugets"
HOMEPAGE="https://github.com/dotnet/aspnetcore"
SRC_URI="
	${NUGET_URIS}
"

S="${WORKDIR}"
LICENSE="MIT"
SLOT="$(ver_cut 1-4)/${PV}"
KEYWORDS="~amd64 ~arm ~arm64"
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
