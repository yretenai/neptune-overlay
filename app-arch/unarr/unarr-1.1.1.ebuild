EAPI=8

inherit cmake git-r3

DESCRIPTION="A decompression library for rar, tar, zip and 7z archives"
HOMEPAGE="http://github.com/selmf/unarr"
LICENSE="LGPL-3"
SLOT="0"

EGIT_REPO_URI="https://github.com/selmf/unarr.git"

if [[ "${PV}" != *9999* ]]; then
	EGIT_COMMIT="v${PV}"
	KEYWORDS="~amd64"
fi

DEPEND="
	sys-libs/zlib
	app-arch/bzip2
	app-arch/xz-utils
"
RDEPEND="${DEPEND}"
