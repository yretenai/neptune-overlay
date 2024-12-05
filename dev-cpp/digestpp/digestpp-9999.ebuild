# Copyright 2023-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="C++11 header-only message digest library"
HOMEPAGE="https://github.com/kerukuro/digestpp"

LICENSE="Unlicense"
SLOT="0"

if [[ ${PV} == *9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/kerukuro/digestpp.git"
else
	# 44th commit
	SRC_URI="https://github.com/kerukuro/digestpp/archive/873b5bbab87a8a62ea7bf2ea8d26733181a2fe8d.tar.gz -> ${PN}-${PV}.tar.gz"
	S="${WORKDIR}/${PN}-873b5bbab87a8a62ea7bf2ea8d26733181a2fe8d"
	KEYWORDS="~amd64"
fi
RESTRICT="mirror test"

src_install() {
	mkdir digestpp
	mv digestpp.hpp hasher.hpp detail algorithm digestpp
	doheader -r digestpp
}
