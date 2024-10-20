# Copyright 2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake git-r3

EGIT_SUBMODULES=( )

DESCRIPTION="Collection of computer vision methods for solving geometric vision problems"
HOMEPAGE="https://github.com/laurentkneip/opengv"
EGIT_REPO_URI="https://github.com/laurentkneip/opengv.git"

if [[ ${PV} != *9999* ]]; then
	EGIT_COMMIT="v${PV}"
	KEYWORDS="~amd64 ~ppc64 ~x86"
fi

LICENSE="BSD"
SLOT="0"

DEPEND="
	dev-cpp/eigen:3
"
RDEPEND="${DEPEND}"

PATCHES=(
	"${FILESDIR}/install-paths.patch"
)

src_configure() {
	local mycmakeargs=(
		-DBUILD_TESTS=OFF
		-DBUILD_PYTHON=OFF
	)

	cmake_src_configure
}
