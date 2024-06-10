# Copyright 2023-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Manpages for dotnet"
HOMEPAGE="https://github.com/dotnet/sdk"

SRC_URI="https://github.com/dotnet/sdk/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

S="${WORKDIR}/sdk-${PV}"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64"

src_install() {
	cd documentation/manpages/sdk
	find . -iname "dotnet*" -type f -exec doman {} \;
}
