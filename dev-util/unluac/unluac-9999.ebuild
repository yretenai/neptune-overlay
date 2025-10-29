# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit java-pkg-2 java-pkg-simple mercurial

JAVA_SRC_DIR="src/unluac"
JAVA_MAIN_CLASS="unluac.Main"

EHG_REPO_URI="http://hg.code.sf.net/p/${PN}/hgcode"

DESCRIPTION="A decompiler for Lua 5.0 through 5.4"
HOMEPAGE="https://sourceforge.net/projects/unluac"
S="${WORKDIR}/${PN}"
LICENSE="MIT"
SLOT="0"

DEPEND=">=virtual/jdk-17:*"
RDEPEND=">=virtual/jre-17:*"
BDEPEND="
	app-text/dos2unix
"

RESTRICT="test"

src_prepare() {
	find "${S}" -iname "*.java" -exec dos2unix {} \;
	eapply_user
	default
}
