# Copyright 2023-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Electron Virtual"

SLOT="$(ver_cut 1)"
KEYWORDS="-* ~amd64 ~arm ~arm64"
RESTRICT="test"

# TODO: source-build electron
RDEPEND="
	|| (
		dev-electron/electron-bin:${SLOT}=
	)
"
