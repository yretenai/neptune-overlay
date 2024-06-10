# Copyright 2023-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2
EAPI=8

inherit meson

DESCRIPTION="pretty view of star constellations"
HOMEPAGE="https://git.vlhl.dev/navi/stargaze"

if [[ ${PV} = *9999* ]] ; then
	inherit git-r3
	EGIT_REPO_URI="https://git.vlhl.dev/navi/stargaze.git"
else
	SRC_URI="https://files.vlhl.dev/src/${P}.tar.gz"
	KEYWORDS="~amd64"
fi

LICENSE="GPL-3"

SLOT="0"

DEPEND="dev-cpp/notcurses"
