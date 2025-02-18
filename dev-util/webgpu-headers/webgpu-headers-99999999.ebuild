# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Webgpu Header files"
HOMEPAGE="https://github.com/webgpu-native/webgpu-headers"
LICENSE="BSD"
SLOT="0"

EGIT_REPO_URI="https://github.com/webgpu-native/${PN}.git"
inherit git-r3

src_prepare() {
	default

	rm "${S}"/Makefile || die
}

src_install() {
	insinto /usr/include/webgpu
	doins "${S}"/webgpu.h
}
