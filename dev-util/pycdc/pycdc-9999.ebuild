# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake git-r3

EGIT_REPO_URI="https://github.com/zrax/pycdc.git"
DESCRIPTION="C++ python bytecode disassembler and decompiler"
HOMEPAGE="https://github.com/zrax/pycdc"
LICENSE="MIT"
SLOT="0"

# requires python 3.6+ for tests
RESTRICT="test"
