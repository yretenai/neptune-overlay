# Copyright 2022-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DOTNET_PKG_COMPAT=8.0
DOTNET_NEPTUNE_TARGETS=( 8.0 )
DOTNET_NEPTUNE_NUGET_LEVELS=( 8.0.12 )
DOTNET_NEPTUNE_PROJECT_ROOT=modules/mono
DOTNET_NEPTUNE_SOLUTIONS=( editor/Godot.NET.Sdk/Godot.NET.Sdk.sln editor/GodotTools/GodotTools.sln glue/GodotSharp/GodotSharp.sln )
DOTNET_NEPTUNE_OPTIONAL=1

# run godot-nugets.bash
NUGETS="
coverlet.collector@3.2.0
diffplex@1.5.0
envdte@17.8.37221
humanizer.core@2.14.1
humanizer.core@2.2.0
jetbrains.annotations@2019.1.3
jetbrains.rider.pathlocator@1.0.9
microsoft.bcl.asyncinterfaces@5.0.0
microsoft.bcl.asyncinterfaces@7.0.0
microsoft.build.framework@15.1.548
microsoft.build.locator@1.2.6
microsoft.build.notargets@2.0.1
microsoft.build@15.1.548
microsoft.codeanalysis.analyzer.testing@1.1.1
microsoft.codeanalysis.analyzers@2.6.1
microsoft.codeanalysis.analyzers@3.3.2
microsoft.codeanalysis.analyzers@3.3.4
microsoft.codeanalysis.codefix.testing@1.1.1
microsoft.codeanalysis.common@3.11.0
microsoft.codeanalysis.common@4.8.0
microsoft.codeanalysis.csharp.analyzer.testing.xunit@1.1.1
microsoft.codeanalysis.csharp.analyzer.testing@1.1.1
microsoft.codeanalysis.csharp.codefix.testing.xunit@1.1.1
microsoft.codeanalysis.csharp.codefix.testing@1.1.1
microsoft.codeanalysis.csharp.sourcegenerators.testing.xunit@1.1.1
microsoft.codeanalysis.csharp.sourcegenerators.testing@1.1.1
microsoft.codeanalysis.csharp.workspaces@3.11.0
microsoft.codeanalysis.csharp.workspaces@4.8.0
microsoft.codeanalysis.csharp@3.11.0
microsoft.codeanalysis.csharp@4.8.0
microsoft.codeanalysis.sourcegenerators.testing@1.1.1
microsoft.codeanalysis.testing.verifiers.xunit@1.1.1
microsoft.codeanalysis.workspaces.common@1.0.1
microsoft.codeanalysis.workspaces.common@3.11.0
microsoft.codeanalysis.workspaces.common@3.8.0
microsoft.codeanalysis.workspaces.common@4.8.0
microsoft.codecoverage@17.7.1
microsoft.net.test.sdk@17.7.1
microsoft.netcore.platforms@1.1.0
microsoft.netcore.targets@1.1.0
microsoft.netframework.referenceassemblies.net461@1.0.0
microsoft.netframework.referenceassemblies@1.0.0
microsoft.testplatform.objectmodel@17.7.1
microsoft.testplatform.testhost@17.7.1
microsoft.visualstudio.composition.netfxattributes@16.1.8
microsoft.visualstudio.composition@16.1.8
microsoft.visualstudio.interop@17.8.37221
microsoft.visualstudio.validation@15.0.82
netstandard.library@1.6.1
netstandard.library@2.0.3
newtonsoft.json@13.0.1
newtonsoft.json@9.0.1
nuget.common@5.6.0
nuget.configuration@5.6.0
nuget.frameworks@5.6.0
nuget.frameworks@6.12.1
nuget.frameworks@6.5.0
nuget.packaging@5.6.0
nuget.protocol@5.6.0
nuget.resolver@5.6.0
nuget.versioning@5.6.0
reflectionanalyzers@0.1.22-dev
runtime.any.system.collections@4.3.0
runtime.any.system.diagnostics.tools@4.3.0
runtime.any.system.globalization@4.3.0
runtime.any.system.io@4.3.0
runtime.any.system.reflection.extensions@4.3.0
runtime.any.system.reflection.primitives@4.3.0
runtime.any.system.reflection@4.3.0
runtime.any.system.resources.resourcemanager@4.3.0
runtime.any.system.runtime@4.3.0
runtime.any.system.text.encoding@4.3.0
runtime.any.system.threading.tasks@4.3.0
runtime.debian.8-x64.runtime.native.system.security.cryptography.openssl@4.3.0
runtime.fedora.23-x64.runtime.native.system.security.cryptography.openssl@4.3.0
runtime.fedora.24-x64.runtime.native.system.security.cryptography.openssl@4.3.0
runtime.native.system.security.cryptography.openssl@4.3.0
runtime.native.system@4.3.0
runtime.opensuse.13.2-x64.runtime.native.system.security.cryptography.openssl@4.3.0
runtime.opensuse.42.1-x64.runtime.native.system.security.cryptography.openssl@4.3.0
runtime.osx.10.10-x64.runtime.native.system.security.cryptography.openssl@4.3.0
runtime.rhel.7-x64.runtime.native.system.security.cryptography.openssl@4.3.0
runtime.ubuntu.14.04-x64.runtime.native.system.security.cryptography.openssl@4.3.0
runtime.ubuntu.16.04-x64.runtime.native.system.security.cryptography.openssl@4.3.0
runtime.ubuntu.16.10-x64.runtime.native.system.security.cryptography.openssl@4.3.0
runtime.unix.system.diagnostics.debug@4.3.0
runtime.unix.system.private.uri@4.3.0
runtime.unix.system.runtime.extensions@4.3.0
system.buffers@4.5.1
system.collections.immutable@5.0.0
system.collections.immutable@7.0.0
system.collections@4.3.0
system.componentmodel.composition@4.5.0
system.composition.attributedmodel@1.0.31
system.composition.attributedmodel@7.0.0
system.composition.convention@1.0.31
system.composition.convention@7.0.0
system.composition.hosting@1.0.31
system.composition.hosting@7.0.0
system.composition.runtime@1.0.31
system.composition.runtime@7.0.0
system.composition.typedparts@1.0.31
system.composition.typedparts@7.0.0
system.composition@1.0.31
system.composition@7.0.0
system.diagnostics.debug@4.3.0
system.diagnostics.tools@4.3.0
system.globalization@4.3.0
system.io.pipelines@5.0.1
system.io.pipelines@7.0.0
system.io@4.3.0
system.linq.expressions@4.3.0
system.linq@4.3.0
system.memory@4.5.4
system.memory@4.5.5
system.numerics.vectors@4.4.0
system.objectmodel@4.3.0
system.private.uri@4.3.0
system.reflection.emit.ilgeneration@4.3.0
system.reflection.emit.lightweight@4.3.0
system.reflection.emit@4.3.0
system.reflection.extensions@4.3.0
system.reflection.metadata@5.0.0
system.reflection.metadata@7.0.0
system.reflection.primitives@4.3.0
system.reflection.typeextensions@4.3.0
system.reflection@4.3.0
system.resources.resourcemanager@4.3.0
system.runtime.compilerservices.unsafe@4.5.2
system.runtime.compilerservices.unsafe@4.5.3
system.runtime.compilerservices.unsafe@5.0.0
system.runtime.compilerservices.unsafe@6.0.0
system.runtime.extensions@4.3.0
system.runtime@4.3.0
system.security.cryptography.protecteddata@4.3.0
system.security.permissions@4.5.0
system.text.encoding.codepages@4.5.1
system.text.encoding.codepages@7.0.0
system.text.encoding@4.3.0
system.threading.tasks.extensions@4.5.4
system.threading.tasks@4.3.0
system.threading@4.3.0
system.xml.xpath.xmldocument@4.0.1
xunit.abstractions@2.0.3
xunit.analyzers@1.0.0
xunit.assert@2.3.0
xunit.assert@2.4.2
xunit.core@2.4.2
xunit.extensibility.core@2.4.2
xunit.extensibility.execution@2.4.2
xunit.runner.visualstudio@2.4.5
xunit@2.4.2
"

PYTHON_COMPAT=( python3_{11..13} )
inherit desktop python-any-r1 flag-o-matic scons-utils shell-completion toolchain-funcs xdg neptune-dotnet

DESCRIPTION="Multi-platform 2D and 3D game engine with a feature-rich editor"
HOMEPAGE="https://godotengine.org/"
LICENSE="
	MIT
	Apache-2.0 BSD Boost-1.0 CC0-1.0 Unlicense ZLIB OFL-1.1
	gui? ( CC-BY-4.0 )
"
SLOT="${PV}"
if [[ "${PV}" == *9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/godotengine/godot.git"
else
	SRC_URI="
		https://github.com/godotengine/godot/archive/refs/tags/${PV}-stable.tar.gz
		${NUGET_URIS}
	"
	S="${WORKDIR}/${P}-stable"
	KEYWORDS="~amd64"
fi
# Enable roughly same as upstream by default so it works as expected,
IUSE="
	alsa +dbus debug +deprecated +double-precision dotnet +fontconfig +gui pulseaudio
	+raycast speech test +theora +udev +upnp +vulkan wayland +webp dev
"
REQUIRED_USE="wayland? ( gui )"
# TODO: tests still need more figuring out
# TODO: figure out how dotnet.eclass builds things so i can just pass it through to godot.
RESTRICT="
	!test? ( test )
"

# dlopen: libglvnd
# dotnet: 4.4 uses both 6.0 and 8.0
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
	net-libs/mbedtls:3=
	net-libs/wslay
	sys-libs/zlib:=
	app-misc/ca-certificates
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
		raycast? ( media-libs/embree:4 )
		vulkan? ( media-libs/vulkan-loader[X,wayland?] )
	)
	pulseaudio? ( media-libs/libpulse )
	speech? ( app-accessibility/speech-dispatcher )
	theora? ( media-libs/libtheora )
	udev? ( virtual/udev )
	wayland? (
		dev-libs/wayland
		gui-libs/libdecor
	)
	webp? ( media-libs/libwebp:= )
	dotnet? (
		${DOTNET_PKG_RDEPS}
		neptune-dotnet/nuget-source-godot
	)
"

DEPEND="
	${RDEPEND}
	gui? ( x11-base/xorg-proto )
	test? ( dev-cpp/doctest )
"
BDEPEND="
	virtual/pkgconfig
	wayland? ( dev-util/wayland-scanner )
	app-alternatives/awk
	dotnet? (
		${DOTNET_PKG_BDEPS}
		neptune-dotnet/nuget-source-godot
	)
"

PATCHES=(
	"${FILESDIR}/${PN}-4.4-scons.patch"
	"${FILESDIR}/${PN}-4.3-mono-path.patch"
)

godot_get_version() {
	export GODOT_VERSION=$(
		${PYTHON} -c 'from version import major, minor, patch, status; print(f"{major}.{minor}{f".{patch}" if patch > 0 else ""}{f"-{status}" if status != "stable" else ""}")'
	)
}

src_unpack() {
	if [[ "${PV}" == *9999* ]]; then
		git-r3_src_unpack
	fi

	if use dotnet; then
		neptune-dotnet_src_unpack
	else
		default
	fi
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

	sed -i "s|pkg-config |$(tc-getPKG_CONFIG) |" platform/linuxbsd/detect.py || die
	sed -i "s/mbedtls mbedcrypto mbedx509/mbedtls3 mbedcrypto3 mbedx5093/" platform/linuxbsd/detect.py || die
	sed -i "s/--exists mbedtls/--exists mbedtls3/" platform/linuxbsd/detect.py || die
	sed -e "s/app_id = \"org.godotengine.Editor\"/app_id = \"org.godotengine.Editor${s}\"/g" -i platform/linuxbsd/wayland/display_server_wayland.cpp || die
	sed -e "s/app_id = \"org.godotengine.ProjectManager\"/app_id = \"org.godotengine.ProjectManager${s}\"/g" -i platform/linuxbsd/wayland/display_server_wayland.cpp || die
	sed -e "s/app_id = \"org.godotengine.Godot\"/app_id = \"org.godotengine.Godot${s}\"/g" -i platform/linuxbsd/wayland/display_server_wayland.cpp || die
	sed -e "s|__GODOT_VERSION__|godot${s}|" -i modules/mono/godotsharp_dirs.cpp

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

	if use dotnet; then
		neptune-dotnet_src_prepare

		# !!! WARNING !!!
		# strip runtime identifiers!!
		find modules/mono -iname "*.csproj" -exec sed -e "s|<RuntimeIdentifier>.*</RuntimeIdentifier>||" -i "{}" \; || die
		find modules/mono -iname "*.csproj" -exec sed -e "s|<TargetFramework>net8.0-.*</TargetFramework>|<TargetFramework>net8.0</TargetFramework>|" -i "{}" \; || die
		sed -e "s|= find_dotnet_cli()|= \"${EPREFIX}/opt/neptune-dotnet/dotnet\"|" -i modules/mono/build_scripts/build_assemblies.py || die
	fi
}

src_configure() {
	if use dotnet; then
		neptune-dotnet_src_configure
	fi
}

src_compile() {
	local -x BUILD_NAME=gentoo.neptune # replaces "custom_build" in version string

	filter-lto #921017

	local esconsargs=(
		AR="$(tc-getAR)" CC="$(tc-getCC)" CXX="$(tc-getCXX)"

		progress=no
		verbose=yes
		engine_update_check=no
		precision=$(usex double-precision double single)

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
		builtin_embree=$(usex !gui yes $(usex !raycast))
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
		module_mono_enabled=$(usex dotnet)
		# note raycast is only enabled on amd64+arm64, see raycast/config.py
		module_raycast_enabled=$(usex gui $(usex raycast))
		module_theora_enabled=$(usex theora)
		module_upnp_enabled=$(usex upnp)
		module_webp_enabled=$(usex webp)

		# let *FLAGS handle these
		debug_symbols=no
		lto=none
		optimize=custom
		use_static_cpp=no
		disable_exceptions=$(usex dev no yes)

		# harmless but note this bakes in --test in the final binary
		tests=$(usex test)
		target=editor
	)

	escons extra_suffix=main "${esconsargs[@]}" || die

	if use dotnet; then
		addpredict /dev/input
		addpredict /opt/neptune-dotnet
		export DOTNET_CLI_TELEMETRY_OPTOUT=1
		export DOTNET_ROOT="${EPREFIX}/opt/neptune-dotnet"
		bin/godot* --headless --generate-mono-glue ./modules/mono/glue || die

		local dotnetargs=(
			--godot-output-dir=./bin
			--godot-platform=linuxbsd
			--precision=$(usex double-precision double single)
			--push-nupkgs-local=./bin/nugets
		)

		if use dev; then
			dotnetargs+=(
				--dev-debug
			)
		fi

		if ! use deprecated; then
			dotnetargs+=(
				--no-deprecated
			)
		fi

		"${EPYTHON}" ./modules/mono/build_scripts/build_assemblies.py ${dotnetargs[@]} || die
	fi
}

src_test() {
	xdg_environment_reset

	bin/godot* --headless --test || die
}

src_install() {
	godot_get_version
	local s="godot-${GODOT_VERSION}"

	newbin bin/godot* ${s}
	if use dotnet; then
		insinto "/usr/share/godot/${s}/"
		doins -r bin/GodotSharp
		insinto "/usr/share/godot/"
		doins -r bin/nugets
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

pkg_setup() {
	python-any-r1_pkg_setup

	if use dotnet; then
		neptune-dotnet_pkg_setup
	fi
}

pkg_postinst() {
	if use dotnet; then
		ewarn
		ewarn "Godot C# SDK has been installed to ${EPREFIX}/usr/share/godot/godot-${GODOT_VERSION}"
		ewarn "Godot Nugets have been installed to ${EPREFIX}/usr/share/godot/nugets"
		ewarn "An appropriate NuGet config file has been placed in ${EPREFIX}/etc/opt/NuGet/Config"
		ewarn "No further action is needed"
		ewarn
	fi
}
