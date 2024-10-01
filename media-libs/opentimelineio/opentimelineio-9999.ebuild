# Copyright 2022-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake git-r3

DESCRIPTION="Open Source API and interchange format for editorial timeline information."
HOMEPAGE="
	https://opentimeline.io
	https://github.com/AcademySoftwareFoundation/OpenTimelineIO
"
LICENSE="Apache-2.0"
SLOT="0"

EGIT_REPO_URI="https://github.com/AcademySoftwareFoundation/OpenTimelineIO.git"

if [[ "${PV}" != *9999* ]]; then
	EGIT_COMMIT="v${PV}"
	KEYWORDS="~amd64"
fi

DEPEND="
	dev-libs/imath
"
RDEPEND="${DEPEND}"

src_prepare() {
	eapply_user

	sed -i \
		"s|\(set(OTIO_RESOLVED_CXX_DYLIB_INSTALL_DIR \"\${CMAKE_INSTALL_PREFIX}/\)lib\")|\1$(get_libdir)\")|" \
		CMakeLists.txt || die

	cmake_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DOTIO_AUTOMATIC_SUBMODULES=OFF
		-DOTIO_FIND_IMATH=ON
		-DOTIO_CXX_COVERAGE=OFF
		-DOTIO_CXX_EXAMPLES=OFF
		-DOTIO_CXX_INSTALL=ON
		-DOTIO_DEPENDENCIES_INSTALL=ON
		-DOTIO_INSTALL_COMMANDLINE_TOOLS=ON
		-DOTIO_INSTALL_CONTRIB=OFF
		-DOTIO_PYTHON_INSTALL=OFF
		-DOTIO_SHARED_LIBS=ON
	)
	cmake_src_configure
}
