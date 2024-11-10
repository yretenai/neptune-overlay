# Copyright 2022-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{11..13} )
inherit desktop python-any-r1 scons-utils
inherit shell-completion toolchain-funcs xdg git-r3

DESCRIPTION="Multi-platform 2D and 3D game engine with a feature-rich editor"
HOMEPAGE="https://godotengine.org/"

LICENSE="
	MIT
	Apache-2.0 BSD Boost-1.0 CC0-1.0 Unlicense ZLIB BitstreamVera OFL-1.1
	gui? ( CC-BY-4.0 )
"
SLOT="${PV}"
EGIT_REPO_URI="https://github.com/godotengine/godot.git"
if [[ "${PV}" != *9999* ]]; then
	EGIT_COMMIT="${PV}-stable"
	KEYWORDS="~amd64"
fi
# Enable roughly same as upstream by default so it works as expected,
IUSE="
	+bullet debug +deprecated +double-precision +gui pulseaudio
	+raycast +theora +udev +upnp +webm +webp
"

# dlopen: alsa-lib,pulseaudio,udev
RDEPEND="
	app-arch/zstd:=
	dev-games/recastnavigation:=
	dev-libs/libpcre2:=[pcre32]
	media-libs/alsa-lib
	media-libs/freetype[brotli]
	media-libs/libpng:=
	<net-libs/mbedtls-3:=
	net-libs/wslay
	sys-libs/zlib:=
	app-misc/ca-certificates
	bullet? ( sci-physics/bullet:= )
	gui? (
		media-libs/libglvnd
		x11-libs/libX11
		x11-libs/libXcursor
		x11-libs/libXext
		x11-libs/libXi
		x11-libs/libXinerama
		x11-libs/libXrandr
		x11-libs/libXrender
		raycast? ( media-libs/embree:3 )
	)
	pulseaudio? ( media-libs/libpulse )
	theora? (
		media-libs/libogg
		media-libs/libtheora
		media-libs/libvorbis
	)
	udev? ( virtual/udev )
	webm? (
		media-libs/libvorbis
		media-libs/libvpx:=
		media-libs/opus
	)
	webp? ( media-libs/libwebp:= )
"
DEPEND="
	${RDEPEND}
	gui? ( x11-base/xorg-proto )
"
BDEPEND="virtual/pkgconfig"

PATCHES=(
	"${FILESDIR}"/${PN}-${PV}-musl.patch
	"${FILESDIR}"/${PN}-${PV}-scons.patch
)

godot_get_version() {
	export GODOT_VERSION=$(awk -F ' = ' '{
		gsub(/"/, "", $2)
		if ($1 == "major") major = $2
		else if ($1 == "minor") minor = $2
		else if ($1 == "patch") patch = $2
		else if ($1 == "status") status = $2
	} END {
		version = major "." minor
		if (patch != "0") version = version "." patch
		if (status != "stable") version = version "-" status
		print version
	}' version.py)
}

src_prepare() {
	default

	godot_get_version
	local s="-${GODOT_VERSION}"

	# handle slotting
	sed -i "1,5s/ godot/&${s}/i" misc/dist/linux/godot.6 || die
	sed -i "/id/s/Godot/&${s}/" misc/dist/linux/org.godotengine.Godot.appdata.xml || die
	sed -e "s/=godot/&${s}/" -e "/^Name=/s/$/ ${GODOT_VERSION}/" \
		-i misc/dist/linux/org.godotengine.Godot.desktop || die
	sed -e "s/godot/&${s}/g" \
		-i misc/dist/shell/{godot.bash-completion,godot.fish,_godot.zsh-completion} || die

	sed -i "s|pkg-config |$(tc-getPKG_CONFIG) |" platform/{x11,server}/detect.py || die

	# use of builtin_ switches can be messy (see below), delete to be sure
	local unbundle=(
		bullet embree freetype libogg libpng libtheora libvorbis libvpx
		libwebp mbedtls opus pcre2 recastnavigation wslay zlib zstd # miniupnpc
		# certs: unused by generated header, but scons panics if not found
		# miniupnpc: check if can re-add on bump, bug #934044
	)
	rm -r "${unbundle[@]/#/thirdparty/}" || die
}

src_compile() {
	local -x BUILD_NAME=gentoo.neptune # replaces "custom_build" in version string

	local esconsargs=(
		AR="$(tc-getAR)" CC="$(tc-getCC)" CXX="$(tc-getCXX)"

		platform=$(usex gui x11 server)
		progress=no
		verbose=yes
		engine_update_check=no
		precision=$(usex double-precision double single)

		deprecated=$(usex deprecated)
		#execinfo=$(usex !elibc_glibc) # libexecinfo is not packaged
		minizip=yes # uses a modified bundled copy
		pulseaudio=$(usex pulseaudio)
		udev=$(usex udev)

		system_certs_path="${EPREFIX}"/etc/ssl/certs/ca-certificates.crt

		# platform/*/detect.py uses builtin_* switches to check if need
		# to link with system libraries, but ignores whether the dep is
		# actually used, so "enable" deleted builtins on disabled deps
		builtin_bullet=$(usex !bullet)
		builtin_certs=no
		builtin_embree=$(usex !gui yes $(usex !raycast))
		builtin_enet=yes # bundled copy is patched for IPv6+DTLS support
		builtin_freetype=no
		builtin_libogg=yes # unused
		builtin_libpng=no
		builtin_libtheora=$(usex !theora)
		builtin_libvorbis=$(usex !theora $(usex !webm))
		builtin_libvpx=$(usex !webm)
		builtin_libwebp=$(usex !webp)
		builtin_mbedtls=no
		builtin_miniupnpc=yes #934044 (for now, should revisit)
		builtin_opus=$(usex !webm)
		builtin_pcre2=no
		builtin_recast=no
		builtin_rvo2=yes # bundled copy has godot-specific changes
		builtin_squish=yes # ^ likewise, may not be safe to unbundle
		builtin_wslay=no
		builtin_xatlas=yes # not wired for unbundling nor packaged
		builtin_zlib=no
		builtin_zstd=no
		# (more is bundled in third_party/ but they lack builtin_* switches)

		# modules with optional dependencies, "possible" to disable more but
		# gets messy and breaks all sorts of features (expected enabled)
		module_bullet_enabled=$(usex bullet)
		module_mono_enabled=no # unstable
		module_ogg_enabled=no # unused
		module_opus_enabled=no # unused, support is gone and webm uses system's
		# note raycast is disabled on many arches, see raycast/config.py
		module_raycast_enabled=$(usex gui $(usex raycast))
		module_theora_enabled=$(usex theora)
		module_upnp_enabled=$(usex upnp)
		module_vorbis_enabled=no # unused, non-theora/webm uses stb_vorbis
		module_webm_enabled=$(usex webm)
		module_webp_enabled=$(usex webp)

		# let *FLAGS handle these, e.g. can pass -flto as-is
		debug_symbols=no
		lto=none
		optimize=none
		use_static_cpp=no
		disable_exceptions=$(usex debug no yes)

		target=release_debug
		tools=yes
		disable_exceptions=$(usex debug no yes)
	)

	escons extra_suffix=main "${esconsargs[@]}" || die
}

src_install() {
	godot_get_version
	local s="godot-${GODOT_VERSION}"

	newbin bin/godot*.main ${s}

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
