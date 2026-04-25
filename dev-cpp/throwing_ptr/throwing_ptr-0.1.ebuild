# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="A header only library that throws an exception when a null pointer is dereferenced"
HOMEPAGE="https://github.com/rockdreamer/throwing_ptr"

LICENSE="BSL-1.0"
SLOT="0"

if [[ ${PV} == *9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/rockdreamer/throwing_ptr.git"
else
	COMMIT="cd28490ebf9be803497a9fff733de62295d8288e"
	SRC_URI="https://github.com/rockdreamer/throwing_ptr/archive/${COMMIT}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~arm64"
	S="${WORKDIR}/${PN}-${COMMIT}"
fi

RESTRICT="test"

src_install() {
	cd include
	doheader -r throwing
}
