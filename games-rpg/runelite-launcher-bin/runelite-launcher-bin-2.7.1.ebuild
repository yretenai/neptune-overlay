# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

CANONICAL_NAME="RuneLite"

inherit desktop java-pkg-2 xdg
DESCRIPTION="A popular free, open-source and super fast client for Old School RuneScape"
HOMEPAGE="
    https://runelite.net/
    https://github.com/runelite
"

SRC_URI="https://github.com/runelite/launcher/releases/download/${PV}/RuneLite.jar -> ${P}.jar"

LICENSE="BSD-2-Clause"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
RESTRICT="bindist mirror"

RDEPEND=">=virtual/jre-17"

S="${WORKDIR}"

src_unpack() {
	return
}

src_install() {
	java-pkg_newjar "${DISTDIR}/${P}.jar" ${P}.jar
	java-pkg_dolauncher "${CANONICAL_NAME}" --jar "${P}.jar" --main net.runelite.launcher.Launcher --java_args "-Xmx768m -Xss2m -XX:CompileThreshold=1500"
	doicon "${FILESDIR}/runelite.png"
	make_desktop_entry "${CANONICAL_NAME}" "RuneLite" "runelite" "Game" "StartupWMClass=net-runelite-launcher-Launcher"
}