# Copyright 2023-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

MY_PN="${PN/-bin/}"
MY_PV="${PV/-r*/}"
MY_BRANCH="${MY_PN/discord-/}"
MY_PN_RAW="${MY_PN/-${MY_BRANCH}/}"
MY_PN_UC="${MY_PN_RAW^}${MY_BRANCH^}"

CHROMIUM_LANGS="
	af am ar bg bn ca cs da de el en-GB en-US es es-419 et fa fi fil fr gu he hi
	hr hu id it ja kn ko lt lv ml mr ms nb nl pl pt-BR pt-PT ro ru sk sl sr sv
	sw ta te th tr uk ur vi zh-CN zh-TW
"

inherit chromium-2 desktop linux-info optfeature unpacker xdg

DISCORD_MODULE_URI="
	https://canary.dl2.discordapp.net/distro/app/canary/linux/x64/1.0.927/discord_cloudsync/1/full.distro -> ${P}-discord_cloudsync-1.tar.br
	https://canary.dl2.discordapp.net/distro/app/canary/linux/x64/1.0.927/discord_desktop_core/1/full.distro -> ${P}-discord_desktop_core-1.tar.br
	https://canary.dl2.discordapp.net/distro/app/canary/linux/x64/1.0.927/discord_dispatch/1/full.distro -> ${P}-discord_dispatch-1.tar.br
	https://canary.dl2.discordapp.net/distro/app/canary/linux/x64/1.0.927/discord_erlpack/1/full.distro -> ${P}-discord_erlpack-1.tar.br
	https://canary.dl2.discordapp.net/distro/app/canary/linux/x64/1.0.927/discord_game_utils/1/full.distro -> ${P}-discord_game_utils-1.tar.br
	https://canary.dl2.discordapp.net/distro/app/canary/linux/x64/1.0.927/discord_krisp/1/full.distro -> ${P}-discord_krisp-1.tar.br
	https://canary.dl2.discordapp.net/distro/app/canary/linux/x64/1.0.927/discord_modules/1/full.distro -> ${P}-discord_modules-1.tar.br
	https://canary.dl2.discordapp.net/distro/app/canary/linux/x64/1.0.927/discord_rpc/1/full.distro -> ${P}-discord_rpc-1.tar.br
	https://canary.dl2.discordapp.net/distro/app/canary/linux/x64/1.0.927/discord_spellcheck/1/full.distro -> ${P}-discord_spellcheck-1.tar.br
	https://canary.dl2.discordapp.net/distro/app/canary/linux/x64/1.0.927/discord_utils/1/full.distro -> ${P}-discord_utils-1.tar.br
	https://canary.dl2.discordapp.net/distro/app/canary/linux/x64/1.0.927/discord_voice/1/full.distro -> ${P}-discord_voice-1.tar.br
	https://canary.dl2.discordapp.net/distro/app/canary/linux/x64/1.0.927/discord_zstd/1/full.distro -> ${P}-discord_zstd-1.tar.br
"

DISCORD_MODULE="
	discord_cloudsync-1
	discord_desktop_core-1
	discord_dispatch-1
	discord_erlpack-1
	discord_game_utils-1
	discord_krisp-1
	discord_modules-1
	discord_rpc-1
	discord_spellcheck-1
	discord_utils-1
	discord_voice-1
	discord_zstd-1
"

DESCRIPTION="All-in-one voice and text chat for gamers"
HOMEPAGE="https://discordapp.com"
SRC_URI="
	https://dl-${MY_BRANCH}.discordapp.net/apps/linux/${MY_PV}/${MY_PN}-${MY_PV}.tar.gz -> ${P}.tar.gz
	https://${MY_BRANCH}.dl2.discordapp.net/distro/app/${MY_BRANCH}/linux/x64/${MY_PV}/full.distro -> ${P}.full.tar.br
	${DISCORD_MODULE_URI}
"

S="${WORKDIR}/files"
LICENSE="all-rights-reserved"
SLOT="0"
KEYWORDS="~amd64"
IUSE="appindicator +seccomp"
RESTRICT="bindist mirror strip test"

RDEPEND="
	>=app-accessibility/at-spi2-core-2.46.0:2
	app-crypt/libsecret
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/nspr
	dev-libs/nss
	media-libs/alsa-lib
	media-libs/fontconfig
	media-libs/mesa[gbm(+)]
	net-print/cups
	sys-apps/dbus
	sys-apps/util-linux
	sys-libs/glibc
	x11-libs/cairo
	x11-libs/libdrm
	x11-libs/gdk-pixbuf:2
	x11-libs/gtk+:3
	x11-libs/libX11
	x11-libs/libXScrnSaver
	x11-libs/libXcomposite
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXrandr
	x11-libs/libxcb
	x11-libs/libxkbcommon
	x11-libs/libxshmfence
	x11-libs/pango
	appindicator? ( dev-libs/libayatana-appindicator )
"
BDEPEND="
	app-arch/brotli
	app-misc/jq
"

DESTDIR="/opt/${MY_PN}"

QA_PREBUILT="*"

CONFIG_CHECK="~USER_NS"
src_unpack() {
	cd "${DISTDIR}"
	brotli -c --decompress "${DISTDIR}/${P}.full.tar.br" > "${WORKDIR}/${P}.full.tar"

	mkdir -p "${S}/modules/${MODULE}"
	for MODULE in ${DISCORD_MODULE}; do
		brotli -c --decompress "${DISTDIR}/${P}-${MODULE}.tar.br" > "${S}/modules/${MODULE}.tar"
	done

	cd "${WORKDIR}"
	unpacker "${WORKDIR}/${P}.full.tar"
	unpacker "${P}.tar.gz"

	for MODULE in ${DISCORD_MODULE}; do
		cd "${S}/modules"
		unpacker "${S}/modules/${MODULE}.tar"
		rm -f delta_manifest.json "${S}/modules/${MODULE}.tar"
		mv files "${MODULE%-[0-9]*}"
	done
}

src_prepare() {
	cd "${WORKDIR}/${MY_PN_UC}"
	mv "${MY_PN}.desktop" "${MY_PN_RAW}.png" "${S}"

	cd "${S}"
	default

	# fix .desktop exec location
	sed -i "/Exec/s:/usr/share/${MY_PN}/${MY_PN_UC}:${DESTDIR}/${MY_PN_UC}:" \
		"${MY_PN}.desktop" ||
		die "fixing of exec location on .desktop failed"
	# USE seccomp
	if ! use seccomp; then
		sed -i "/Exec/s/${MY_PN_UC}/${MY_PN_UC} --disable-seccomp-filter-sandbox/" \
			"${MY_PN}.desktop" ||
			die "sed failed for seccomp"
	fi
	# fix icon path
	mv "${MY_PN_RAW}.png" "${MY_PN}.png"
}

src_configure() {
	default
	chromium_suid_sandbox_check_kernel_config
}

src_install() {
	doicon -s 256 "${MY_PN}.png"

	# install .desktop file
	domenu "${MY_PN}.desktop"

	exeinto "${DESTDIR}"

	doexe "${MY_PN_UC}" chrome-sandbox libEGL.so libffmpeg.so libGLESv2.so libvk_swiftshader.so libvulkan.so.1

	ewarn
	ewarn "patching build info to point locally, meaning modules will not be updated."
	ewarn "if things break, consider using the proper client installer which installs to .config/${MY_PN}"
	ewarn
	jq ". + { \"localModulesRoot\": \"${DESTDIR}/modules\" }" resources/build_info.json > build_info.json
	mv build_info.json resources/build_info.json

	insinto "${DESTDIR}"
	doins chrome_100_percent.pak chrome_200_percent.pak icudtl.dat resources.pak snapshot_blob.bin v8_context_snapshot.bin
	insopts -m0755
	doins -r locales resources modules

	# Chrome-sandbox requires the setuid bit to be specifically set.
	# see https://github.com/electron/electron/issues/17972
	fowners root "${DESTDIR}/chrome-sandbox"
	fperms 4711 "${DESTDIR}/chrome-sandbox"

	# Crashpad is included in the package once in a while and when it does, it must be installed.
	# See #903616 and #890595
	[[ -x chrome_crashpad_handler ]] && doins chrome_crashpad_handler

	dosym "${DESTDIR}/${MY_PN_UC}" "/usr/bin/${MY_PN}"

	# https://bugs.gentoo.org/898912
	if use appindicator; then
		dosym ../../usr/lib64/libayatana-appindicator3.so ${DESTDIR}/libappindicator3.so
	fi
}

pkg_postinst() {
	xdg_pkg_postinst

	optfeature "sound support" \
		media-sound/pulseaudio media-sound/apulse[sdk] media-video/pipewire
}
