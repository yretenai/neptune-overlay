# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="XDG Thumbnailer for Blender"
HOMEPAGE="https://wiki.gentoo.org/wiki/No_homepage"

S="${WORKDIR}"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="
	media-gfx/blender
	app-eselect/eselect-blender
"

src_install() {
	insinto /usr/share/thumbnailers
	doins "${FILESDIR}/blend.thumbnailer"
}
