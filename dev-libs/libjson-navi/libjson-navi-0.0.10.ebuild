# Copyright 2023-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit meson

DESCRIPTION="a json parser and json-ld preprocessor"
HOMEPAGE="https://git.vlhl.dev/navi/json"
LICENSE="LGPL-3"
SLOT="0"

EGIT_COMMIT="c0bcb33d99ff939eb75758f80c948a10ea6733d2" # 10th commit
if [[ ${PV} == *9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://git.vlhl.dev/navi/json.git"
else
	SRC_URI="https://git.vlhl.dev/navi/json.git/snapshot/json-${EGIT_COMMIT}.tar.xz"
	S="${WORKDIR}/json-${EGIT_COMMIT}"
	KEYWORDS="~amd64 ~arm64"
fi

BDEPEND="
	dev-build/meson
"
