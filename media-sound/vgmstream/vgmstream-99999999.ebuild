# Copyright 2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake git-r3

DESCRIPTION="A library for playback of various streamed audio formats used in video games"
HOMEPAGE="
	https://github.com/vgmstream/vgmstream
	https://vgmstream.org
"

EGIT_REPO_URI="https://github.com/vgmstream/vgmstream.git"
ATRAC9_EGIT_REPO_URI="https://github.com/Thealexbarney/LibAtrac9.git"
ATRAC9_EGIT_COMMIT="7406e447c05bb5a99b8c8b22ab747c5a220c6ea3"
ATRAC9_EGIT_LOCAL_ID="${CATEGORY}/${PN}/${SLOT%/*}-atrac9"
G719_EGIT_REPO_URI="https://github.com/kode54/libg719_decode.git"
G719_EGIT_COMMIT="da90ad8a676876c6c47889bcea6a753f9bbf7a73"
G719_EGIT_LOCAL_ID="${CATEGORY}/${PN}/${SLOT%/*}-g719"

SRC_URI="
	celt? (
		https://downloads.xiph.org/releases/celt/celt-0.6.1.tar.gz -> celt-061.tar.gz
		https://downloads.xiph.org/releases/celt/celt-0.11.0.tar.gz -> celt-0110.tar.gz
	)
"

if [[ "${PV}" != *99999999* ]]; then
	EGIT_COMMIT="r${PV}"
	KEYWORDS="~amd64"
fi

LICENSE="GPL-2 MIT"
SLOT="0"

IUSE="+mp3 +vorbis +speex +ffmpeg +g7221 +g719 +atrac9 +celt +json +tools player audacious"
RESTRICT="mirror"

DEPEND="
	json? ( dev-libs/jansson )
	mp3? ( media-sound/mpg123 )
	vorbis? ( media-libs/libvorbis )
	speex? ( media-libs/speex )
	ffmpeg? ( media-video/ffmpeg )
	player? ( media-libs/libao )
	audacious? (
		media-libs/libao
		media-sound/audacious
	)
"

RDEPEND=$DEPEND

BDEPEND="
	dev-lang/yasm
"

src_unpack() {
	if use atrac9; then
		git-r3_fetch "${ATRAC9_EGIT_REPO_URI}" "${ATRAC9_EGIT_COMMIT}" "${ATRAC9_EGIT_LOCAL_ID}"
		git-r3_checkout "${ATRAC9_EGIT_REPO_URI}" "${WORKDIR}/atrac9" "${ATRAC9_EGIT_LOCAL_ID}"
	fi

	if use g719; then
		git-r3_fetch "${G719_EGIT_REPO_URI}" "${G719_EGIT_COMMIT}" "${G719_EGIT_LOCAL_ID}"
		git-r3_checkout "${G719_EGIT_REPO_URI}" "${WORKDIR}/g719" "${G719_EGIT_LOCAL_ID}"
	fi

	if use celt; then
		unpack celt-061.tar.gz
		unpack celt-0110.tar.gz
	fi

	git-r3_src_unpack
}

src_configure() {
	local mycmakeargs=(
		-DUSE_MPEG=$(usex mp3)
		-DUSE_VORBIS=$(usex vorbis)
		-DUSE_FFMPEG=$(usex ffmpeg)
		-DUSE_G7221=$(usex g7221)
		-DUSE_G719=$(usex g719)
		-DG719_PATH="${WORKDIR}/g719"
		-DUSE_ATRAC9=$(usex atrac9)
		-DATRAC9_PATH="${WORKDIR}/atrac9"
		-DUSE_CELT=$(usex celt)
		-DCELT_0061_PATH="${WORKDIR}/celt-0.6.1"
		-DCELT_0110_PATH="${WORKDIR}/celt-0.11.0"
		-DUSE_SPEEX=$(usex speex)
		-DUSE_JANSSON=$(usex json)
		-DBUILD_CLI=$(usex tools)
		-DBUILD_V123=$(usex player)
		-DBUILD_AUDACIOUS=$(usex audacious)
	)

	cmake_src_configure
}
