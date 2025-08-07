# Copyright 2023-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit meson

DESCRIPTION="a bytebeat playback library"
HOMEPAGE="https://git.kimapr.net/kimapr/libbytebeat"
LICENSE="MIT"
SLOT="0"

if [[ "${PV}" == *9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://git.kimapr.net/kimapr/libbytebeat"
else
	SRC_URI="https://git.kimapr.net/kimapr/libbytebeat/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz"
	S="${WORKDIR}/${PN}"
	KEYWORDS="~amd64 ~arm64"
fi

RDEPEND="
	dev-libs/glib:2=
	net-libs/webkit-gtk:6=
"

DEPEND="${RDEPEND}"

BDEPEND="
	app-alternatives/sh
	|| (
		dev-util/xxd
		app-editors/vim-core
	)
	dev-build/meson
	dev-util/pkgconf
"
