# Copyright 2020-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_REQ_USE="tk"
PYTHON_COMPAT=( python3_{10..12} )
inherit python-single-r1

DESCRIPTION="Wwise .bnk explorer and audio simulator"
HOMEPAGE="https://github.com/bnnm/wwiser"

if [[ "${PV}" == *99999999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/bnnm/${PN}.git"
else
	SRC_URI="https://github.com/bnnm/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64"
fi

LICENSE=""
SLOT="0"
RDEPEND=""
DEPEND="${RDEPEND}"

src_compile() {
	python build.py
	echo "#!/usr/bin/env sh
env -S ${EPYTHON} \"${EPREFIX}/usr/bin/wwiser.pyz\"
" > bin/wwiser
}

src_install() {
	dobin bin/wwiser.pyz
	dobin bin/wwiser
}
