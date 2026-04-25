# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake git-r3

DESCRIPTION="The Pattern Language used by the ImHex Hex Editor"
MY_PN="PatternLanguage"
HOMEPAGE="https://github.com/WerWolv/${MY_PN}"
EGIT_SUBMODULES=(
	"*"
	"-external/fmt"
	"-external/cli11"
	"-external/throwing_ptr"
)
EGIT_REPO_URI="https://github.com/WerWolv/${MY_PN}.git"

LICENSE="LGPL-2.1"
SLOT="0"
IUSE="test"
RESTRICT="!test? ( test )"

PATCHES=(
	# Remove -Werror
	"${FILESDIR}/imhex-pattern-language-9999-remove_Werror.patch"
	# Use GNUInstallDirs
	"${FILESDIR}/imhex-pattern-language-9999-install.patch"
)

DEPEND="
	>=dev-cpp/nlohmann_json-3.10.2
	>=dev-libs/libfmt-11.0.2:=
	dev-cpp/cli11
	dev-cpp/throwing_ptr
"
RDEPEND="
	${DEPEND}
	dev-misc/imhex-patterns
"

src_configure() {
	local mycmakeargs=(
		-D LIBPL_ENABLE_TESTS=$(usex test) \
		-D LIBPL_ENABLE_EXAMPLE=OFF \
		-D LIBPL_ENABLE_CLI=ON \
		-D LIBPL_SHARED_LIBRARY=ON \
		-D USE_SYSTEM_FMT=ON \
		-D USE_SYSTEM_NLOHMANN_JSON=ON \
		-D USE_SYSTEM_CLI11=ON
	)

	cmake_src_configure
}

src_install() {
	cd lib/include
	doheader -r pl.hpp pl
	cmake_src_install
}

src_test() {
	cmake_build unit_tests
	cmake_src_test
}
