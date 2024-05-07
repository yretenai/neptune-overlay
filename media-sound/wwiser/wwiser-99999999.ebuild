# Copyright 1999-2024 Gentoo Authors
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

src_install() {
	python_domodule wwiser
	python_newscript wwiser.py wwiser
	dodoc -r doc
}
