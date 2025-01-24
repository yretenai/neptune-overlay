# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{11..12} )
inherit python-single-r1 desktop xdg

DESCRIPTION="Python fitting assistant, cross-platform fitting tool for EVE Online"
HOMEPAGE="https://github.com/pyfa-org/Pyfa"
LICENSE="GPL-3"

if [[ "${PV}" == *beta* ]]; then
	SLOT="sisi"
	SUF="dev1"
	NAME="Singularity"
	EGIT_BRANCH="singularity"
else
	SLOT="tq"
	SUF=""
	NAME="Tranquility"
	EGIT_BRANCH="master"
fi

if [[ "${PV}" == *9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/pyfa-org/Pyfa.git"
else
	SRC_URI="https://github.com/pyfa-org/Pyfa/archive/refs/tags/v${PV}${SUF}.tar.gz -> ${PN}-${PV}${SUF}.tar.gz"
	S="${WORKDIR}/Pyfa-${PV}${SUF}"
	KEYWORDS="~amd64"
fi

RDEPEND="
	${PYTHON_DEPS}
	$(python_gen_cond_dep '
		dev-python/wxpython[webkit,${PYTHON_USEDEP}]
		dev-python/logbook[${PYTHON_USEDEP}]
		dev-python/numpy[${PYTHON_USEDEP}]
		dev-python/matplotlib[${PYTHON_USEDEP}]
		dev-python/python-dateutil[${PYTHON_USEDEP}]
		dev-python/requests[${PYTHON_USEDEP}]
		dev-python/requests-cache[${PYTHON_USEDEP}]
		<dev-python/sqlalchemy-2[${PYTHON_USEDEP}]
		dev-python/cryptography[${PYTHON_USEDEP}]
		dev-python/markdown2[${PYTHON_USEDEP}]
		dev-python/packaging[${PYTHON_USEDEP}]
		dev-python/roman[${PYTHON_USEDEP}]
		dev-python/beautifulsoup4[${PYTHON_USEDEP}]
		dev-python/pyyaml[${PYTHON_USEDEP}]
		dev-python/python-jose[${PYTHON_USEDEP}]
	')
"
DEPEND="${RDEPEND}"
BDEPEND="
	sys-devel/gettext
"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

src_compile() {
	find locale/ -type f -name "*.po" -exec msgen "{}" -o "{}" \;
	${PYTHON} -B scripts/compile_lang.py
	${PYTHON} -B db_update.py
}

src_install() {
	insinto "/opt/pyfa/${SLOT}"
	doins -r eos graphs gui imgs locale service utils eve.db config.py pyfa.py db_update.py README.md LICENSE version.yml
	newicon -s 64 "imgs/gui/pyfa64.png" "pyfa-${SLOT}.png"
	make_desktop_entry "${EPYTHON} -s \"/opt/pyfa/${SLOT}/pyfa.py\"" "Python Fitting Assitant (${NAME})" "pyfa-${SLOT}" Utility Path=/opt/pyfa "GenericName=Pyfa" "DBusActivatable=false" "Terminal=false"
}
