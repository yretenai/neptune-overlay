# Copyright 2023-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2
EAPI=8

inherit meson git-r3

DESCRIPTION="pretty view of star constellations"
HOMEPAGE="https://git.vlhl.dev/navi/stargaze"
LICENSE="GPL-3"
SLOT="0"

EGIT_REPO_URI="https://git.vlhl.dev/navi/stargaze.git"

if [[ "${PV}" != *9999* ]]; then
	EGIT_COMMIT="v${PV}"
	KEYWORDS="~amd64"
fi

DEPEND="dev-cpp/notcurses"
