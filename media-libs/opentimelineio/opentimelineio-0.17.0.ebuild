# Copyright 2022-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{10..13} )
DISTUTILS_EXT=1
DISTUTILS_USE_PEP517=setuptools
inherit cmake distutils-r1 pypi

DESCRIPTION="Open Source API and interchange format for editorial timeline information."
HOMEPAGE="
	https://opentimeline.io
	https://github.com/AcademySoftwareFoundation/OpenTimelineIO
"
LICENSE="Apache-2.0"
SLOT="0"

if [[ ${PV} == *9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/AcademySoftwareFoundation/OpenTimelineIO.git"
	EGIT_SUBMODULES=()
else
	KEYWORDS="~amd64"
fi


RDEPEND="
	dev-libs/imath
	dev-python/pyside2[${PYTHON_USEDEP}]
"
RDEPEND="${DEPEND}"
BDEPEND="
	dev-libs/rapidjson
"

python_prepare_all() {
	sed -re '/.*: OTIO_build_ext,/d' -i setup.py
	sed -i \
		"s|\(set(OTIO_RESOLVED_CXX_DYLIB_INSTALL_DIR \"\${CMAKE_INSTALL_PREFIX}/\)lib\")|\1$(get_libdir)\")|" \
		CMakeLists.txt || die
	cmake_src_prepare
	distutils-r1_python_prepare_all
}

python_configure() {
	local mycmakeargs=(
		-DOTIO_AUTOMATIC_SUBMODULES=OFF
		-DOTIO_FIND_IMATH=ON
		-DOTIO_CXX_COVERAGE=OFF
		-DOTIO_CXX_EXAMPLES=OFF
		-DOTIO_CXX_INSTALL=ON
		-DOTIO_DEPENDENCIES_INSTALL=OFF
		-DOTIO_SHARED_LIBS=ON
		-DOTIO_INSTALL_COMMANDLINE_TOOLS=ON
		-DOTIO_INSTALL_CONTRIB=OFF
		-DOTIO_INSTALL_PYTHON_MODULES=OFF
		-DOTIO_PYTHON_INSTALL=ON
		-DOTIO_PYTHON_INSTALL_DIR="$(python_get_sitedir)"
		-DPython_EXECUTABLE="${PYTHON}"
	)
	cmake_src_configure
}

python_compile() {
	cmake_src_compile
	distutils-r1_python_compile
}

python_install() {
	cmake_src_install
	distutils-r1_python_install
}
