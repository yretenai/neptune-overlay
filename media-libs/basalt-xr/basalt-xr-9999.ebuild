# Copyright 2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake git-r3

EGIT_SUBMODULES=( '*'
	'-thirdparty/opengv'
	'-thirdparty/Pangolin'
	'-thirdparty/CLI11'
	'-thirdparty/magic_enum'
	'-thirdparty/basalt-headers/test/*'
	'-thirdparty/basalt-headers/thirdparty/eigen'
)

DESCRIPTION="Fork of Basalt, improves XR device tracking"
HOMEPAGE="https://gitlab.freedesktop.org/mateosss/basalt"
EGIT_REPO_URI="https://gitlab.freedesktop.org/mateosss/basalt.git"

if [[ ${PV} != *9999* ]]; then
	EGIT_COMMIT="v${PV}"
	KEYWORDS="~amd64 ~ppc64 ~x86"
fi

LICENSE="BSD"
SLOT="0"

IUSE="wayland"

RDEPEND="
	app-arch/bzip2
	app-arch/lz4
	dev-cpp/eigen:3
	dev-libs/boost[bzip2]
	dev-libs/libfmt
	dev-libs/opengv
	dev-libs/pangolin
	media-libs/glew
	media-libs/libepoxy
	media-libs/libjpeg-turbo
	media-libs/libpng
	media-libs/libuvc
	media-libs/mesa[egl(+)]
	media-libs/opencv
	sys-libs/libunwind
	wayland? (
		dev-libs/wayland
		dev-libs/wayland-protocols
		dev-util/wayland-scanner
	)
"
DEPEND="
	dev-cpp/cli11
	dev-cpp/magic_enum
	dev-cpp/nlohmann_json
	${RDEPEND}
"

PATCHES=(
	"${FILESDIR}/basalt-remove-exec.patch"
	"${FILESDIR}/install-paths.patch"
	"${FILESDIR}/thirdparty.patch"
)


src_configure() {
	local mycmakeargs=(
		-DEIGEN_ROOT="${EROOT}/usr/include/eigen3"
		-DEIGEN3_INCLUDE_DIR="${EROOT}/usr/include/eigen3"
		-DBUILD_TESTING=OFF
		-DBASALT_BUILTIN_EIGEN=OFF
	)

	sed -e "s|^ignore_external_warnings|#ignore_external_warnings|" -i thirdparty/basalt-headers/CMakeLists.txt || die

	cmake_src_configure
}
