# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2
EAPI=8

SWIFT_PV="5.9.0"

SWIFT_CHECKOUTS=(
	"Rainbow https://github.com/onevcat/Rainbow e0dada9cd44e3fa7ec3b867e49a8ddbf543e3df3"
	"PathKit https://github.com/kylef/PathKit 3bfd2737b700b9a36565a8c94f4ad2b050a5e574"
	"SwiftCLI https://github.com/jakeheis/SwiftCLI 2e949055d9797c1a6bddcda0e58dada16cc8e970"
	"Spectre https://github.com/kylef/Spectre 26cc5e9ae0947092c7139ef7ba612e34646086c7"
	"Version https://github.com/mxcl/Version 1fe824b80d89201652e7eca7c9252269a1d85e25"
)

SWIFT_ARTIFACTS=(
	"exe mint"
)

DESCRIPTION=""
HOMEPAGE=""
LICENSE=""
SLOT="0"

S="${WORKDIR}/Mint-${PV}"
inherit swift

SRC_URI="
	${SWIFT_URIS}
	https://github.com/yonaskolb/Mint/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz
"
KEYWORDS="~amd64"
	
