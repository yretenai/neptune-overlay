# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Webgpu Header files"
HOMEPAGE="https://github.com/webgpu-native/webgpu-headers"
LICENSE="BSD"
SLOT="0"

if [[ "${PV}" == *99999999* ]] ; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/webgpu-native/${PN}.git"
else
	COMMIT=
	SRC_URI="https://github.com/webgpu-native/${PN}/archive/${COMMIT}.tar.gz -> ${P}.tar.gz"
	S="${WORKDIR}/${PN}-${COMMIT}"
	KEYWORDS="~amd64 ~x86"
fi

src_prepare() {
	default

	rm "${S}"/Makefile || die
}

src_install() {
	insinto /usr/include/webgpu
	doins "${S}"/webgpu.h
}
