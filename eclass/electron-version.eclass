# Copyright 2023-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: electron-version.eclass
# @SUPPORTED_EAPIS: 8
# @BLURB: Eclass for tracking Electron versions
# @MAINTAINER:
# Ada <ada@chronovore.dev>
# @AUTHOR:
# Ada <ada@chronovore.dev>

# @ECLASS_VARIABLE: LATEST_ELECTRON_VER
# @DESCRIPTION:
# Latest version of electron

# @ECLASS_VARIABLE: LATEST_ELECTRON_WIDEVINE_VER
# @DESCRIPTION:
# Latest version of electron with widevine support

# @ECLASS_VARIABLE: LATEST_ELECTRON_BUILDER_VER
# @DESCRIPTION:
# Latest version of electron builder

# NOTE: when updating these, bump the revision of every ebuild that depends on this

LATEST_ELECTRON_VER="36"
LATEST_ELECTRON_WIDEVINE_VER="36"
LATEST_ELECTRON_BUILDER_VER="26.0.12"
