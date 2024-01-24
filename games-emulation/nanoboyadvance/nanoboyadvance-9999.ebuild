EAPI=8

inherit cmake

DESCRIPTION="A cycle-accurate Nintendo Game Boy Advance emulator"
HOMEPAGE="https://github.com/nba-emu/NanoBoyAdvance"

if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/nba-emu/${PN}.git"
	KEYWORDS=""
else
	SRC_URI="https://github.com/nba-emu/${PN}/releases/download/v${PV}/${P}.tar.xz"
	KEYWORDS="amd64 ~arm"
fi

IUSE="qt6 +qt5"
REQUIRED_USE="^^ ( qt6 qt5 )"

PATCHES=(
       "${FILESDIR}/9999-add-algorithms.patch"
)

LICENSE="GPL-3"
SLOT="0"

DEPEND="
	media-libs/libsdl2
	virtual/opengl
	media-libs/glew
	app-arch/unarr
	dev-libs/libfmt
	qt5? (
		dev-qt/qtcore:5
		dev-qt/qtgui:5
		dev-qt/qtwidgets:5
		dev-qt/qtopengl:5
	)
	qt6? (
		dev-qt/qtbase:6[gui,opengl,widgets]
		dev-qt/qt5compat:6
	)
"
RDEPEND="${DEPEND}"
BDEPEND="
	dev-cpp/toml11
"

src_configure() {
	local mycmakeargs=(
		-DPORTABLE_MODE=OFF
		-DUSE_QT6=$(usex qt6)
		-DUSE_SYSTEM_TOML11=ON
		-DUSE_SYSTEM_UNARR=ON
		-DUSE_SYSTEM_FMT=ON
		-DRELEASE_BUILD=ON
	)

	cmake_src_configure
}
