EAPI=8

inherit git-r3

DESCRIPTION="A superfast compression library"
HOMEPAGE="https://github.com/g1mv/density"
LICENSE="BSD"
SLOT="0"

EGIT_REPO_URI="https://github.com/g1mv/density.git"
EGIT_SUBMODULES=()

if [[ "${PV}" != *9999* ]]; then
	EGIT_COMMIT="density-${PV}"
	KEYWORDS="~amd64"
fi

PATCHES="
	${FILESDIR}/fixup-makefile.patch
"

src_install() {
	doheader src/density_api.h
	dolib.a build/libdensity.a
	dolib.so build/libdensity.so
}
