# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

DESCRIPTION="Typesafe hierarchial key-value with inheritance and patching"
HOMEPAGE="https://github.com/SFTtech/nyan"

LICENSE="LGPL-3+"
SLOT="0"

if [[ ${PV} == *9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/SFTtech/nyan.git"
else
	SRC_URI="https://github.com/SFTtech/nyan/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~arm64"
fi
RESTRICT="test"

BDEPEND="
	sys-devel/flex
"

src_prepare() {
	sed -ie "s/nyancat/nyanc/" "nyan/CMakeLists.txt"
	sed -ie "s/cmake_minimum_required(VERSION 3.8.0)/cmake_minimum_required(VERSION 3.10.0)/" CMakeLists.txt
	cmake_src_prepare
}
