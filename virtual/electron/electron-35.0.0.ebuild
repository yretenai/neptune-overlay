# Copyright 2023-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Electron Virtual"

SLOT="$(ver_cut 1)/${PV}"
KEYWORDS="-* ~amd64 ~arm ~arm64"

# TODO: source-build electron
RDEPEND="
	dev-electron/electron-sets
	|| (
		=dev-electron/electron-bin-${PV}*:=
	)
"
