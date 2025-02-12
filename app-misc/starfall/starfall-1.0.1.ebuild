# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2
EAPI=8

SWIFT_PV="6.0.0"

SWIFT_CHECKOUTS=(
	"swift-docc-plugin https://github.com/swiftlang/swift-docc-plugin 85e4bb4e1cd62cec64a4b8e769dcefdf0c5b9d64"
	"swift-argument-parser https://github.com/apple/swift-argument-parser 41982a3656a71c768319979febd796c6fd111d5c"
	"swift-docc-symbolkit https://github.com/swiftlang/swift-docc-symbolkit b45d1f2ed151d057b54504d653e0da5552844e34"
)

SWIFT_ARTIFACTS=(
	"exe starfall"
)

SWIFT_HAS_RESOURCES=1

inherit swift

DESCRIPTION="pretty view of star constellations"
HOMEPAGE="https://github.com/yretenai/starfall"
LICENSE="GPL-3"
SLOT="0"
SRC_URI="
	https://github.com/yretenai/starfall/archive/refs/tags/v${PV}.tar.gz -> ${PN}-${PV}.tar.gz
	${SWIFT_URIS}
"
KEYWORDS="~amd64"
