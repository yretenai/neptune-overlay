# Copyright 2022-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{10..13} )
inherit desktop python-any-r1 flag-o-matic scons-utils
inherit shell-completion toolchain-funcs xdg git-r3

DESCRIPTION="Multi-platform 2D and 3D game engine with a feature-rich editor"
HOMEPAGE="https://godotengine.org/"

LICENSE="
	MIT
	Apache-2.0 BSD Boost-1.0 CC0-1.0 Unlicense ZLIB
	gui? ( CC-BY-4.0 ) tools? ( OFL-1.1 )
"
SLOT="${PV}"
EGIT_REPO_URI="https://github.com/godotengine/godot.git"
if [[ "${PV}" != *9999* ]]; then
	EGIT_COMMIT="${PV}-stable"
	KEYWORDS="~amd64"
fi
# Enable roughly same as upstream by default so it works as expected,
# except raycast (tools-only heavy dependency), and deprecated.
IUSE="
	alsa +dbus debug deprecated +fontconfig +gui pulseaudio raycast
	+runner speech test +theora +tools +udev +upnp +vulkan wayland +webp
"
REQUIRED_USE="wayland? ( gui )"
# TODO: tests still need more figuring out
RESTRICT="test"

# mbedtls: "can" use >=mbedtls-3 but the module needs updates handle
# the new tls1.3 default among other things, and the bundled 3.x copy
# builds it #undef MBEDTLS_SSL_PROTO_TLS1_3 + a patch or else will get
# "ERROR: TLS handshake error: -27648" with system's on startup
# https://github.com/godotengine/godot/commit/40fa684c181d
# dlopen: libglvnd
RDEPEND="
	app-arch/brotli:=
	app-arch/zstd:=
	dev-games/recastnavigation:=
	dev-libs/icu:=
	dev-libs/libpcre2:=[pcre32]
	media-libs/freetype[brotli,harfbuzz]
	media-libs/harfbuzz:=[icu]
	media-libs/libogg
	media-libs/libpng:=
	media-libs/libvorbis
	<net-libs/mbedtls-3:=
	net-libs/wslay
	sys-libs/zlib:=
	alsa? ( media-libs/alsa-lib )
	dbus? ( sys-apps/dbus )
	fontconfig? ( media-libs/fontconfig )
	gui? (
		media-libs/libglvnd
		x11-libs/libX11
		x11-libs/libXcursor
		x11-libs/libXext
		x11-libs/libXi
		x11-libs/libXinerama
		x11-libs/libXrandr
		x11-libs/libXrender
		x11-libs/libxkbcommon
		tools? ( raycast? ( media-libs/embree:4 ) )
		vulkan? ( media-libs/vulkan-loader[X,wayland?] )
	)
	pulseaudio? ( media-libs/libpulse )
	speech? ( app-accessibility/speech-dispatcher )
	theora? ( media-libs/libtheora )
	tools? ( app-misc/ca-certificates )
	udev? ( virtual/udev )
	wayland? (
		dev-libs/wayland
		gui-libs/libdecor
	)
	webp? ( media-libs/libwebp:= )
"
DEPEND="
	${RDEPEND}
	gui? ( x11-base/xorg-proto )
	tools? ( test? ( dev-cpp/doctest ) )
"
BDEPEND="
	virtual/pkgconfig
	wayland? ( dev-util/wayland-scanner )
"

PATCHES=(
	"${FILESDIR}"/${PN}-${PV}-scons.patch
)

src_prepare() {
	default

	# handle slotting
	sed -i "1,5s/ godot/&${SLOT}/i" misc/dist/linux/godot.6 || die
	sed -i "/id/s/Godot/&${SLOT}/" misc/dist/linux/org.godotengine.Godot.appdata.xml || die
	sed -e "s/=godot/&${SLOT}/" -e "/^Name=/s/$/ ${SLOT}/" \
		-i misc/dist/linux/org.godotengine.Godot.desktop || die
	sed -e "s/godot/&${SLOT}/g" \
		-i misc/dist/shell/{godot.bash-completion,godot.fish,_godot.zsh-completion} || die

	sed -i "s|pkg-config |$(tc-getPKG_CONFIG) |" platform/linuxbsd/detect.py || die
	sed -e "s/app_id = \"org.godotengine.Editor\"/app_id = \"org.godotengine.Editor${SLOT}\"/g" -i platform/linuxbsd/wayland/display_server_wayland.cpp || die
	sed -e "s/app_id = \"org.godotengine.ProjectManager\"/app_id = \"org.godotengine.ProjectManager${SLOT}\"/g" -i platform/linuxbsd/wayland/display_server_wayland.cpp || die
	sed -e "s/app_id = \"org.godotengine.Godot\"/app_id = \"org.godotengine.Godot${SLOT}\"/g" -i platform/linuxbsd/wayland/display_server_wayland.cpp || die

	# use of builtin_ switches can be messy (see below), delete to be sure
	local unbundle=(
		brotli doctest embree freetype graphite harfbuzz icu4c libogg
		libpng libtheora libvorbis libwebp linuxbsd_headers mbedtls
		pcre2 recastnavigation volk wslay zlib zstd
		# certs: unused by generated header, but scons panics if not found
		# miniupnpc: check if can re-add on bump, bug #934044
	)
	rm -r "${unbundle[@]/#/thirdparty/}" || die

	ln -s "${ESYSROOT}"/usr/include/doctest thirdparty/ || die
}

src_compile() {
	local -x BUILD_NAME=gentoo # replaces "custom_build" in version string

	filter-lto #921017

	local esconsargs=(
		AR="$(tc-getAR)" CC="$(tc-getCC)" CXX="$(tc-getCXX)"

		progress=no
		verbose=yes

		use_sowrap=no

		alsa=$(usex alsa)
		dbus=$(usex dbus)
		deprecated=$(usex deprecated)
		execinfo=no # not packaged, disables crash handler if non-glibc
		fontconfig=$(usex fontconfig)
		opengl3=$(usex gui)
		pulseaudio=$(usex pulseaudio)
		speechd=$(usex speech)
		udev=$(usex udev)
		use_volk=no # unnecessary when linking directly to libvulkan
		vulkan=$(usex gui $(usex vulkan))
		wayland=$(usex wayland)
		# TODO: retry to add optional USE=X, wayland support is new
		# and gui build is not well wired to handle USE="-X wayland" yet
		x11=$(usex gui)

		system_certs_path="${EPREFIX}"/etc/ssl/certs/ca-certificates.crt

		# platform/*/detect.py uses builtin_* switches to check if need
		# to link with system libraries, but many ignore whether the dep
		# is actually used, so "enable" deleted builtins on disabled deps
		builtin_brotli=no
		builtin_certs=no
		builtin_clipper2=yes # not packaged
		builtin_embree=$(usex !gui yes $(usex !tools yes $(usex !raycast)))
		builtin_enet=yes # bundled copy is patched for IPv6+DTLS support
		builtin_freetype=no
		builtin_glslang=yes #879111 (for now, may revisit if more stable)
		builtin_graphite=no
		builtin_harfbuzz=no
		builtin_icu4c=no
		builtin_libogg=no
		builtin_libpng=no
		builtin_libtheora=$(usex !theora)
		builtin_libvorbis=no
		builtin_libwebp=$(usex !webp)
		builtin_mbedtls=no
		builtin_miniupnpc=yes #934044 (for now, should revisit)
		builtin_msdfgen=yes # not wired for unbundling nor packaged
		builtin_openxr=yes # not packaged
		builtin_pcre2=no
		builtin_recastnavigation=no
		builtin_rvo2=yes # bundled copy has godot-specific changes
		builtin_squish=yes # ^ likewise, may not be safe to unbundle
		builtin_wslay=no
		builtin_xatlas=yes # not wired for unbundling nor packaged
		builtin_zlib=no
		builtin_zstd=no
		# (more is bundled in third_party/ but they lack builtin_* switches)

		# modules with optional dependencies, "possible" to disable more but
		# gets messy and breaks all sorts of features (expected enabled)
		module_mono_enabled=no # unhandled
		# note raycast is only enabled on amd64+arm64, see raycast/config.py
		module_raycast_enabled=$(usex gui $(usex tools $(usex raycast)))
		module_theora_enabled=$(usex theora)
		module_upnp_enabled=$(usex upnp)
		module_webp_enabled=$(usex webp)

		# let *FLAGS handle these
		debug_symbols=no
		lto=none
		optimize=custom
		use_static_cpp=no
	)

	if use runner && use tools; then
		# build alternate faster + ~60% smaller binary for running
		# games or servers without game development debug paths
		escons extra_suffix=runner target=template_release "${esconsargs[@]}"
	fi

	esconsargs+=(
		target=$(usex tools editor template_$(usex debug{,} release))
		dev_build=$(usex debug)

		# harmless but note this bakes in --test in the final binary
		tests=$(usex tools $(usex test))
	)

	escons extra_suffix=main "${esconsargs[@]}"
}

src_test() {
	xdg_environment_reset
	bin/godot*.main --headless --test || die
}

src_install() {
	local s=godot${SLOT}

	newbin bin/godot*.main ${s}
	if use runner && use tools; then
		newbin bin/godot*.runner ${s}-runner
	else
		# always available, revdeps shouldn't depend on [runner]
		dosym ${s} /usr/bin/${s}-runner
	fi

	newman misc/dist/linux/godot.6 ${s}.6
	dodoc AUTHORS.md CHANGELOG.md DONORS.md README.md

	if use gui; then
		newicon icon.svg ${s}.svg
		newmenu misc/dist/linux/org.godotengine.Godot.desktop \
			org.godotengine.${s^}.desktop

		insinto /usr/share/metainfo
		newins misc/dist/linux/org.godotengine.Godot.appdata.xml \
			org.godotengine.${s^}.appdata.xml

		insinto /usr/share/mime/application
		newins misc/dist/linux/org.godotengine.Godot.xml \
			org.godotengine.${s^}.xml
	fi

	newbashcomp misc/dist/shell/godot.bash-completion ${s}
	newfishcomp misc/dist/shell/godot.fish ${s}.fish
	newzshcomp misc/dist/shell/_godot.zsh-completion _${s}
}
