# Copyright 2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Terra is a programming langauge that is embedded in Lua"
HOMEPAGE="
	https://terralang.org/
	https://github.com/terralang/terra/
"
REVISION="cc543db"
SRC_URI="
	amd64? (
		https://github.com/terralang/terra/releases/download/release-${PV}/terra-Linux-x86_64-${REVISION}.tar.xz -> ${PN}-${PV}-amd64.tar.xz
	)
	arm64? (
		https://github.com/terralang/terra/releases/download/release-${PV}/terra-Linux-aarch64-${REVISION}.tar.xz -> ${PN}-${PV}-aarch64.tar.xz
	)
	ppc64? (
		https://github.com/terralang/terra/releases/download/release-${PV}/terra-Linux-ppc64le-${REVISION}.tar.xz -> ${PN}-${PV}-ppc64.tar.xz
	)
"

if [[ "$ARCH" == "amd64" ]]; then
	S="${WORKDIR}/terra-Linux-x86_64-${REVISION}"
elif [[ "$ARCH" == "arm64" ]]; then
	S="${WORKDIR}/terra-Linux-aarch64-${REVISION}"
elif [[ "$ARCH" == "ppc64" ]]; then
	S="${WORKDIR}/terra-Linux-ppc64le-${REVISION}"
fi

LICENSE="MIT"
SLOT="0/$(ver_cut 1-2)"
KEYWORDS="~amd64"

RDEPEND="
	!dev-lang/terra
"

QA_PREBUILT="*"

src_install() {
	dobin bin/terra
	doheader -r include/terra
	dolib.so lib/terra.so lib/libterra.so
	dolib.a lib/libterra_s.a
	insinto usr/share/
	doins -r share/terra
}
