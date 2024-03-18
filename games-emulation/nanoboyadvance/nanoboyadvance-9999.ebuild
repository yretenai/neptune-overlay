EAPI=8

PYTHON_COMPAT=( python3_{10..12} )

inherit cmake git-r3 python-single-r1

DESCRIPTION="A cycle-accurate Nintendo Game Boy Advance emulator"
HOMEPAGE="https://github.com/nba-emu/NanoBoyAdvance"

EGIT_REPO_URI="https://github.com/nba-emu/${PN}.git"
GLAD_EGIT_REPO_URI="https://github.com/Dav1dde/glad.git"

KEYWORDS=""
IUSE="qt6 +qt5"
REQUIRED_USE="^^ ( qt6 qt5 )"

PATCHES=(
	"${FILESDIR}/9999-add-algorithms.patch"
	"${FILESDIR}/9999-load-glad.patch"
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
	$(python_gen_cond_dep '
		>=dev-python/jinja-2.7[${PYTHON_USEDEP}]
	')
	dev-cpp/toml11
"

src_unpack() {
	git-r3_src_unpack

	git-r3_fetch "${GLAD_EGIT_REPO_URI}"
	git-r3_checkout "${GLAD_EGIT_REPO_URI}" "${S}/glad"
}

src_configure() {
	sed -e "s|find_package(Python |find_package(Python ${EPYTHON:6} EXACT |" -i glad/cmake/GladConfig.cmake || die

	local mycmakeargs=(
		-DPORTABLE_MODE=OFF
		-DBUILD_SHARED_LIBS=OFF
		-DUSE_QT6=$(usex qt6)
		-DUSE_SYSTEM_TOML11=ON
		-DUSE_SYSTEM_UNARR=ON
		-DUSE_SYSTEM_FMT=ON
		-DRELEASE_BUILD=ON
	)

	cmake_src_configure
}

