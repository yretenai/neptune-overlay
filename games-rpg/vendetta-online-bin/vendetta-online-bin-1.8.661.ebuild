# Copyright 2023-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop unpacker

DESCRIPTION="Space-based MMORPG"
HOMEPAGE="https://www.vendetta-online.com"
SRC_URI="
	amd64? (
		http://cdn.vendetta-online.com/vendetta-linux-amd64-installer.sh
			-> ${P}-amd64.sh
	)
	x86? (
		http://cdn.vendetta-online.com/vendetta-linux-ia32-installer.sh
			-> ${P}-x86.sh
	)
"
S="${WORKDIR}"

LICENSE="guild"
SLOT="0"
KEYWORDS="-* ~amd64 ~x86"
RESTRICT="test mirror bindist strip"

RDEPEND="
	media-libs/alsa-lib
	media-libs/libpulse
	virtual/glu
	virtual/opengl
	x86? ( x11-libs/gtk+:2 )
	amd64? ( x11-libs/gtk+:3 )
"
BDEPEND="dev-util/patchelf"

QA_FLAGS_IGNORED="
	opt/vendetta-online-bin/install/drivers/.*.so
	opt/vendetta-online-bin/install/update.rlb
	opt/vendetta-online-bin/install/vendetta
	opt/vendetta-online-bin/vendetta
"

REQUIRED_USE="
	elibc_glibc
"

src_unpack() {
	unpack_makeself
}

src_prepare() {
	# Won't do much good since this is a -bin, but there's no bin_prepare :)
	default

	# scanelf: rpath_security_checks(): Security problem with relative DT_RPATH '.'
	for file in install/drivers/{gkvc.so,soundbackends/libalsa_linux_amd64.so,soundbackends/libpulseaudio_linux_amd64.so} ; do
		patchelf --set-rpath '$ORIGIN' $file || die
	done
}

src_install() {
	local dir=/opt/${PN}

	insinto ${dir}
	doins -r *
	fperms +x ${dir}/{vendetta,install/{update.rlb,vendetta}}

	sed \
		-e "s:DATADIR:${dir}:" \
		"${FILESDIR}"/vendetta > "${T}"/vendetta \
		|| die "sed failed"

	dobin "${T}"/vendetta
	doicon "${FILESDIR}/vendetta-online.png"
	make_desktop_entry vendetta "Vendetta Online" "vendetta-online" "Game"
}
