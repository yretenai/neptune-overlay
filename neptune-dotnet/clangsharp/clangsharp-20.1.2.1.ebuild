# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

LLVM_COMPAT=( 20 )
inherit cmake llvm-r1

if [[ ${PV} == 9999* ]]; then
	EGIT_REPO_URI="https://github.com/dotnet/ClangSharp.git"
	inherit git-r3
else
	SRC_URI="
		https://github.com/dotnet/ClangSharp/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz
	"
	KEYWORDS="~amd64"
	S="${WORKDIR}/ClangSharp-${PV}"
fi

DESCRIPTION="Clang bindings for .NET written in C#"
HOMEPAGE="https://github.com/dotnet/ClangSharp"

LICENSE="MIT"
SLOT="0"

PATCHES=(
	"${FILESDIR}/${PN}-20.1.2.1-revert-fe454e00.patch"
)

src_configure() {
	local mycmakeargs=(
		-DPATH_TO_LLVM=$(get_llvm_prefix)
	)
	cmake_src_configure
}
