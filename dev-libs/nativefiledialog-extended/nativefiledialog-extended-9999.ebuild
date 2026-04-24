# Copyright 2023-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

CMAKE_BUILD_TYPE="Release"

inherit cmake

DESCRIPTION="File dialog library with C and C++ bindings, based on nativefiledialog"
HOMEPAGE="https://github.com/btzy/nativefiledialog-extended"
LICENSE="ZLIB"
SLOT="0/${PV}"

if [[ ${PV} == *9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/btzy/nativefiledialog-extended.git"
else
	SRC_URI="
		https://github.com/btzy/nativefiledialog-extended/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz
	"
	KEYWORDS="~amd64 ~arm64"
fi

IUSE="+desktop-portal test"

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

RESTRICT="!test? ( test )"

src_prepare() {
	eapply_user
	sed -e "s|DESTINATION lib|DESTINATION $(get_libdir)|g" -i src/CMakeLists.txt || die
	cmake_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DNFD_BUILD_TESTS=$(usex test)
		-DNFD_PORTAL=$(usex desktop-portal)
	)
	cmake_src_configure
}
