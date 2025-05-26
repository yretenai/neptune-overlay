# Copyright 2023-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Nuget Source Config for Godot"
HOMEPAGE="https://docs.godotengine.org/en/4.3/contributing/development/compiling/compiling_with_dotnet.html"
S="${WORKDIR}"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
RESTRICT="test"

src_unpack() {
	cat > Godot.config <<-EOF
<?xml version="1.0" encoding="utf-8"?>
<configuration>
	<packageSources>
		<add key="Godot" value="/usr/share/godot/nugets" />
	</packageSources>
</configuration>
EOF
}

src_install() {
	insinto "/etc/opt/NuGet/Config"
	doins Godot.config
}
