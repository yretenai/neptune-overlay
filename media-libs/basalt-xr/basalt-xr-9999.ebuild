# Copyright 2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake git-r3

DESCRIPTION="Fork of Basalt, improves XR device tracking"
HOMEPAGE="https://gitlab.freedesktop.org/mateosss/basalt"
# this has A LOT of random dependencies, and I don't really know if I want to unpack all of them
EGIT_REPO_URI="https://gitlab.freedesktop.org/mateosss/basalt.git"
LICENSE="BSD"
SLOT="0"

IUSE="wayland"

DEPEND="
	media-libs/mesa[egl(+)]
	dev-cpp/eigen:3
	media-libs/glew
	media-libs/libjpeg-turbo
	media-libs/libpng
	app-arch/lz4
	app-arch/bzip2
	dev-libs/boost[bzip2]
	media-libs/opencv
	sys-libs/libunwind
	media-libs/libepoxy
	dev-libs/libfmt
	media-libs/libuvc
	wayland? (
		dev-libs/wayland
		dev-libs/wayland-protocols
		dev-util/wayland-scanner
	)
	!media-libs/basalt
"
RDEPEND="${DEPEND}"

PATCHES=(
	"${FILESDIR}/basalt-remove-exec.patch"
	"${FILESDIR}/install-paths.patch"
)


src_configure() {
	local mycmakeargs=(
		-DEIGEN_ROOT="${EROOT}/usr/include/eigen3"
	)

	cmake_src_configure
}
