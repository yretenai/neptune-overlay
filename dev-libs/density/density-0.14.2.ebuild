EAPI=8

DESCRIPTION="A superfast compression library"
HOMEPAGE="https://github.com/g1mv/density"
SRC_URI="
	https://github.com/g1mv/density/archive/refs/tags/density-${PV}.tar.gz
"
S="${WORKDIR}/${PN}-density-${PV}"
LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

PATCHES=(
	"${FILESDIR}/fixup-makefile.patch"
)

src_install() {
	doheader src/density_api.h
	dolib.a build/libdensity.a
	dolib.so build/libdensity.so
}
