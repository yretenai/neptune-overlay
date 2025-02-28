# Copyright 2023-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{11..12} )
DISTUTILS_USE_PEP517=setuptools
inherit python-single-r1

DESCRIPTION="Soundcloud Music Downloader"
HOMEPAGE="https://github.com/scdl-org/scdl"
LICENSE="GPL-2"
SLOT="0"

if [[ "${PV}" == *9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/scdl-org/scdl/${PN}.git"
else
	SRC_URI="https://github.com/scdl-org/scdl/archive/refs/tags/v${PV}.tar.gz -> ${PN}-${PV}.tar.gz"
	KEYWORDS="~amd64"
fi

IUSE="test"

REQUIRED_USE="${PYTHON_REQUIRED_USE}"
RDEPEND="
	${PYTHON_DEPS}
	$(python_gen_cond_dep '
		dev-python/docopt[${PYTHON_USEDEP}]
		media-libs/mutagen[${PYTHON_USEDEP}]
		dev-python/termcolor[${PYTHON_USEDEP}]
		dev-python/requests[${PYTHON_USEDEP}]
		dev-python/tqdm[${PYTHON_USEDEP}]
		dev-python/pathvalidate[${PYTHON_USEDEP}]
		dev-python/soundcloud-v2[${PYTHON_USEDEP}]
		dev-python/filelock[${PYTHON_USEDEP}]
		dev-python/typing-extensions[${PYTHON_USEDEP}]
		dev-python/music-tag[${PYTHON_USEDEP}]
		dev-python/clint[${PYTHON_USEDEP}]
	')
	media-video/ffmpeg
"
DEPEND="${RDEPEND}"
BDEPEND="
	test? (
		dev-util/ruff
		$(python_gen_cond_dep '
			dev-python/pytest[${PYTHON_USEDEP}]
			dev-python/pytest-cov[${PYTHON_USEDEP}]
			dev-python/music-tag[${PYTHON_USEDEP}]
			dev-python/mypy[${PYTHON_USEDEP}]
		')
	)
"

RESTRICT="!test? ( test )"

PATCHES=(
	"${FILESDIR}/${PN}-${PV}-cfg-location.patch"
)

src_prepare() {
	default
	sed -i '1s|^|#!/usr/bin/python\n|' scdl/scdl.py || die
}

src_install() {
	python_domodule scdl
	python_fix_shebang scdl/scdl.py
	python_newscript scdl/scdl.py scdl
	insinto /etc
	doins scdl/scdl.cfg
}
