# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# please keep this ebuild at EAPI 8 -- sys-apps/portage dep
EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{11..14} python3_14t pypy3_11 )

inherit distutils-r1

MY_P=certifi-system-store-${PV}
DESCRIPTION="A certifi hack to use system trust store on Linux/FreeBSD"
HOMEPAGE="
	https://github.com/projg2/certifi-system-store/
	https://github.com/tiran/certifi-system-store/
	https://pypi.org/project/certifi-system-store/
"
SRC_URI="
	https://github.com/projg2/certifi-system-store/archive/v${PV}.tar.gz
		-> ${MY_P}.gh.tar.gz
"
S=${WORKDIR}/${MY_P}

LICENSE="MPL-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="
	app-misc/ca-certificates
"

EPYTEST_IGNORE=(
	# requires Internet
	tests/test_requests.py
)

distutils_enable_tests pytest

src_prepare() {
	sed -i -e "s^/etc^${EPREFIX}/etc^" src/certifi/core.py || die
	distutils-r1_src_prepare
}
