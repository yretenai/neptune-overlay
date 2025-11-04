# Copyright 2023-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{11..14} )
DISTUTILS_USE_PEP517=setuptools
inherit distutils-r1

DESCRIPTION="Python wrapper for v2 SoundCloud API. Does not require an API key. "
HOMEPAGE="https://github.com/7x11x13/soundcloud.py"
LICENSE="MIT"
SLOT="0"

if [[ "${PV}" == *9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/7x11x13/soundcloud.py/${PN}.git"
else
	SRC_URI="https://github.com/7x11x13/soundcloud.py/archive/refs/tags/v${PV}.tar.gz -> ${PN}-${PV}.tar.gz"
	S="${WORKDIR}/soundcloud.py-${PV}"
	KEYWORDS="~amd64 ~arm64"
fi

IUSE="test"

RDEPEND="
	${PYTHON_DEPS}
	$(python_gen_cond_dep '
		dev-python/dacite[${PYTHON_USEDEP}]
		dev-python/python-dateutil[${PYTHON_USEDEP}]
		dev-python/requests[${PYTHON_USEDEP}]
		dev-python/typing-extensions[${PYTHON_USEDEP}]
	')
"

DEPEND="
	${RDEPEND}
"

BDEPEND="
	test? (
		dev-util/ruff
		$(python_gen_cond_dep '
			dev-python/pytest[${PYTHON_USEDEP}]
			dev-python/pytest-cov[${PYTHON_USEDEP}]
			dev-python/mypy[${PYTHON_USEDEP}]
		')
	)
"

RESTRICT="!test? ( test )"
