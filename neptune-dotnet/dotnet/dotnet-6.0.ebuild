# Copyright 2023-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit multilib-build

DESCRIPTION="Virtual for neptune-dotnet"

LICENSE=""

IUSE="+sdk asp doc"

RUNTIME_SLOT="${PV}.0"
SLOT="${PV}/${RUNTIME_SLOT}"
KEYWORDS="~amd64 ~arm ~arm64 -*"

BDEPEND=""

# sdk includes asp, asp includes runtime
RDEPEND="
doc? ( neptune-dotnet/dotnet-man )
|| (
	sdk? ( neptune-dotnet/dotnet-sdk:${SLOT} )
	!sdk? ( asp? ( neptune-dotnet/dotnet-aspnetcore-runtime:${SLOT} ) )
	!sdk? ( !asp? ( neptune-dotnet/dotnet-runtime:${SLOT} ) )
)"
