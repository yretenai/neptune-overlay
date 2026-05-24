# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2
EAPI=8

SWIFT_PV="6.0"


SWIFT_ARTIFACTS=(
	"exe swift-bundler"
)

DESCRIPTION="An Xcodeproj-less tool for creating cross-platform Swift apps"
HOMEPAGE="https://swiftbundler.dev/"
LICENSE="Apache-2.0"
SLOT="0"

inherit git-r3 swift
EGIT_REPO_URI="https://github.com/moreSwift/swift-bundler"

KEYWORDS="~amd64"
	
