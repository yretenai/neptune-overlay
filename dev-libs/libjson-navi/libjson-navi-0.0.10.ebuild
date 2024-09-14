# Copyright 2023-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit meson git-r3

DESCRIPTION="a json parser and json-ld preprocessor"
HOMEPAGE="https://git.vlhl.dev/navi/json"
EGIT_REPO_URI="https://git.vlhl.dev/navi/json.git"
EGIT_COMMIT="c0bcb33d99ff939eb75758f80c948a10ea6733d2" # 10th commit 
KEYWORDS="~amd64"

LICENSE="GPL-3"
SLOT="0"

BDEPEND="
	dev-build/meson
"
