# Copyright 2023-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake optfeature xdg-utils git-r3

DESCRIPTION="Chat client for https://twitch.tv, 7tv soft fork"
HOMEPAGE="https://github.com/SevenTV/chatterino7"

EGIT_REPO_URI="https://github.com/SevenTV/chatterino7.git"
if [[ "${PV}" != *9999* ]]; then
	EGIT_COMMIT="v${PV}"
	KEYWORDS="~amd64 ~arm64 ~x86"
fi

S=${WORKDIR}/chatterino7-${PV}

LICENSE="MIT"
SLOT="0"

RDEPEND="
	dev-libs/openssl:=
	dev-libs/qtkeychain:=[qt6]
	dev-qt/qtbase:6[concurrent,dbus,gui,network,widgets]
	dev-qt/qt5compat:6
	dev-qt/qtmultimedia:6
	dev-qt/qtsvg:6
"
DEPEND="
	${RDEPEND}
	dev-libs/boost
"
BDEPEND="dev-qt/qttools:6[linguist]"

PATCHES="
	${FILESDIR}/chatterino7-update-name.patch
"

src_configure() {
	local mycmakeargs=(
		-DUSE_SYSTEM_QTKEYCHAIN=ON
		-DBUILD_WITH_QT6=ON
	)
	cmake_src_configure
}

pkg_postinst() {
	xdg_icon_cache_update
	optfeature "for opening streams in a local video player" net-misc/streamlink
}

pkg_postrm() {
	xdg_icon_cache_update
}
