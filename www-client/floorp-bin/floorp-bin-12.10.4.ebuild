# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

MOZ_PN="${PN%-bin}"

inherit desktop linux-info optfeature pax-utils xdg

DESCRIPTION="Floorp Browser, a Firefox Fork"
HOMEPAGE="
	https://floorp.app/
	https://github.com/Floorp-Projects/Floorp
"
SRC_URI="amd64? ( https://github.com/Floorp-Projects/Floorp/releases/download/v${PV}/floorp-linux-x86_64.tar.xz -> ${PN}-amd64-${PV}.tar.xz )
	arm64? ( https://github.com/Floorp-Projects/Floorp/releases/download/v${PV}/floorp-linux-aarch64.tar.xz -> ${PN}-arm64-${PV}.tar.xz )"

KEYWORDS="-* amd64 ~arm64"
LICENSE="MPL-2.0 GPL-2 LGPL-2.1"
IUSE="+gmp-autoupdate selinux wayland"
SLOT="0"

RESTRICT="mirror strip"

BDEPEND="app-arch/unzip"
RDEPEND="${DEPEND}
	|| (
		media-libs/libpulse
		media-sound/apulse
	)
	>=app-accessibility/at-spi2-core-2.46.0:2
	>=dev-libs/glib-2.26:2
	media-libs/alsa-lib
	media-libs/fontconfig
	>=media-libs/freetype-2.4.10
	media-video/ffmpeg
	sys-apps/dbus
	virtual/freedesktop-icon-theme
	>=x11-libs/cairo-1.10[X]
	x11-libs/gdk-pixbuf:2
	>=x11-libs/gtk+-3.11:3[X,wayland?]
	x11-libs/libX11
	x11-libs/libXcomposite
	x11-libs/libXcursor
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXi
	x11-libs/libXrandr
	x11-libs/libXrender
	x11-libs/libxcb
	>=x11-libs/pango-1.22.0
	selinux? ( sec-policy/selinux-mozilla )
"

QA_PREBUILT="opt/${MOZ_PN}/*"

# Allow MOZ_GMP_PLUGIN_LIST to be set in an eclass or
# overridden in the enviromnent (advanced hackers only)
if [[ -z "${MOZ_GMP_PLUGIN_LIST+set}" ]] ; then
	MOZ_GMP_PLUGIN_LIST=( gmp-gmpopenh264 gmp-widevinecdm )
fi

pkg_setup() {
	CONFIG_CHECK="~SECCOMP"
	WARNING_SECCOMP="CONFIG_SECCOMP not set! This system will be unable to play DRM-protected content."

	linux-info_pkg_setup
}

src_unpack() {
	local _lp_dir="${WORKDIR}/language_packs"
	local _src_file

	mkdir "${S}" || die

	if [[ ! -d "${_lp_dir}" ]] ; then
		mkdir "${_lp_dir}" || die
	fi

	for _src_file in ${A} ; do
		if [[ ${_src_file} == *.xpi ]]; then
			cp "${DISTDIR}/${_src_file}" "${_lp_dir}" || die "Failed to copy '${_src_file}' to '${_lp_dir}'!"
		else
			MY_SRC_FILE=${_src_file}
		fi
	done
}

src_install() {
	# Set MOZILLA_FIVE_HOME
	local MOZILLA_FIVE_HOME="/opt/${MOZ_PN}"

	dodir /opt
	pushd "${ED}"/opt &>/dev/null || die
	unpack "${MY_SRC_FILE}"
	popd &>/dev/null || die

	pax-mark m \
		"${ED}${MOZILLA_FIVE_HOME}"/${MOZ_PN} \
		"${ED}${MOZILLA_FIVE_HOME}"/${MOZ_PN}-bin \
		"${ED}${MOZILLA_FIVE_HOME}"/plugin-container

	# Install policy (currently only used to disable application updates)
	insinto "${MOZILLA_FIVE_HOME}/distribution"
	newins "${FILESDIR}"/disable-auto-update.policy.json policies.json

	# Install system-wide preferences
	local PREFS_DIR="${MOZILLA_FIVE_HOME}/browser/defaults/preferences"
	insinto "${PREFS_DIR}"
	newins "${FILESDIR}"/gentoo-default-prefs.js all-gentoo.js

	local GENTOO_PREFS="${ED}${PREFS_DIR}/all-gentoo.js"

	if ! use gmp-autoupdate ; then
		local plugin
		for plugin in "${MOZ_GMP_PLUGIN_LIST[@]}" ; do
			einfo "Disabling auto-update for ${plugin} plugin ..."
			cat >>"${GENTOO_PREFS}" <<-EOF || die "failed to disable autoupdate for ${plugin} media plugin"
			pref("media.${plugin}.autoupdate",   false);
			EOF
		done
	fi

	# Install icons
	local icon_srcdir="${ED}/${MOZILLA_FIVE_HOME}/browser/chrome/icons/default"
	local icon_symbolic_file="${FILESDIR}/floorp-symbolic.svg"

	insinto /usr/share/icons/hicolor/symbolic/apps
	newins "${icon_symbolic_file}" ${PN}-symbolic.svg

	local icon size
	for icon in "${icon_srcdir}"/default*.png ; do
		size=${icon%.png}
		size=${size##*/default}

		if [[ ${size} -eq 48 ]] ; then
			newicon "${icon}" ${PN}.png
		fi

		newicon -s ${size} "${icon}" ${PN}.png
	done

	# Install menu
	local app_name="${MOZ_PN^} (bin)"
	local desktop_file="${FILESDIR}/${PN}-r3.desktop"
	local desktop_filename="${PN}.desktop"
	local exec_command="${PN} --name=floorp-bin"
	local icon="${PN}"
	local use_wayland="false"

	if use wayland ; then
		use_wayland="true"
	fi

	cp "${desktop_file}" "${WORKDIR}/${PN}.desktop-template" || die

	# Add apulse support through our wrapper shell launcher, patchelf-method broken since 119.0.
	# See bgo#916230, bgo#941873
	local apulselib=
	if has_version -r media-sound/apulse[-sdk] ; then
		apulselib="${EPREFIX}/usr/$(get_libdir)/apulse"
		ewarn "media-sound/apulse with -sdk use flag detected!"
		ewarn "Floorp-bin will be installed with a wrapper, that attempts to load"
		ewarn "apulse instead of pipewire/pulseadio. This may lead to sound issues."
		ewarn "Please either enable sdk use flag for apulse, or remove apulse"
		ewarn "completely and re-install floorp-bin to utilize pipewire/pulseaudio instead."
	fi

	sed -i \
		-e "s:@NAME@:${app_name}:" \
		-e "s:@EXEC@:${exec_command}:" \
		-e "s:@ICON@:${icon}:" \
		"${WORKDIR}/${PN}.desktop-template" \
		|| die

	newmenu "${WORKDIR}/${PN}.desktop-template" "${desktop_filename}"

	rm "${WORKDIR}/${PN}.desktop-template" || die

	# Install wrapper script
	[[ -f "${ED}/usr/bin/${PN}" ]] && rm "${ED}/usr/bin/${PN}"
	newbin "${FILESDIR}/${PN}-r1.sh" ${PN}

	# Update wrapper
	sed -i \
		-e "s:@PREFIX@:${EPREFIX}/usr:" \
		-e "s:@MOZ_FIVE_HOME@:${EPREFIX}${MOZILLA_FIVE_HOME}:" \
		-e "s:@APULSELIB_DIR@:${apulselib}:" \
		-e "s:@DEFAULT_WAYLAND@:${use_wayland}:" \
		"${ED}/usr/bin/${PN}" \
		|| die
}

pkg_postinst() {
	xdg_pkg_postinst

	if ! use gmp-autoupdate ; then
		elog "USE='-gmp-autoupdate' has disabled the following plugins from updating or"
		elog "installing into new profiles:"
		local plugin
		for plugin in "${MOZ_GMP_PLUGIN_LIST[@]}" ; do
			elog "\t ${plugin}"
		done
		elog
	fi

	local show_doh_information show_normandy_information

	if [[ -z "${REPLACING_VERSIONS}" ]] ; then
		# New install; Tell user that DoH is disabled by default
		show_doh_information=yes
	fi

	if [[ -n "${show_doh_information}" ]] ; then
		elog
		elog "Note regarding Trusted Recursive Resolver aka DNS-over-HTTPS (DoH):"
		elog "Due to privacy concerns (encrypting DNS might be a good thing, sending all"
		elog "DNS traffic to Cloudflare by default is not a good idea and applications"
		elog "should respect OS configured settings), \"network.trr.mode\" was set to 5"
		elog "(\"Off by choice\") by default."
		elog "You can enable DNS-over-HTTPS in ${PN^}'s preferences."
	fi

	optfeature_header "Optional programs for extra features:"
	optfeature "speech syntesis (text-to-speech) support" app-accessibility/speech-dispatcher
	optfeature "fallback mouse cursor theme e.g. on WMs" gnome-base/gsettings-desktop-schemas
	# optfeature "ffmpeg-based audio/video codec support, required for HTML5 video rendering" media-video/ffmpeg
	optfeature "desktop notifications" x11-libs/libnotify
}
