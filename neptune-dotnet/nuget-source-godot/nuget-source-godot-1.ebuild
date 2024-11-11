# Copyright 2023-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Nuget Source Config for Godot"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~x86"
RESTRICT="test"

S="${WORKDIR}"

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
