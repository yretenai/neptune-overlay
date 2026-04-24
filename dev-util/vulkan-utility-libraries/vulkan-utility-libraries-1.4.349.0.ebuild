# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

MY_PN=Vulkan-Utility-Libraries
PYTHON_COMPAT=( python3_{12..14} )
PYTHON_REQ_USE="xml(+)"
inherit cmake-multilib dot-a python-any-r1

if [[ ${PV} == *9999* ]]; then
	EGIT_REPO_URI="https://github.com/KhronosGroup/${MY_PN}.git"
	inherit git-r3
else
	SRC_URI="https://github.com/KhronosGroup/${MY_PN}/archive/refs/tags/v$(ver_cut 0-3).tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~arm64"
	S="${WORKDIR}/${MY_PN}-$(ver_cut 0-3)"
fi

DESCRIPTION="Share code across various Vulkan repositories"
HOMEPAGE="https://github.com/KhronosGroup/Vulkan-Utility-Libraries"

LICENSE="Apache-2.0"
SLOT="0"
IUSE="test"
RESTRICT="!test? ( test )"

DEPEND="~dev-util/vulkan-headers-${PV}
	test? (
		dev-cpp/gtest
		>=dev-cpp/magic_enum-0.9.7
	)"
BDEPEND="${PYTHON_DEPS}"

PATCHES=(
	"${FILESDIR}"/${PN}-1.4.313.0-magic_enum-0.9.7.patch
)

src_configure() {
	lto-guarantee-fat
	multilib-minimal_src_configure
}

multilib_src_configure() {
	local mycmakeargs=(
		-DBUILD_TESTS=$(usex test ON OFF)
	)
	cmake_src_configure
}

multilib_src_install_all() {
	einstalldocs
	strip-lto-bytecode
}
