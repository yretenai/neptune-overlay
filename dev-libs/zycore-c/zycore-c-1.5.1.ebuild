# Copyright 2023-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

DESCRIPTION="Internal Zycore library providing a fallback for environments without LibC."
HOMEPAGE="https://github.com/zyantific/zycore-c"
LICENSE="MIT"
SLOT="0"

if [[ ${PV} == *9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/zyantific/zycore-c.git"
else
	SRC_URI="
		https://github.com/zyantific/zycore-c/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz
	"
	S="${WORKDIR}/zycore-c-${PV}"
	KEYWORDS="~amd64"
fi

src_configure() {
	local mycmakeargs=(
		-D ZYCORE_BUILD_SHARED_LIB=ON
		-D ZYCORE_BUILD_EXAMPLES=ON
	)

	cmake_src_configure
}
