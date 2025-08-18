# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{9..14} python3_{13..14}t )
inherit toolchain-funcs python-single-r1

DESCRIPTION="The X86 Encoder Decoder (XED), is a software library for encoding and decoding X86 (IA32 and Intel64) instructions"
HOMEPAGE="https://github.com/intelxed/xed"
SRC_URI="https://github.com/intelxed/xed/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE="debug"

BDEPEND="
	$(python_gen_cond_dep '
		dev-build/mbuild[${PYTHON_USEDEP}]
	')
"

PATCHES=(
	"${FILESDIR}/${PN}-2025.06.08-system-mbuild.patch"
)

src_compile() {
	local mbuildargs=(
		--install-dir ../${PN}_build
		--shared
		--cc "$(tc-getCC)"
		--cxx "$(tc-getCXX)"
		--linker "$(tc-getLD)"
		--ar "$(tc-getAR)"
		--as "$(tc-getAS)"
	)
	if use debug; then
		mbuildargs+=( --debug )
	fi
	if tc-is-clang; then
		mbuildargs+=(--compiler clang)
	fi
	"${EPYTHON}" mfile.py install "${mbuildargs[@]}"
}

src_install() {
	cd ../${PN}_build
	dolib.so lib/libxed.so lib/libxed-ild.so
	doheader -r include/xed
	dodoc misc/cdata.txt misc/idata.txt
}
