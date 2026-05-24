# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit multilib-minimal

DESCRIPTION="D3D12 to Vulkan translation library"
HOMEPAGE="https://gitlab.winehq.org/wine/vkd3d/"
if [[ ${PV} == *9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://gitlab.winehq.org/wine/vkd3d.git"
else
	SRC_URI="https://dl.winehq.org/vkd3d/source/vkd3d-${PV}.tar.xz"
	KEYWORDS="~amd64 ~arm64 ~x86"
	S="${WORKDIR}/vkd3d-${PV}"
fi

LICENSE="LGPL-2.1+"
SLOT="0"
IUSE="ncurses spirv-tools examples"
RESTRICT="test" #838655

RDEPEND="
	media-libs/vulkan-loader[${MULTILIB_USEDEP}]
	ncurses? ( sys-libs/ncurses:= )
	spirv-tools? ( dev-util/spirv-tools[${MULTILIB_USEDEP}] )
"
DEPEND="
	${RDEPEND}
	dev-util/spirv-headers
	dev-util/vulkan-headers
	examples? (
		x11-libs/libxcb[${MULTILIB_USEDEP}]
		x11-libs/xcb-util[${MULTILIB_USEDEP}]
		x11-libs/xcb-util-wm[${MULTILIB_USEDEP}]
		x11-libs/xcb-util-keysyms[${MULTILIB_USEDEP}]
	)
"
BDEPEND="
	sys-devel/flex
	sys-devel/bison
	dev-perl/JSON
	virtual/pkgconfig
"

multilib_src_configure() {
	local conf=(
		$(multilib_native_use_with ncurses)
		$(use_with spirv-tools)
		--disable-doxygen-pdf
		$(use_with examples xcb)
		$(use_enable examples demos)
		# let users' flags control lto (bug #933178)
		vkd3d_cv_cflags__flto_auto=
	)

	ECONF_SOURCE=${S} econf "${conf[@]}"
}

multilib_src_install_all() {
	einstalldocs

	find "${ED}" -type f -name '*.la' -delete || die
}
