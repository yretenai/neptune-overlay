# Copyright 2023-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DOTNET_PKG_COMPAT=8.0
NUGETS="
argon@0.11.0
argon@0.17.0
autofixture.xunit2@4.18.1
autofixture@4.18.1
avalonia.angle.windows.natives@2.1.22045.20230930
avalonia.avaloniaedit@11.0.6
avalonia.buildservices@0.0.28
avalonia.buildservices@0.0.29
avalonia.controls.colorpicker@11.1.0-beta2
avalonia.controls.datagrid@11.1.0-beta2
avalonia.controls.treedatagrid@11.0.10
avalonia.desktop@11.1.0-beta2
avalonia.diagnostics@11.1.0-beta2
avalonia.freedesktop@11.1.0-beta2
avalonia.headless@11.1.0-beta2
avalonia.native@11.1.0-beta2
avalonia.reactiveui@11.1.0-beta2
avalonia.remote.protocol@11.0.0
avalonia.remote.protocol@11.1.0-beta2
avalonia.skia@11.0.0
avalonia.skia@11.1.0-beta1
avalonia.skia@11.1.0-beta2
avalonia.svg.skia@11.1.0-beta1
avalonia.themes.fluent@11.1.0-beta2
avalonia.themes.simple@11.1.0-beta2
avalonia.win32@11.1.0-beta2
avalonia.x11@11.1.0-beta2
avalonia@11.0.0
avalonia@11.1.0-beta2
avaloniaedit.textmate@11.0.6
bannerlord.launchermanager@1.0.76
benchmarkdotnet.annotations@0.13.12
benchmarkdotnet@0.13.12
bitfaster.caching@2.5.0
castle.core@5.1.1
cliwrap@3.6.6
colordocument.avalonia@11.0.3-a1
colortextblock.avalonia@11.0.3-a1
commandlineparser@2.9.1
coverlet.collector@6.0.2
diffengine@12.3.0
diffengine@15.4.0
diffplex@1.5.0
dotnetzip@1.16.0
dynamicdata@8.3.27
dynamicdata@8.4.1
emptyfiles@4.5.1
emptyfiles@8.2.0
excss@4.2.3
fare@2.1.1
fetchbannerlordversion.models@1.0.6.45
fetchbannerlordversion@1.0.6.45
flatsharp.compiler@7.6.0
flatsharp.runtime@7.6.0
fluentassertions.analyzers@0.31.0
fluentassertions.oneof@0.0.5
fluentassertions@6.12.0
fluentresults@3.15.2
fody@6.8.0
fomodinstaller.interface@1.2.0
fomodinstaller.scripting.xmlscript@1.0.0
fomodinstaller.scripting@1.0.0
fomodinstaller.utils@1.0.0
gamefinder.common@2.4.0
gamefinder.common@4.2.0
gamefinder.registryutils@2.4.0
gamefinder.registryutils@4.2.0
gamefinder.storehandlers.eadesktop@4.2.0
gamefinder.storehandlers.egs@4.2.0
gamefinder.storehandlers.gog@2.4.0
gamefinder.storehandlers.gog@4.2.0
gamefinder.storehandlers.origin@4.2.0
gamefinder.storehandlers.steam@2.4.0
gamefinder.storehandlers.steam@4.2.0
gamefinder.storehandlers.xbox@4.2.0
gamefinder.wine@4.2.0
gamefinder@4.2.0
gee.external.capstone@2.3.0
githubactionstestlogger@2.3.3
google.protobuf@3.22.5
grpc.core.api@2.52.0
grpc.net.client@2.52.0
grpc.net.common@2.52.0
harfbuzzsharp.nativeassets.linux@2.8.2.3
harfbuzzsharp.nativeassets.linux@7.3.0
harfbuzzsharp.nativeassets.linux@7.3.0.2
harfbuzzsharp.nativeassets.macos@2.8.2.3
harfbuzzsharp.nativeassets.macos@7.3.0
harfbuzzsharp.nativeassets.macos@7.3.0.1
harfbuzzsharp.nativeassets.macos@7.3.0.2
harfbuzzsharp.nativeassets.webassembly@2.8.2.3
harfbuzzsharp.nativeassets.webassembly@7.3.0
harfbuzzsharp.nativeassets.webassembly@7.3.0.2
harfbuzzsharp.nativeassets.win32@2.8.2.3
harfbuzzsharp.nativeassets.win32@7.3.0
harfbuzzsharp.nativeassets.win32@7.3.0.1
harfbuzzsharp.nativeassets.win32@7.3.0.2
harfbuzzsharp@2.8.2.3
harfbuzzsharp@7.3.0
harfbuzzsharp@7.3.0.1
harfbuzzsharp@7.3.0.2
htmlagilitypack@1.11.52
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
jetbrains.annotations@2023.3.0
k4os.compression.lz4.streams@1.3.6
k4os.compression.lz4@1.3.6
k4os.compression.lz4@1.3.7-beta
k4os.hash.xxhash@1.0.8
linqgen@0.3.1
livechartscore.skiasharpview.avalonia@2.0.0-rc2
livechartscore.skiasharpview@2.0.0-rc2
livechartscore@2.0.0-rc2
loqui@2.64.0
magick.net-q16-anycpu@13.8.0
magick.net.core@13.8.0
markdown.avalonia.tight@11.0.3-a1
martincostello.logging.xunit@0.3.0
memorypack.core@1.21.1
memorypack.generator@1.21.1
memorypack.streaming@1.21.1
memorypack@1.21.1
microcom.runtime@0.11.0
microsoft.aspnet.webapi.client@5.2.9
microsoft.aspnetcore.webutilities@8.0.5
microsoft.bcl.asyncinterfaces@1.1.0
microsoft.bcl.asyncinterfaces@1.1.1
microsoft.bcl.asyncinterfaces@6.0.0
microsoft.bcl.asyncinterfaces@7.0.0
microsoft.build.tasks.git@8.0.0
microsoft.codeanalysis.analyzer.testing@1.1.1
microsoft.codeanalysis.analyzers@3.3.2
microsoft.codeanalysis.analyzers@3.3.3
microsoft.codeanalysis.analyzers@3.3.4
microsoft.codeanalysis.common@1.0.1
microsoft.codeanalysis.common@3.8.0
microsoft.codeanalysis.common@4.1.0
microsoft.codeanalysis.common@4.8.0
microsoft.codeanalysis.csharp.sourcegenerators.testing.xunit@1.1.1
microsoft.codeanalysis.csharp.sourcegenerators.testing@1.1.1
microsoft.codeanalysis.csharp.workspaces@3.8.0
microsoft.codeanalysis.csharp.workspaces@4.8.0
microsoft.codeanalysis.csharp@3.8.0
microsoft.codeanalysis.csharp@4.1.0
microsoft.codeanalysis.csharp@4.8.0
microsoft.codeanalysis.sourcegenerators.testing@1.1.1
microsoft.codeanalysis.testing.verifiers.xunit@1.1.1
microsoft.codeanalysis.workspaces.common@1.0.1
microsoft.codeanalysis.workspaces.common@3.8.0
microsoft.codeanalysis.workspaces.common@4.8.0
microsoft.codecoverage@17.9.0
microsoft.composition@1.0.27
microsoft.csharp@4.0.1
microsoft.csharp@4.7.0
microsoft.diagnostics.netcore.client@0.2.251802
microsoft.diagnostics.runtime@2.2.332302
microsoft.diagnostics.tracing.traceevent@3.0.2
microsoft.dotnet.platformabstractions@3.1.6
microsoft.extensions.configuration.abstractions@2.1.1
microsoft.extensions.configuration.abstractions@8.0.0
microsoft.extensions.configuration.binder@2.1.1
microsoft.extensions.configuration.binder@8.0.0
microsoft.extensions.configuration.binder@8.0.1
microsoft.extensions.configuration.commandline@8.0.0
microsoft.extensions.configuration.environmentvariables@8.0.0
microsoft.extensions.configuration.fileextensions@8.0.0
microsoft.extensions.configuration.json@8.0.0
microsoft.extensions.configuration.usersecrets@8.0.0
microsoft.extensions.configuration@2.1.1
microsoft.extensions.configuration@8.0.0
microsoft.extensions.dependencyinjection.abstractions@2.0.0
microsoft.extensions.dependencyinjection.abstractions@2.1.1
microsoft.extensions.dependencyinjection.abstractions@8.0.0
microsoft.extensions.dependencyinjection.abstractions@8.0.1
microsoft.extensions.dependencyinjection@8.0.0
microsoft.extensions.diagnostics.abstractions@8.0.0
microsoft.extensions.diagnostics@8.0.0
microsoft.extensions.fileproviders.abstractions@8.0.0
microsoft.extensions.fileproviders.physical@8.0.0
microsoft.extensions.filesystemglobbing@8.0.0
microsoft.extensions.hosting.abstractions@8.0.0
microsoft.extensions.hosting@8.0.0
microsoft.extensions.logging.abstractions@2.0.0
microsoft.extensions.logging.abstractions@2.1.1
microsoft.extensions.logging.abstractions@3.0.3
microsoft.extensions.logging.abstractions@8.0.0
microsoft.extensions.logging.abstractions@8.0.1
microsoft.extensions.logging.configuration@8.0.0
microsoft.extensions.logging.console@8.0.0
microsoft.extensions.logging.debug@8.0.0
microsoft.extensions.logging.eventlog@8.0.0
microsoft.extensions.logging.eventsource@8.0.0
microsoft.extensions.logging@2.0.0
microsoft.extensions.logging@2.1.1
microsoft.extensions.logging@8.0.0
microsoft.extensions.objectpool@8.0.5
microsoft.extensions.options.configurationextensions@8.0.0
microsoft.extensions.options@2.0.0
microsoft.extensions.options@2.1.1
microsoft.extensions.options@8.0.0
microsoft.extensions.primitives@2.0.0
microsoft.extensions.primitives@2.1.1
microsoft.extensions.primitives@8.0.0
microsoft.net.http.headers@8.0.5
microsoft.net.test.sdk@17.9.0
microsoft.netcore.platforms@1.0.1
microsoft.netcore.platforms@1.1.0
microsoft.netcore.platforms@2.0.0
microsoft.netcore.platforms@2.1.2
microsoft.netcore.platforms@3.1.0
microsoft.netcore.platforms@5.0.0
microsoft.netcore.targets@1.0.1
microsoft.netcore.targets@1.1.0
microsoft.sourcelink.common@8.0.0
microsoft.sourcelink.github@8.0.0
microsoft.testplatform.objectmodel@17.7.1
microsoft.testplatform.objectmodel@17.9.0
microsoft.testplatform.testhost@17.9.0
microsoft.visualbasic@10.0.1
microsoft.visualstudio.composition.netfxattributes@16.1.8
microsoft.visualstudio.composition@16.1.8
microsoft.visualstudio.threading.analyzers@17.10.48
microsoft.visualstudio.threading@17.10.48
microsoft.visualstudio.validation@15.0.82
microsoft.visualstudio.validation@17.8.8
microsoft.win32.primitives@4.0.1
microsoft.win32.primitives@4.3.0
microsoft.win32.registry@4.3.0
microsoft.win32.registry@5.0.0
microsoft.win32.systemevents@4.7.0
mutagen.bethesda.core@0.44.0
mutagen.bethesda.kernel@0.44.0
mutagen.bethesda.skyrim@0.44.0
nerdbank.fullduplexstream@1.1.12
nerdbank.streams@2.11.74
netescapades.enumgenerators@1.0.0-beta07
netstandard.library@1.6.0
netstandard.library@1.6.1
newtonsoft.json.bson@1.0.1
newtonsoft.json@13.0.1
newtonsoft.json@13.0.3
newtonsoft.json@9.0.1
nexusmods.archives.nx@0.4.0
nexusmods.hashing.xxhash64@2.0.1
nexusmods.mnemonicdb.abstractions@0.9.29
nexusmods.mnemonicdb.storage@0.9.29
nexusmods.mnemonicdb@0.9.29
nexusmods.paths.testinghelpers@0.9.4
nexusmods.paths@0.4.0
nexusmods.paths@0.9.4
nlog.extensions.logging@5.3.11
nlog@5.3.2
noggog.csharpext@2.64.0
nsubstitute.analyzers.csharp@1.0.17
nsubstitute@5.1.0
nuget.common@5.6.0
nuget.configuration@5.6.0
nuget.frameworks@5.6.0
nuget.frameworks@6.5.0
nuget.packaging@5.6.0
nuget.protocol@5.6.0
nuget.resolver@5.6.0
nuget.versioning@5.6.0
oneof.extended@2.1.125
oneof@2.1.125
oneof@3.0.263
opentelemetry.api.providerbuilderextensions@1.8.1
opentelemetry.api@1.8.1
opentelemetry.exporter.opentelemetryprotocol@1.8.1
opentelemetry.extensions.hosting@1.8.1
opentelemetry@1.8.1
pathoschild.http.fluentclient@4.3.0
perfolizer@0.2.1
projektanker.icons.avalonia.materialdesign@9.3.0
projektanker.icons.avalonia@9.3.0
reactiveui.fody@19.5.41
reactiveui@18.3.1
reactiveui@19.5.41
reloaded.memory@9.3.0
reloaded.memory@9.4.1
rocksdb@8.11.3.46984
runtime.any.system.collections@4.3.0
runtime.any.system.diagnostics.tools@4.3.0
runtime.any.system.diagnostics.tracing@4.3.0
runtime.any.system.globalization.calendars@4.3.0
runtime.any.system.globalization@4.3.0
runtime.any.system.io@4.3.0
runtime.any.system.reflection.extensions@4.3.0
runtime.any.system.reflection.primitives@4.3.0
runtime.any.system.reflection@4.3.0
runtime.any.system.resources.resourcemanager@4.3.0
runtime.any.system.runtime.handles@4.3.0
runtime.any.system.runtime.interopservices@4.3.0
runtime.any.system.runtime@4.3.0
runtime.any.system.text.encoding.extensions@4.3.0
runtime.any.system.text.encoding@4.3.0
runtime.any.system.threading.tasks@4.3.0
runtime.any.system.threading.timer@4.3.0
runtime.debian.8-x64.runtime.native.system.security.cryptography.openssl@4.3.0
runtime.fedora.23-x64.runtime.native.system.security.cryptography.openssl@4.3.0
runtime.fedora.24-x64.runtime.native.system.security.cryptography.openssl@4.3.0
runtime.native.system.io.compression@4.1.0
runtime.native.system.io.compression@4.3.0
runtime.native.system.net.http@4.0.1
runtime.native.system.net.http@4.3.0
runtime.native.system.security.cryptography.apple@4.3.0
runtime.native.system.security.cryptography.openssl@4.3.0
runtime.native.system.security.cryptography@4.0.0
runtime.native.system@4.0.0
runtime.native.system@4.3.0
runtime.opensuse.13.2-x64.runtime.native.system.security.cryptography.openssl@4.3.0
runtime.opensuse.42.1-x64.runtime.native.system.security.cryptography.openssl@4.3.0
runtime.osx.10.10-x64.runtime.native.system.security.cryptography.apple@4.3.0
runtime.osx.10.10-x64.runtime.native.system.security.cryptography.openssl@4.3.0
runtime.rhel.7-x64.runtime.native.system.security.cryptography.openssl@4.3.0
runtime.ubuntu.14.04-x64.runtime.native.system.security.cryptography.openssl@4.3.0
runtime.ubuntu.16.04-x64.runtime.native.system.security.cryptography.openssl@4.3.0
runtime.ubuntu.16.10-x64.runtime.native.system.security.cryptography.openssl@4.3.0
runtime.unix.microsoft.win32.primitives@4.3.0
runtime.unix.system.console@4.3.0
runtime.unix.system.diagnostics.debug@4.3.0
runtime.unix.system.io.filesystem@4.3.0
runtime.unix.system.net.primitives@4.3.0
runtime.unix.system.net.sockets@4.3.0
runtime.unix.system.private.uri@4.3.0
runtime.unix.system.runtime.extensions@4.3.0
sha3.net@2.0.0
sharpziplib@1.4.2
sharpzstd.interop@1.5.5-beta1
shimskiasharp@2.0.0-beta1
simpleinfoname@2.1.1
simpleinfoname@2.2.0
skiasharp.harfbuzz@2.88.6
skiasharp.harfbuzz@2.88.7
skiasharp.nativeassets.linux@2.88.3
skiasharp.nativeassets.linux@2.88.7
skiasharp.nativeassets.linux@2.88.8
skiasharp.nativeassets.macos@2.88.3
skiasharp.nativeassets.macos@2.88.6
skiasharp.nativeassets.macos@2.88.7
skiasharp.nativeassets.macos@2.88.8
skiasharp.nativeassets.webassembly@2.88.3
skiasharp.nativeassets.webassembly@2.88.7
skiasharp.nativeassets.webassembly@2.88.8
skiasharp.nativeassets.win32@2.88.3
skiasharp.nativeassets.win32@2.88.6
skiasharp.nativeassets.win32@2.88.7
skiasharp.nativeassets.win32@2.88.8
skiasharp@2.88.3
skiasharp@2.88.6
skiasharp@2.88.7
skiasharp@2.88.8
spectre.console.cli@0.49.1
spectre.console.testing@0.49.1
spectre.console@0.49.1
splat.microsoft.extensions.logging@15.0.1
splat@14.4.1
splat@14.8.12
splat@15.0.1
svg.custom@2.0.0-beta1
svg.model@2.0.0-beta1
svg.skia@2.0.0-beta1
system.appcontext@4.1.0
system.appcontext@4.3.0
system.buffers@4.0.0
system.buffers@4.3.0
system.buffers@4.5.1
system.codedom@5.0.0
system.codedom@6.0.0
system.codedom@8.0.0
system.collections.concurrent@4.0.12
system.collections.concurrent@4.3.0
system.collections.immutable@1.1.36
system.collections.immutable@1.2.0
system.collections.immutable@5.0.0
system.collections.immutable@7.0.0
system.collections.immutable@8.0.0
system.collections@4.0.11
system.collections@4.3.0
system.commandline@2.0.0-beta4.22272.1
system.componentmodel.annotations@4.3.0
system.componentmodel.annotations@4.5.0
system.componentmodel.annotations@5.0.0
system.componentmodel.composition@4.5.0
system.componentmodel@4.3.0
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
system.configuration.configurationmanager@4.4.0
system.console@4.0.0
system.console@4.3.0
system.diagnostics.debug@4.0.0
system.diagnostics.debug@4.0.11
system.diagnostics.debug@4.3.0
system.diagnostics.diagnosticsource@4.0.0
system.diagnostics.diagnosticsource@4.3.0
system.diagnostics.diagnosticsource@8.0.0
system.diagnostics.eventlog@6.0.0
system.diagnostics.eventlog@8.0.0
system.diagnostics.process@4.3.0
system.diagnostics.tools@4.0.0
system.diagnostics.tools@4.0.1
system.diagnostics.tools@4.3.0
system.diagnostics.tracing@4.1.0
system.diagnostics.tracing@4.3.0
system.drawing.common@4.7.0
system.dynamic.runtime@4.0.11
system.dynamic.runtime@4.3.0
system.globalization.calendars@4.0.1
system.globalization.calendars@4.3.0
system.globalization.extensions@4.0.1
system.globalization.extensions@4.3.0
system.globalization@4.0.0
system.globalization@4.0.11
system.globalization@4.3.0
system.io.abstractions@19.1.5
system.io.abstractions@20.0.28
system.io.compression.zipfile@4.0.1
system.io.compression.zipfile@4.3.0
system.io.compression@4.1.0
system.io.compression@4.3.0
system.io.filesystem.primitives@4.0.1
system.io.filesystem.primitives@4.3.0
system.io.filesystem@4.0.1
system.io.filesystem@4.3.0
system.io.hashing@7.0.0
system.io.hashing@8.0.0
system.io.pipelines@6.0.0
system.io.pipelines@6.0.3
system.io.pipelines@7.0.0
system.io.pipelines@8.0.0
system.io@4.1.0
system.io@4.3.0
system.linq.async@6.0.1
system.linq.expressions@4.1.0
system.linq.expressions@4.3.0
system.linq@4.0.0
system.linq@4.1.0
system.linq@4.3.0
system.management@5.0.0
system.management@6.0.2
system.management@8.0.0
system.memory@4.5.1
system.memory@4.5.3
system.memory@4.5.4
system.memory@4.5.5
system.net.http@4.1.0
system.net.http@4.3.0
system.net.nameresolution@4.3.0
system.net.primitives@4.0.11
system.net.primitives@4.3.0
system.net.sockets@4.1.0
system.net.sockets@4.3.0
system.numerics.vectors@4.4.0
system.numerics.vectors@4.5.0
system.objectmodel@4.0.12
system.objectmodel@4.3.0
system.private.uri@4.3.0
system.reactive@5.0.0
system.reactive@6.0.0
system.reactive@6.0.1
system.reflection.emit.ilgeneration@4.0.1
system.reflection.emit.ilgeneration@4.3.0
system.reflection.emit.lightweight@4.0.1
system.reflection.emit.lightweight@4.3.0
system.reflection.emit@4.0.1
system.reflection.emit@4.3.0
system.reflection.emit@4.7.0
system.reflection.extensions@4.0.1
system.reflection.extensions@4.3.0
system.reflection.metadata@1.0.21
system.reflection.metadata@1.3.0
system.reflection.metadata@1.6.0
system.reflection.metadata@5.0.0
system.reflection.metadata@7.0.0
system.reflection.primitives@4.0.1
system.reflection.primitives@4.3.0
system.reflection.typeextensions@4.1.0
system.reflection.typeextensions@4.3.0
system.reflection@4.0.0
system.reflection@4.1.0
system.reflection@4.3.0
system.resources.resourcemanager@4.0.0
system.resources.resourcemanager@4.0.1
system.resources.resourcemanager@4.3.0
system.runtime.compilerservices.unsafe@4.4.0
system.runtime.compilerservices.unsafe@4.5.3
system.runtime.compilerservices.unsafe@4.7.1
system.runtime.compilerservices.unsafe@5.0.0
system.runtime.compilerservices.unsafe@6.0.0
system.runtime.extensions@4.1.0
system.runtime.extensions@4.3.0
system.runtime.handles@4.0.1
system.runtime.handles@4.3.0
system.runtime.interopservices.runtimeinformation@4.0.0
system.runtime.interopservices.runtimeinformation@4.3.0
system.runtime.interopservices@4.1.0
system.runtime.interopservices@4.3.0
system.runtime.numerics@4.0.1
system.runtime.numerics@4.3.0
system.runtime.serialization.primitives@4.1.1
system.runtime@4.0.0
system.runtime@4.1.0
system.runtime@4.3.0
system.security.accesscontrol@4.5.0
system.security.accesscontrol@4.7.0
system.security.accesscontrol@5.0.0
system.security.claims@4.3.0
system.security.cryptography.algorithms@4.2.0
system.security.cryptography.algorithms@4.3.0
system.security.cryptography.cng@4.2.0
system.security.cryptography.cng@4.3.0
system.security.cryptography.csp@4.0.0
system.security.cryptography.csp@4.3.0
system.security.cryptography.encoding@4.0.0
system.security.cryptography.encoding@4.3.0
system.security.cryptography.openssl@4.0.0
system.security.cryptography.openssl@4.3.0
system.security.cryptography.primitives@4.0.0
system.security.cryptography.primitives@4.3.0
system.security.cryptography.protecteddata@4.3.0
system.security.cryptography.protecteddata@4.4.0
system.security.cryptography.x509certificates@4.1.0
system.security.cryptography.x509certificates@4.3.0
system.security.permissions@4.5.0
system.security.permissions@4.7.0
system.security.principal.windows@4.3.0
system.security.principal.windows@4.5.0
system.security.principal.windows@4.7.0
system.security.principal.windows@5.0.0
system.security.principal@4.3.0
system.text.encoding.codepages@4.5.1
system.text.encoding.codepages@7.0.0
system.text.encoding.codepages@8.0.0
system.text.encoding.extensions@4.0.11
system.text.encoding.extensions@4.3.0
system.text.encoding@4.0.11
system.text.encoding@4.3.0
system.text.encodings.web@7.0.0
system.text.encodings.web@8.0.0
system.text.json@7.0.0
system.text.json@8.0.0
system.text.json@8.0.3
system.text.regularexpressions@4.1.0
system.text.regularexpressions@4.3.0
system.threading.channels@7.0.0
system.threading.channels@8.0.0
system.threading.tasks.dataflow@4.6.0
system.threading.tasks.extensions@4.0.0
system.threading.tasks.extensions@4.3.0
system.threading.tasks.extensions@4.5.4
system.threading.tasks@4.0.0
system.threading.tasks@4.0.11
system.threading.tasks@4.3.0
system.threading.thread@4.3.0
system.threading.threadpool@4.3.0
system.threading.timer@4.0.1
system.threading.timer@4.3.0
system.threading@4.0.11
system.threading@4.3.0
system.valuetuple@4.5.0
system.windows.extensions@4.7.0
system.xml.readerwriter@4.0.11
system.xml.readerwriter@4.3.0
system.xml.xdocument@4.0.11
system.xml.xdocument@4.3.0
testableio.system.io.abstractions.wrappers@19.1.5
testableio.system.io.abstractions.wrappers@20.0.28
testableio.system.io.abstractions@19.1.5
testableio.system.io.abstractions@20.0.28
textmatesharp.grammars@1.0.56
textmatesharp@1.0.56
tmds.dbus.protocol@0.16.0
transparentvalueobjects@1.0.1
validation@2.3.7
validation@2.4.18
valvekeyvalue@0.8.2.162
valvekeyvalue@0.9.0.267
verify.imagemagick@3.4.2
verify.sourcegenerators@2.2.0
verify.xunit@24.2.0
verify@21.3.0
verify@24.2.0
vogen@3.0.20
vogen@3.0.24
xunit.abstractions@2.0.1
xunit.abstractions@2.0.2
xunit.abstractions@2.0.3
xunit.analyzers@1.13.0
xunit.assert@2.3.0
xunit.assert@2.8.0
xunit.core@2.8.0
xunit.dependencyinjection.logging@9.0.0
xunit.dependencyinjection.skippablefact@9.0.0
xunit.dependencyinjection@9.3.0
xunit.extensibility.core@2.2.0
xunit.extensibility.core@2.4.0
xunit.extensibility.core@2.4.2
xunit.extensibility.core@2.8.0
xunit.extensibility.execution@2.4.0
xunit.extensibility.execution@2.4.2
xunit.extensibility.execution@2.8.0
xunit.runner.visualstudio@2.8.0
xunit.skippablefact@1.4.13
xunit@2.8.0
"

inherit desktop dotnet-pkg xdg git-r3

DESCRIPTION="Nexus Mods App is a mod installer, creator and manager for all your popular games"
HOMEPAGE="
	https://nexus-mods.github.io/NexusMods.App/
	https://github.com/Nexus-Mods/NexusMods.App
"
EGIT_REPO_URI="https://github.com/Nexus-Mods/NexusMods.App.git"

if [[ "${PV}" != *9999* ]]; then
	EGIT_COMMIT="v${PV}"
	KEYWORDS="~amd64"
fi

SRC_URI="${NUGET_URIS}"
LICENSE="GPL-3 Apache-2.0 BSD-2 BSD MIT"
SLOT="0"

RDEPEND="
	>=dev-libs/rocksdb-8.11.3
	app-arch/7zip
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

DOTNET_PKG_PROJECTS=(
	"src/NexusMods.App/NexusMods.App.csproj"
)

DOTNET_PKG_BUILD_EXTRA_ARGS+=(
	"/p:TieredCompilation=true"
	"/p:DefineConstants=INSTALLATION_METHOD_PACKAGE_MANAGER"
)

DOTNET_PKG_TEST_EXTRA_ARGS+=(
	"--filter \"RequiresNetworking==True\""
)

src_prepare() {
	rm src/src.sln
	dotnet-pkg_src_prepare
}

src_unpack() {
	dotnet-pkg_src_unpack
	git-r3_src_unpack
}

# error MSB1001 due to --filter switch not being recognized??
# -> edotnet fucks something up?
src_test() {
	dotnet test -c Release --filter "RequiresNetworking==True" --no-restore
}

src_compile() {
	export NEXUSMODS_APP_USE_SYSTEM_EXTRACTOR=1
	export INSTALLATION_METHOD_PACKAGE_MANAGER
	dotnet-pkg_src_compile
}

src_install() {
	rm -fv "${DOTNET_PKG_OUTPUT}/librocksdb.so" \
		"${DOTNET_PKG_OUTPUT}/librocksdb-musl.so" \
		"${DOTNET_PKG_OUTPUT}/librocksdb-jemalloc.so"
	dotnet-pkg-base_install
	dotnet-pkg-base_dolauncher "/usr/share/${P}/nexusmods" "nexusmods"

	doicon -s scalable src/NexusMods.App.UI/Assets/nexus-logo.svg
	domenu "${FILESDIR}/${PN}-nxm.desktop"
	domenu "${FILESDIR}/${PN}.desktop"
}
