# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake-multilib

DESCRIPTION="Song information plugin for obs-studio"
HOMEPAGE="https://github.com/univrsal/tuna"

if [[ ${PV} == 9999 ]] ; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/univrsal/tuna.git"
else
	SRC_URI="https://github.com/univrsal/tuna/archive/v${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~arm64"
	S="${WORKDIR}/tuna-${PV}"
fi

LICENSE="GPL-2"
SLOT="0"
IUSE="dbus"

DEPEND="
	>=media-video/obs-studio-30.2.0
	sys-libs/zlib
	net-misc/curl
	media-libs/taglib
	media-libs/libmpdclient
	dev-cpp/cpp-httplib[zlib]
	dbus? ( sys-apps/dbus )
	>=dev-qt/qtbase-6.0.0[widgets]
"

RDEPEND="
	${DEPEND}
"

PATCHES=(
	"${FILESDIR}/tuna-1.9.9-deps.patch"
)

multilib_src_configure() {
	local mycmakeargs+=(
		-DENABLE_QT=ON
		-DWITH_DBUS=$(usex dbus)
	)

	cmake_src_configure
}
