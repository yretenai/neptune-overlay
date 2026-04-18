# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Minimalistic MP3 decoder single header library"
HOMEPAGE="https://github.com/lieff/minimp3"
COMMIT="7b590fdcfa5a79c033e76eacc05d0c3e4c79f536"
SRC_URI="https://github.com/lieff/minimp3/archive/${COMMIT}.zip"
S="${WORKDIR}/${PN}-${COMMIT}"

LICENSE="CC0-1.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
RESTRICT="test"

src_install() {
	doheader minimp3.h minimp3_ex.h
}
