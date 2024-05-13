EAPI=8

inherit cmake

DESCRIPTION="A decompression library for rar, tar, zip and 7z archives"
HOMEPAGE="http://github.com/selmf/unarr"

if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/selmf/${PN}.git"
else
	SRC_URI="https://github.com/selmf/${PN}/releases/download/v${PV}/${P}.tar.xz"
	KEYWORDS="amd64"
fi

LICENSE="LGPL-3"
SLOT="0"

DEPEND="
	sys-libs/zlib
	app-arch/bzip2
	app-arch/xz-utils
"
RDEPEND="${DEPEND}"
