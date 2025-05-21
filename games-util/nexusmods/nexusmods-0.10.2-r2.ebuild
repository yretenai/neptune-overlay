# Copyright 2023-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DOTNET_PKG_COMPAT=9.0
DOTNET_NEPTUNE_TARGETS=( 9.0 )

NUGETS="
argon@0.24.2
autofixture.xunit2@4.18.1
autofixture@4.18.1
avalonia.angle.windows.natives@2.1.22045.20230930
avalonia.avaloniaedit@11.2.0
avalonia.buildservices@0.0.28
avalonia.buildservices@0.0.31
avalonia.controls.colorpicker@11.2.6
avalonia.controls.datagrid@11.2.6
avalonia.controls.treedatagrid@11.1.1
avalonia.desktop@11.2.6
avalonia.diagnostics@11.2.6
avalonia.freedesktop@11.2.6
avalonia.headless@11.2.6
avalonia.labs.panels@11.2.0
avalonia.native@11.2.6
avalonia.reactiveui@11.2.6
avalonia.remote.protocol@11.0.0
avalonia.remote.protocol@11.2.6
avalonia.skia@11.0.0
avalonia.skia@11.2.0
avalonia.skia@11.2.6
avalonia.svg.skia@11.2.0.2
avalonia.themes.fluent@11.2.6
avalonia.themes.simple@11.2.6
avalonia.win32@11.2.6
avalonia.x11@11.2.6
avalonia@11.0.0
avalonia@11.2.0
avalonia@11.2.3
avalonia@11.2.6
avaloniaedit.textmate@11.2.0
bannerlord.launchermanager.localization@1.0.140
bannerlord.launchermanager.models@1.0.140
bannerlord.launchermanager@1.0.140
bannerlord.modulemanager.models@5.0.221
bannerlord.modulemanager.models@6.0.246
bannerlord.modulemanager@5.0.225
bannerlord.modulemanager@6.0.246
benchmarkdotnet.annotations@0.14.0
benchmarkdotnet@0.14.0
bitfaster.caching@2.5.2
bsdiff@1.1.0
castle.core@5.1.1
cliwrap@3.6.7
colordocument.avalonia@11.0.3-a1
colortextblock.avalonia@11.0.3-a1
commandlineparser@2.9.1
coverlet.collector@6.0.2
diffengine@15.5.3
diffplex@1.7.2
dynamicdata@8.3.27
dynamicdata@8.4.1
dynamicdata@9.0.1
dynamicdata@9.0.4
dynamicdata@9.1.2
emptyfiles@8.5.0
excss@4.2.3
fare@2.1.1
fetchbannerlordversion.models@1.0.6.46
fetchbannerlordversion@1.0.6.46
fluentassertions.analyzers@0.34.1
fluentassertions.oneof@0.0.5
fluentassertions@5.0.0
fluentassertions@7.1.0
fluentresults@3.15.2
fody@6.8.0
fomodinstaller.interface@1.0.0
fomodinstaller.interface@1.2.0
fomodinstaller.scripting.xmlscript@1.0.0
fomodinstaller.scripting@1.0.0
fomodinstaller.utils@1.0.0
gamefinder.common@4.6.1
gamefinder.launcher.heroic@4.6.1
gamefinder.registryutils@4.6.1
gamefinder.storehandlers.eadesktop@4.6.1
gamefinder.storehandlers.egs@4.6.1
gamefinder.storehandlers.gog@4.6.1
gamefinder.storehandlers.origin@4.6.1
gamefinder.storehandlers.steam@4.6.1
gamefinder.storehandlers.xbox@4.6.1
gamefinder.wine@4.6.1
gamefinder@4.6.1
gee.external.capstone@2.3.0
githubactionstestlogger@2.4.1
google.protobuf@3.22.5
grpc.core.api@2.52.0
grpc.net.client@2.52.0
grpc.net.common@2.52.0
halgari.jamarino.intervaltree@1.0.0-alpha
harfbuzzsharp.nativeassets.linux@7.3.0.2
harfbuzzsharp.nativeassets.linux@7.3.0.3
harfbuzzsharp.nativeassets.macos@7.3.0.2
harfbuzzsharp.nativeassets.macos@7.3.0.3
harfbuzzsharp.nativeassets.webassembly@7.3.0.3
harfbuzzsharp.nativeassets.webassembly@7.3.0.3-preview.2.2
harfbuzzsharp.nativeassets.win32@7.3.0.2
harfbuzzsharp.nativeassets.win32@7.3.0.3
harfbuzzsharp@7.3.0.2
harfbuzzsharp@7.3.0.3
hotchocolate.language.syntaxtree@15.0.3
hotchocolate.transport.abstractions@15.0.3
hotchocolate.transport.http@15.0.3
hotchocolate.utilities@15.0.3
htmlagilitypack@1.11.71
humanizer.core.af@2.14.1
humanizer.core.ar@2.14.1
humanizer.core.az@2.14.1
humanizer.core.bg@2.14.1
humanizer.core.bn-bd@2.14.1
humanizer.core.cs@2.14.1
humanizer.core.da@2.14.1
humanizer.core.de@2.14.1
humanizer.core.el@2.14.1
humanizer.core.es@2.14.1
humanizer.core.fa@2.14.1
humanizer.core.fi-fi@2.14.1
humanizer.core.fr-be@2.14.1
humanizer.core.fr@2.14.1
humanizer.core.he@2.14.1
humanizer.core.hr@2.14.1
humanizer.core.hu@2.14.1
humanizer.core.hy@2.14.1
humanizer.core.id@2.14.1
humanizer.core.is@2.14.1
humanizer.core.it@2.14.1
humanizer.core.ja@2.14.1
humanizer.core.ko-kr@2.14.1
humanizer.core.ku@2.14.1
humanizer.core.lv@2.14.1
humanizer.core.ms-my@2.14.1
humanizer.core.mt@2.14.1
humanizer.core.nb-no@2.14.1
humanizer.core.nb@2.14.1
humanizer.core.nl@2.14.1
humanizer.core.pl@2.14.1
humanizer.core.pt@2.14.1
humanizer.core.ro@2.14.1
humanizer.core.ru@2.14.1
humanizer.core.sk@2.14.1
humanizer.core.sl@2.14.1
humanizer.core.sr-latn@2.14.1
humanizer.core.sr@2.14.1
humanizer.core.sv@2.14.1
humanizer.core.th-th@2.14.1
humanizer.core.tr@2.14.1
humanizer.core.uk@2.14.1
humanizer.core.uz-cyrl-uz@2.14.1
humanizer.core.uz-latn-uz@2.14.1
humanizer.core.vi@2.14.1
humanizer.core.zh-cn@2.14.1
humanizer.core.zh-hans@2.14.1
humanizer.core.zh-hant@2.14.1
humanizer.core@2.14.1
humanizer.core@2.2.0
humanizer@2.14.1
iced@1.17.0
ini-parser-netstandard@2.5.2
jetbrains.annotations@2024.3.0
jitbit.fastcache@1.1.0
k4os.compression.lz4@1.3.7-beta
k4os.compression.lz4@1.3.8
linqgen@0.3.1
linuxdesktoputils.xdgdesktopportal@1.0.2
livechartscore.skiasharpview.avalonia@2.0.0-rc2
livechartscore.skiasharpview@2.0.0-rc2
livechartscore@2.0.0-rc2
magick.net-q16-anycpu@14.0.0
magick.net.core@14.0.0
markdig@0.38.0
markdown.avalonia.tight@11.0.3-a1
martincostello.logging.xunit@0.3.0
memorypack.core@1.21.3
memorypack.generator@1.21.3
memorypack.streaming@1.21.3
memorypack@1.21.3
microcom.runtime@0.11.0
microsoft.aspnet.webapi.client@6.0.0
microsoft.aspnetcore.webutilities@9.0.0
microsoft.bcl.asyncinterfaces@1.1.0
microsoft.bcl.asyncinterfaces@1.1.1
microsoft.bcl.asyncinterfaces@6.0.0
microsoft.bcl.asyncinterfaces@7.0.0
microsoft.bcl.asyncinterfaces@8.0.0
microsoft.build.tasks.git@8.0.0
microsoft.codeanalysis.analyzer.testing@1.1.2
microsoft.codeanalysis.analyzers@3.3.3
microsoft.codeanalysis.analyzers@3.3.4
microsoft.codeanalysis.common@1.0.1
microsoft.codeanalysis.common@3.8.0
microsoft.codeanalysis.common@4.1.0
microsoft.codeanalysis.common@4.11.0
microsoft.codeanalysis.common@4.8.0
microsoft.codeanalysis.csharp.sourcegenerators.testing.xunit@1.1.2
microsoft.codeanalysis.csharp.sourcegenerators.testing@1.1.2
microsoft.codeanalysis.csharp.workspaces@3.8.0
microsoft.codeanalysis.csharp.workspaces@4.8.0
microsoft.codeanalysis.csharp@3.8.0
microsoft.codeanalysis.csharp@4.1.0
microsoft.codeanalysis.csharp@4.11.0
microsoft.codeanalysis.csharp@4.8.0
microsoft.codeanalysis.sourcegenerators.testing@1.1.2
microsoft.codeanalysis.testing.verifiers.xunit@1.1.2
microsoft.codeanalysis.workspaces.common@1.0.1
microsoft.codeanalysis.workspaces.common@3.8.0
microsoft.codeanalysis.workspaces.common@4.8.0
microsoft.codecoverage@17.12.0
microsoft.composition@1.0.27
microsoft.diagnostics.netcore.client@0.2.251802
microsoft.diagnostics.runtime@2.2.332302
microsoft.diagnostics.tracing.traceevent@3.1.8
microsoft.dotnet.platformabstractions@3.1.6
microsoft.extensions.ambientmetadata.application@9.0.0
microsoft.extensions.compliance.abstractions@9.0.0
microsoft.extensions.configuration.abstractions@8.0.0
microsoft.extensions.configuration.abstractions@9.0.0
microsoft.extensions.configuration.binder@8.0.0
microsoft.extensions.configuration.binder@9.0.0
microsoft.extensions.configuration.commandline@8.0.0
microsoft.extensions.configuration.commandline@9.0.0
microsoft.extensions.configuration.environmentvariables@8.0.0
microsoft.extensions.configuration.environmentvariables@9.0.0
microsoft.extensions.configuration.fileextensions@8.0.0
microsoft.extensions.configuration.fileextensions@9.0.0
microsoft.extensions.configuration.json@8.0.0
microsoft.extensions.configuration.json@9.0.0
microsoft.extensions.configuration.usersecrets@8.0.0
microsoft.extensions.configuration.usersecrets@9.0.0
microsoft.extensions.configuration@8.0.0
microsoft.extensions.configuration@9.0.0
microsoft.extensions.dependencyinjection.abstractions@2.0.0
microsoft.extensions.dependencyinjection.abstractions@8.0.0
microsoft.extensions.dependencyinjection.abstractions@8.0.2
microsoft.extensions.dependencyinjection.abstractions@9.0.0
microsoft.extensions.dependencyinjection.autoactivation@9.0.0
microsoft.extensions.dependencyinjection@8.0.0
microsoft.extensions.dependencyinjection@9.0.0
microsoft.extensions.diagnostics.abstractions@8.0.0
microsoft.extensions.diagnostics.abstractions@9.0.0
microsoft.extensions.diagnostics.exceptionsummarization@9.0.0
microsoft.extensions.diagnostics@8.0.0
microsoft.extensions.diagnostics@9.0.0
microsoft.extensions.fileproviders.abstractions@8.0.0
microsoft.extensions.fileproviders.abstractions@9.0.0
microsoft.extensions.fileproviders.physical@8.0.0
microsoft.extensions.fileproviders.physical@9.0.0
microsoft.extensions.filesystemglobbing@8.0.0
microsoft.extensions.filesystemglobbing@9.0.0
microsoft.extensions.hosting.abstractions@8.0.0
microsoft.extensions.hosting.abstractions@9.0.0
microsoft.extensions.hosting@8.0.0
microsoft.extensions.hosting@9.0.0
microsoft.extensions.http.diagnostics@9.0.0
microsoft.extensions.http.resilience@9.0.0
microsoft.extensions.http@9.0.0
microsoft.extensions.logging.abstractions@2.0.0
microsoft.extensions.logging.abstractions@3.0.3
microsoft.extensions.logging.abstractions@6.0.1
microsoft.extensions.logging.abstractions@8.0.0
microsoft.extensions.logging.abstractions@9.0.0
microsoft.extensions.logging.configuration@8.0.0
microsoft.extensions.logging.configuration@9.0.0
microsoft.extensions.logging.console@8.0.0
microsoft.extensions.logging.console@9.0.0
microsoft.extensions.logging.debug@8.0.0
microsoft.extensions.logging.debug@9.0.0
microsoft.extensions.logging.eventlog@8.0.0
microsoft.extensions.logging.eventlog@9.0.0
microsoft.extensions.logging.eventsource@8.0.0
microsoft.extensions.logging.eventsource@9.0.0
microsoft.extensions.logging@2.0.0
microsoft.extensions.logging@2.1.1
microsoft.extensions.logging@8.0.0
microsoft.extensions.logging@9.0.0
microsoft.extensions.objectpool@9.0.0
microsoft.extensions.options.configurationextensions@8.0.0
microsoft.extensions.options.configurationextensions@9.0.0
microsoft.extensions.options@2.0.0
microsoft.extensions.options@8.0.0
microsoft.extensions.options@9.0.0
microsoft.extensions.primitives@8.0.0
microsoft.extensions.primitives@9.0.0
microsoft.extensions.resilience@9.0.0
microsoft.extensions.telemetry.abstractions@9.0.0
microsoft.extensions.telemetry@9.0.0
microsoft.extensions.timeprovider.testing@9.0.0
microsoft.io.recyclablememorystream@3.0.0
microsoft.net.http.headers@9.0.0
microsoft.net.test.sdk@17.12.0
microsoft.netcore.platforms@1.1.0
microsoft.netcore.platforms@5.0.0
microsoft.sourcelink.common@8.0.0
microsoft.sourcelink.github@8.0.0
microsoft.testplatform.objectmodel@17.10.0
microsoft.testplatform.objectmodel@17.12.0
microsoft.testplatform.testhost@17.12.0
microsoft.visualstudio.composition.netfxattributes@16.1.8
microsoft.visualstudio.composition@16.1.8
microsoft.visualstudio.threading.analyzers@17.10.48
microsoft.visualstudio.threading@17.10.48
microsoft.visualstudio.validation@15.0.82
microsoft.visualstudio.validation@17.8.8
microsoft.win32.systemevents@6.0.0
nerdbank.fullduplexstream@1.1.12
nerdbank.streams@2.11.79
netescapades.enumgenerators@1.0.0-beta07
netstandard.library@1.6.0
netstandard.library@1.6.1
netstandard.library@2.0.3
newtonsoft.json.bson@1.0.2
newtonsoft.json@12.0.1
newtonsoft.json@13.0.1
newtonsoft.json@13.0.3
nexusmods.archives.nx@0.6.1
nexusmods.archives.nx@0.6.4
nexusmods.hashing.xxhash3.paths@3.0.3
nexusmods.hashing.xxhash3@3.0.3
nexusmods.mnemonicdb.abstractions@0.9.122
nexusmods.mnemonicdb.sourcegenerator@0.9.122
nexusmods.mnemonicdb@0.9.122
nexusmods.paths.extensions.nx@0.18.0
nexusmods.paths.testinghelpers@0.18.0
nexusmods.paths@0.15.0
nexusmods.paths@0.18.0
nlog.extensions.logging@5.3.14
nlog@5.2.8
nlog@5.3.4
noggog.csharpext@2.67.3
nsubstitute.analyzers.csharp@1.0.17
nsubstitute@5.3.0
nuget.common@6.3.4
nuget.configuration@6.3.4
nuget.frameworks@6.3.4
nuget.packaging@6.3.4
nuget.protocol@6.3.4
nuget.resolver@6.3.4
nuget.versioning@6.12.1
nuget.versioning@6.3.4
observablecollections.r3@3.3.3
observablecollections@3.3.3
oneof.extended@2.1.125
oneof@2.1.125
oneof@3.0.271
onigwrap@1.0.6
opentelemetry.api.providerbuilderextensions@1.10.0
opentelemetry.api@1.10.0
opentelemetry.exporter.opentelemetryprotocol@1.10.0
opentelemetry.extensions.hosting@1.10.0
opentelemetry@1.10.0
pathoschild.http.fluentclient@4.4.1
perfolizer@0.3.17
polly.core@8.4.2
polly.core@8.5.0
polly.extensions@8.4.2
polly.ratelimiting@8.4.2
polly@8.5.0
projektanker.icons.avalonia.materialdesign@9.6.1
projektanker.icons.avalonia@9.6.1
protobuf-net.core@3.2.45
protobuf-net@3.2.45
qoisharp@1.0.0
qrcoder@1.6.0
r3@1.0.0
r3@1.2.9
r3@1.3.0
r3extensions.avalonia@1.3.0
reactiveui.fody@19.5.41
reactiveui@19.5.41
reactiveui@20.1.1
reactiveui@20.1.63
reloaded.memory@9.4.2
rocksdb@9.4.0.50294
sha3.net@2.0.0
sharpziplib@1.4.2
sharpzstd.interop@1.5.6
shimskiasharp@2.0.0.4
simpleinfoname@3.0.1
skiasharp.harfbuzz@2.88.6
skiasharp.harfbuzz@2.88.8
skiasharp.nativeassets.linux@2.88.8
skiasharp.nativeassets.linux@2.88.9
skiasharp.nativeassets.macos@2.88.8
skiasharp.nativeassets.macos@2.88.9
skiasharp.nativeassets.webassembly@2.88.8
skiasharp.nativeassets.webassembly@2.88.9
skiasharp.nativeassets.win32@2.88.8
skiasharp.nativeassets.win32@2.88.9
skiasharp@2.88.6
skiasharp@2.88.8
skiasharp@2.88.9
smartformat@3.5.1
spectre.console.cli@0.49.1
spectre.console.testing@0.49.1
spectre.console@0.49.1
splat.microsoft.extensions.logging@15.2.22
splat@14.8.12
splat@15.1.1
splat@15.2.22
steamkit2@3.0.0
strawberryshake.core@15.0.3
strawberryshake.resources@15.0.3
strawberryshake.server@15.0.3
strawberryshake.transport.http@15.0.3
strawberryshake.transport.websockets@15.0.3
svg.custom@2.0.0.4
svg.model@2.0.0.4
svg.skia@2.0.0.4
system.buffers@4.5.1
system.codedom@5.0.0
system.codedom@8.0.0
system.codedom@9.0.0
system.collections.immutable@7.0.0
system.commandline@2.0.0-beta4.22272.1
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
system.configuration.configurationmanager@6.0.0
system.diagnostics.eventlog@6.0.0
system.diagnostics.eventlog@8.0.0
system.diagnostics.eventlog@9.0.0
system.drawing.common@6.0.0
system.io.abstractions@21.0.29
system.io.hashing@8.0.0
system.io.hashing@9.0.0
system.io.pipelines@7.0.0
system.linq.async@6.0.1
system.linq@4.3.0
system.management@5.0.0
system.management@8.0.0
system.memory@4.5.5
system.numerics.vectors@4.4.0
system.reactive@5.0.0
system.reactive@6.0.1
system.reflection.metadata@7.0.0
system.runtime.compilerservices.unsafe@4.5.3
system.runtime.compilerservices.unsafe@6.0.0
system.security.cryptography.cng@5.0.0
system.security.cryptography.pkcs@5.0.0
system.security.cryptography.protecteddata@4.4.0
system.security.cryptography.protecteddata@6.0.0
system.security.permissions@4.5.0
system.security.permissions@6.0.0
system.text.encoding.codepages@7.0.0
system.threading.channels@7.0.0
system.threading.ratelimiting@8.0.0
system.threading.tasks.extensions@4.5.4
system.windows.extensions@6.0.0
testableio.system.io.abstractions.wrappers@21.0.29
testableio.system.io.abstractions@21.0.29
textmatesharp.grammars@1.0.65
textmatesharp@1.0.65
tmds.dbus.protocol@0.20.0
tmds.dbus.protocol@0.21.2
transparentvalueobjects@1.0.2
validation@2.3.7
validation@2.4.18
valvekeyvalue@0.13.1.398
verify.imagemagick@3.6.0
verify.sourcegenerators@2.5.0
verify.xunit@28.2.1
verify@26.5.0
verify@27.0.0
verify@28.2.1
weave@2.1.0
xunit.abstractions@2.0.1
xunit.abstractions@2.0.2
xunit.abstractions@2.0.3
xunit.analyzers@1.16.0
xunit.assert@2.3.0
xunit.assert@2.9.2
xunit.core@2.9.2
xunit.dependencyinjection.logging@9.0.0
xunit.dependencyinjection.skippablefact@9.0.0
xunit.dependencyinjection@9.0.0
xunit.dependencyinjection@9.6.0
xunit.extensibility.core@2.2.0
xunit.extensibility.core@2.4.0
xunit.extensibility.core@2.4.2
xunit.extensibility.core@2.9.2
xunit.extensibility.execution@2.4.0
xunit.extensibility.execution@2.4.2
xunit.extensibility.execution@2.9.2
xunit.runner.visualstudio@2.8.2
xunit.skippablefact@1.4.13
xunit@2.9.2
yamldotnet@16.3.0
zlinq@0.9.6
zstdsharp.port@0.8.2
zstring@2.6.0
"

inherit desktop neptune-dotnet xdg

DESCRIPTION="Nexus Mods App is a mod manager for games"
HOMEPAGE="
	https://nexus-mods.github.io/NexusMods.App/
	https://github.com/Nexus-Mods/NexusMods.App
"

if [[ "${PV}" == *9999* ]]; then
	PROPERTIES=live
	GIT_LFS=1
	inherit git-r3
	EGIT_REPO_URI="https://github.com/Nexus-Mods/NexusMods.App.git"
else
	NEXUSDOCS_PV="fe4e8b1b26d2c2917b404b0b091bfa31f135e337"
	SMAPI_PV="4.1.10"

	SRC_URI="
		https://github.com/Nexus-Mods/NexusMods.App/archive/refs/tags/v${PV}.tar.gz -> ${PN}-${PV}.tar.gz
		https://github.com/Pathoschild/SMAPI/archive/refs/tags/${SMAPI_PV}.tar.gz -> SMAPI-${SMAPI_PV}.tar.gz
		https://github.com/Nexus-Mods/NexusMods.MkDocsMaterial.Themes.Next/archive/${NEXUSDOCS_PV}.tar.gz -> NexusMods.MkDocsMaterial.Themes.Next-${NEXUSDOCS_PV}.tar.gz
		${NUGET_URIS}
	"
	S="${WORKDIR}/NexusMods.App-${PV}"
	KEYWORDS="~amd64"
fi

LICENSE="GPL-3 Apache-2.0 BSD-2 BSD MIT"
SLOT="0"

RESTRICT="${RESTRICT} mirror"

# jemalloc causes a TLS issue?
RDEPEND="
	>=dev-libs/rocksdb-8.11.3[-jemalloc]
	|| (
		>=app-arch/7zip-24.09[symlink]
		app-arch/p7zip
	)
	app-arch/brotli
	dev-libs/elfutils
	dev-libs/expat
	dev-libs/libxml2
	media-gfx/graphite2
	media-libs/fontconfig
	media-libs/freetype
	media-libs/harfbuzz
	media-libs/libglvnd
	media-libs/libpng
	x11-libs/libICE
	x11-libs/libSM
	x11-libs/libX11
	x11-libs/libXau
	x11-libs/libXcursor
	x11-libs/libXdmcp
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXi
	x11-libs/libXrandr
	x11-libs/libXrender
	x11-libs/libdrm
	x11-libs/libxcb
	x11-libs/libxshmfence
"

BDEPEND="
	app-text/dos2unix
"

DOTNET_PKG_PROJECTS=(
	"src/NexusMods.App/NexusMods.App.csproj"
)

DOTNET_PKG_BUILD_EXTRA_ARGS+=(
	"-p:TieredCompilation=true"
	"-p:DefineConstants=\"INSTALLATION_METHOD_PACKAGE_MANAGER\""
	"-p:UseSystemExtractor=true"
)

DOTNET_PKG_TEST_EXTRA_ARGS+=(
	"--filter \"RequiresNetworking==True\""
)

src_unpack() {
	if [[ "${PV}" == *9999* ]]; then
		git-r3_src_unpack
	fi
	neptune-dotnet_src_unpack
}

src_prepare() {
	if [[ "${PV}" != *9999* ]]; then
		rm -d "${S}/extern/SMAPI"
		rm -d "${S}/docs/Nexus"
		mv "${WORKDIR}/SMAPI-${SMAPI_PV}" "${S}/extern/SMAPI"
		mv "${WORKDIR}/NexusMods.MkDocsMaterial.Themes.Next-${NEXUSDOCS_PV}" "${S}/docs/Nexus"
	fi

	rm src/src.sln

	dos2unix src/Games/NexusMods.Games.StardewValley.SMAPI/NexusMods.Games.StardewValley.SMAPI.csproj
	neptune-dotnet_src_prepare
}

src_install() {
	rm -fv "${DOTNET_PKG_OUTPUT}/librocksdb.so" \
		"${DOTNET_PKG_OUTPUT}/librocksdb-musl.so" \
		"${DOTNET_PKG_OUTPUT}/librocksdb-jemalloc.so"
	dotnet-pkg-base_install
	neptune-dotnet_dolauncher "/usr/share/${P}/NexusMods.App" "nexusmods"

	doicon -s scalable src/NexusMods.App.UI/Assets/nexus-logo.svg
	domenu "${FILESDIR}/${PN}.desktop"
}

pkg_postrm() {
	einfo ""
	einfo "NexusMods.App stores full copies of game archives for repairing."
	einfo "You may want to remove the following directories:"
	einfo "\t\$\{XDG_STATE_HOME:-\$HOME/.local/state\}/NexusMods.App"
	einfo "\t\$\{XDG_DATA_HOME:-\$HOME/.local/share\}/NexusMods.App"
	einfo "It may contain (significant) debris."
	einfo ""
}

pkg_postinst() {
	if has_version "<${CATEGORY}/${P}"; then
		ewarn ""
		ewarn "NexusMods.App at the moment may require a clean install when updating"
		ewarn "You may want to remove the following directories:"
		ewarn "\t\$\{XDG_STATE_HOME:-\$HOME/.local/state\}/NexusMods.App"
		ewarn "\t\$\{XDG_DATA_HOME:-\$HOME/.local/share\}/NexusMods.App"
		ewarn "If you experience issues"
		ewarn ""
	fi
}
