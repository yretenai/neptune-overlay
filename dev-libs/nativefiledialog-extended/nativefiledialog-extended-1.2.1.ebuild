# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

DESCRIPTION="Cross platform native file dialog library with C and C++ bindings"
HOMEPAGE="https://github.com/btzy/nativefiledialog-extended/"

if [[ ${PV} == *9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/btzy/nativefiledialog-extended.git"
else
	SRC_URI="
		https://github.com/btzy/nativefiledialog-extended/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz
	"
	KEYWORDS="~amd64 ~arm64"
fi

LICENSE="ZLIB"
SLOT="0"
IUSE="+desktop-portal"

DEPEND="
	desktop-portal? ( sys-apps/dbus )
	!desktop-portal? (
		dev-libs/glib:2
		x11-libs/gtk+:3
	)
"
RDEPEND="
	${DEPEND}
	desktop-portal? ( sys-apps/xdg-desktop-portal )
"

src_prepare() {
	eapply_user
	sed -e "s|DESTINATION lib|DESTINATION $(get_libdir)|g" -i src/CMakeLists.txt || die
	cmake_src_prepare
}

src_configure() {
	local mycmakeargs=(
		# tests are non-automated examples that open interactive dialogs
		-DNFD_BUILD_TESTS=no
		-DNFD_PORTAL=$(usex desktop-portal)
	)

	cmake_src_configure
}
