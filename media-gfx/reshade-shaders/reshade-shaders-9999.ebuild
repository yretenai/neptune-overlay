# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="A collection of post-processing shaders written for ReShade."
HOMEPAGE="https://github.com/crosire/reshade-shaders"

if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/crosire/${PN}.git"
	KEYWORDS=""
else
	echo "only use 9999"; die
fi

LICENSE="CC0-1.0 BSD MIT"
SLOT="0"

src_install() {
	insinto /usr/share/${PN}
	doins -r Shaders Textures
}
