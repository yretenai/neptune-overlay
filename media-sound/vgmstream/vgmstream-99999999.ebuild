# Copyright 2024-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

DESCRIPTION="A library for playback of various streamed audio formats used in video games"
HOMEPAGE="
	https://github.com/vgmstream/vgmstream
	https://vgmstream.org
"

SRC_URI="
	celt? (
		https://downloads.xiph.org/releases/celt/celt-0.6.1.tar.gz -> celt-061.tar.gz
		https://downloads.xiph.org/releases/celt/celt-0.11.0.tar.gz -> celt-0110.tar.gz
	)
	https://patch-diff.githubusercontent.com/raw/vgmstream/vgmstream/pull/1923.patch -> ${P}-PR1923.patch
"

ATRAC9_EGIT_COMMIT="7406e447c05bb5a99b8c8b22ab747c5a220c6ea3"

if [[ "${PV}" == *99999999* ]]; then
	inherit git-r3

	EGIT_REPO_URI="https://github.com/vgmstream/vgmstream.git"
	ATRAC9_EGIT_REPO_URI="https://github.com/Thealexbarney/LibAtrac9.git"
	ATRAC9_EGIT_LOCAL_ID="${CATEGORY}/${PN}/${SLOT%/*}-atrac9"
else
	SRC_URI+="
		https://github.com/vgmstream/vgmstream/archive/refs/tags/r${PV}.tar.gz -> ${PN}-${PV}.tar.gz
		atrac9? (
			https://github.com/Thealexbarney/LibAtrac9/archive/${ATRAC9_EGIT_COMMIT}.tar.gz -> LibAtrac9-${ATRAC9_EGIT_COMMIT}.tar.gz
		)
	"
	KEYWORDS="~amd64"
fi

LICENSE="GPL-2 MIT"
SLOT="0"

IUSE="+mp3 +vorbis +speex +ffmpeg +g7221 +atrac9 +celt +tools player audacious"
RESTRICT="mirror"

DEPEND="
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

PATCHES=(
	"${DISTDIR}/${P}-PR1923.patch"
)

src_unpack() {
	default

	if [[ "${PV}" == *99999999* ]]; then
		if use atrac9; then
			git-r3_fetch "${ATRAC9_EGIT_REPO_URI}" "${ATRAC9_EGIT_COMMIT}" "${ATRAC9_EGIT_LOCAL_ID}"
			git-r3_checkout "${ATRAC9_EGIT_REPO_URI}" "${WORKDIR}/LibAtrac9-${ATRAC9_EGIT_COMMIT}" "${ATRAC9_EGIT_LOCAL_ID}"
		fi

		git-r3_src_unpack
	fi
}

src_configure() {
	local mycmakeargs=(
		-DUSE_MPEG=$(usex mp3)
		-DUSE_VORBIS=$(usex vorbis)
		-DUSE_FFMPEG=$(usex ffmpeg)
		-DUSE_G7221=$(usex g7221)
		-DUSE_G719=NO
		-DUSE_ATRAC9=$(usex atrac9)
		-DATRAC9_PATH="${WORKDIR}/LibAtrac9-${ATRAC9_EGIT_COMMIT}"
		-DUSE_CELT=$(usex celt)
		-DCELT_0061_PATH="${WORKDIR}/celt-0.6.1"
		-DCELT_0110_PATH="${WORKDIR}/celt-0.11.0"
		-DUSE_SPEEX=$(usex speex)
		-DBUILD_CLI=$(usex tools)
		-DBUILD_V123=$(usex player)
		-DBUILD_AUDACIOUS=$(usex audacious)
	)

	cmake_src_configure
}
