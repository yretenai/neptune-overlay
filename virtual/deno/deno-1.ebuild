# Copyright 2023-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Deno Virtual"

SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"

RDEPEND="
	|| (
		dev-lang/deno
		dev-lang/deno-bin
	)
"
