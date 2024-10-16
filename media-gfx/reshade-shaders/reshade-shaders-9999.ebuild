# Copyright 2023-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit git-r3

DESCRIPTION="A collection of post-processing shaders written for ReShade."
HOMEPAGE="https://github.com/crosire/reshade-shaders"
LICENSE="CC0-1.0 BSD MIT"
SLOT="0"

EGIT_REPO_URI="https://github.com/crosire/${PN}.git"

src_install() {
	insinto /usr/share/${PN}
	doins -r Shaders Textures
}
