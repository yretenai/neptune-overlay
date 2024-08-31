# Copyright 2023-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{10..13} )

inherit cmake git-r3 python-any-r1

DESCRIPTION="The WebAssembly Binary Toolkit"
HOMEPAGE="https://github.com/WebAssembly/wabt"

EGIT_REPO_URI="https://github.com/WebAssembly/wabt.git"
if [[ ${PV} != *9999* ]]; then
	EGIT_COMMIT="${PV}"
	KEYWORDS="~amd64 ~arm64 -*"
fi

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"
IUSE="test"

RESTRICT="!test? ( test )"

RDEPEND="dev-libs/openssl:="
DEPEND="
	${RDEPEND}
	test? (
		dev-cpp/gtest
		dev-libs/simde
	)
"
BDEPEND="
	${PYTHON_DEPS}
	$(python_gen_any_dep 'dev-python/ply[${PYTHON_USEDEP}]')
"

python_check_deps() {
	python_has_version "dev-python/ply[${PYTHON_USEDEP}]"
}

src_prepare() {
	cmake_src_prepare

	rm -v fuzz-in/wasm/stuff.wasm || die

	use test || rm -v third_party/wasm-c-api/example/*.wasm || die

	sed -i 's;default_compiler =.*;default_compiler = os.getenv("CC", "cc");' test/run-spec-wasm2c.py || die

	# Broken tests
	rm test/wasm2c/spec/simd_lane.txt test/wasm2c/spec/simd_load.txt
}

src_configure() {
	local mycmakeargs=(
		-DUSE_SYSTEM_GTEST=ON
		-DBUILD_LIBWASM=ON
		-DWITH_WASI=OFF # bundles libuv
		-DBUILD_TESTS=$(usex test)
	)

	cmake_src_configure
}

src_test() {
	cmake_build check
}
