# Copyright 2023-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit meson git-r3

DESCRIPTION="a json parser and json-ld preprocessor"
HOMEPAGE="https://git.vlhl.dev/navi/json"
EGIT_REPO_URI="https://git.vlhl.dev/navi/json.git"

if [[ "${PV}" != *9999* ]]; then
	EGIT_COMMIT="v${PV}"
	KEYWORDS="~amd64"
fi

LICENSE="GPL-3"
SLOT="0"

BDEPEND="
	dev-build/meson
"
