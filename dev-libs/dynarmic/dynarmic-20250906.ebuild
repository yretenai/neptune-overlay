# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

DESCRIPTION="An ARM dynamic recompiler"
HOMEPAGE="https://github.com/azahar-emu/dynarmic"

if [[ "${PV}" == *9999* ]] ; then
	inherit git-r3

	EGIT_REPO_URI="https://github.com/azahar-emu/${PN}.git"
else
	COMMIT=cbca2f5761a838e99ee6a9ffde206f9e076569d0
	SRC_URI="https://github.com/azahar-emu/${PN}/archive/${COMMIT}.tar.gz
		-> ${P}.tar.gz"
	S="${WORKDIR}/${PN}-${COMMIT}"

	KEYWORDS="~amd64"
fi

LICENSE="0BSD"
SLOT="0"
IUSE="test"
RESTRICT="!test? ( test )"

RDEPEND="
	dev-cpp/robin-map
	dev-libs/boost:=
	dev-libs/libfmt:=
	dev-libs/mcl
	amd64? ( dev-libs/zydis )
"
DEPEND="
	${RDEPEND}
	amd64? ( >=dev-libs/xbyak-7.25 )
	arm64? ( dev-libs/oaknut )
"
BDEPEND="
	test? (
		dev-cpp/catch
		dev-libs/oaknut
	)
"

PATCHES=(
	"${FILESDIR}/${PN}-6.7.0-add-xbyak-as-a-system-library-rather-than-a-cmake-package.patch"
	"${FILESDIR}/${PN}-6.7.0-relax-the-dependency-on-mcl.patch"
	"${FILESDIR}/${PN}-20250906-zycore.patch"
)

src_prepare() {
	find externals -mindepth 1 -not -path "externals/CMakeLists.txt" -delete

	cmake_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DDYNARMIC_USE_PRECOMPILED_HEADERS=no
		-DDYNARMIC_TESTS=$(usex test)
		-Wno-dev
	)

	cmake_src_configure
}
