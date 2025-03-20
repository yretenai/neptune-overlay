EAPI=8

inherit cmake

DESCRIPTION="A decompression library for rar, tar, zip and 7z archives"
HOMEPAGE="http://github.com/selmf/unarr"
LICENSE="LGPL-3"
SLOT="0"

if [[ ${PV} == *9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="http://github.com/selmf/unarr.git"
else
	SRC_URI="http://github.com/selmf/unarr/archive/v${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64"
	S="${WORKDIR}/${PN}-${PV}"
fi

DEPEND="
	sys-libs/zlib
	app-arch/bzip2
	app-arch/xz-utils
"
RDEPEND="${DEPEND}"
