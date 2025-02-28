# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Webgpu Header files"
HOMEPAGE="https://github.com/webgpu-native/webgpu-headers"
LICENSE="BSD"
SLOT="0"

COMMIT="bac520839ff5ed2e2b648ed540bd9ec45edbccbc"
SRC_URI="https://github.com/webgpu-native/${PN}/archive/${COMMIT}.tar.gz -> ${P}.tar.gz"
KEYWORDS="~amd64 ~x86"
S="${WORKDIR}/${PN}-${COMMIT}"

src_prepare() {
	default

	rm "${S}"/Makefile || die
}

src_install() {
	insinto /usr/include/webgpu
	doins "${S}"/webgpu.h
}
