# Copyright 2023-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{11..13} )

inherit cmake python-any-r1

DESCRIPTION="The WebAssembly Binary Toolkit"
HOMEPAGE="https://github.com/WebAssembly/wabt"
LICENSE="Apache-2.0"
SLOT="0"

if [[ ${PV} == *9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/WebAssembly/wabt.git"
	EGIT_SUBMODULES=( '-*' third_party/{uvwasi,PicoSHA2,wasm-c-api,testsuite} )
else
	UVWASI_COMMIT=55eff19f4c7e69ec151424a037f951e0ad006ed6
	PICOSHA2_COMMIT=27fcf6979298949e8a462e16d09a0351c18fcaf2
	TESTSUITE_COMMIT=d76759e746f3564a03f6106ae19679742f2a1831
	WASM_C_API_COMMIT=b6dd1fb658a282c64b029867845bc50ae59e1497

	SRC_URI="
		https://github.com/WebAssembly/wabt/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz
		https://github.com/nodejs/uvwasi/archive/${UVWASI_COMMIT}.tar.gz -> uvwasi-${UVWASI_COMMIT}.tar.gz
		https://github.com/okdshin/PicoSHA2/archive/${PICOSHA2_COMMIT}.tar.gz -> PicoSHA2-${PICOSHA2_COMMIT}.tar.gz
		https://github.com/WebAssembly/wasm-c-api/archive/${WASM_C_API_COMMIT}.tar.gz -> wasm-c-api-${WASM_C_API_COMMIT}.tar.gz
		test? (
			https://github.com/WebAssembly/testsuite/archive/${TESTSUITE_COMMIT}.tar.gz -> testsuite-${TESTSUITE_COMMIT}.tar.gz
		)
	"
	KEYWORDS="~amd64"
fi

IUSE="test"

RESTRICT="!test? ( test )"

RDEPEND="
	dev-libs/openssl:=
"
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

src_unpack() {
	default

	if [[ "${PV}" == *9999* ]]; then
		git-r3_src_unpack
	else
		rmdir "${S}/third_party/uvwasi"; mv "${WORKDIR}/uvwasi-${UVWASI_COMMIT}" "${S}/third_party/uvwasi" || die "Cannot move uvwasi"
		rmdir "${S}/third_party/picosha2"; mv "${WORKDIR}/PicoSHA2-${PICOSHA2_COMMIT}" "${S}/third_party/picosha2" || die "Cannot move PicoSHA2"
		rmdir "${S}/third_party/wasm-c-api"; mv "${WORKDIR}/wasm-c-api-${WASM_C_API_COMMIT}" "${S}/third_party/wasm-c-api" || die "Cannot move wasm-c-api"
		if use test; then
			rmdir "${S}/third_party/testsuite"; mv "${WORKDIR}/testsuite-${TESTSUITE_COMMIT}" "${S}/third_party/testsuite" || die "Cannot move testsuite"
		fi
	fi
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
