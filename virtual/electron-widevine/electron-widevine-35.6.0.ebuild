# Copyright 2023-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Electron Virtual With Widevine"

SLOT="$(ver_cut 1)/${PV}"
KEYWORDS="-* ~amd64"

# TODO: source-build electron with widevine component updater service
RDEPEND="
	app-portage/electron-rebuild-set
	|| (
		=dev-electron/electron-wvcus-bin-${PV}*
	)
"
