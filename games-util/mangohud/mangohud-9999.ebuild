# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )

inherit flag-o-matic python-single-r1 meson-multilib

MY_PV=$(ver_cut 1-3)
[[ -n "$(ver_cut 4)" ]] && MY_PV_REV="-$(ver_cut 4)"

DESCRIPTION="Vulkan and OpenGL overlay for monitoring FPS, sensors, system load and more"
HOMEPAGE="https://github.com/flightlessmango/MangoHud"

IMGUI_VER="1.91.6"
IMGUI_MESON_WRAP_VER="3"
IMPLOT_VER="0.16"
IMPLOT_MESON_WRAP_VER="1"
VKROOTS_VER="5106d8a0df95de66cc58dc1ea37e69c99afc9540"
VKBOOTSTRAP_VER="1.4.328"

SRC_URI="
	https://github.com/ocornut/imgui/archive/refs/tags/v${IMGUI_VER}.tar.gz
		-> imgui-v${IMGUI_VER}.tar.gz
	https://wrapdb.mesonbuild.com/v2/imgui_${IMGUI_VER}-${IMPLOT_MESON_WRAP_VER}/get_patch
		-> imgui-${IMGUI_VER}-${IMPLOT_MESON_WRAP_VER}-meson-wrap.zip
	https://github.com/epezent/implot/archive/refs/tags/v${IMPLOT_VER}.tar.gz
		-> implot-v${IMPLOT_VER}.tar.gz
	https://wrapdb.mesonbuild.com/v2/implot_${IMPLOT_VER}-${IMPLOT_MESON_WRAP_VER}/get_patch
		-> implot-${IMPLOT_VER}-${IMPLOT_MESON_WRAP_VER}-meson-wrap.zip
	https://github.com/charles-lunarg/vk-bootstrap/archive/refs/tags/v${VKBOOTSTRAP_VER}.tar.gz
		-> vk-boostrap-${VKBOOTSTRAP_VER}.tar.gz
	https://github.com/misyltoad/vkroots/archive/${VKROOTS_VER}.tar.gz
		-> vkroots-${VKROOTS_VER}.tar.gz
"

if [[ ${PV} == *9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/flightlessmango/MangoHud.git"
	EGIT_SUBMODULES=()
else
	SRC_URI="
		https://github.com/flightlessmango/MangoHud/archive/v${MY_PV}${MY_PV_REV}.tar.gz -> ${P}.tar.gz
	"
	KEYWORDS="~amd64"
	S="${WORKDIR}/MangoHud-${MY_PV}${MY_PV_REV}"
fi

LICENSE="MIT"
SLOT="0"
IUSE="+dbus debug +X xnvctrl wayland mangoapp mangohudctl mangoplot video_cards_nvidia video_cards_amdgpu test"
RESTRICT="!test? ( test )"

REQUIRED_USE="
	${PYTHON_REQUIRED_USE}
	|| ( X wayland )
	xnvctrl? ( video_cards_nvidia )
"

BDEPEND="
	app-arch/unzip
	dev-util/glslang
	>=dev-util/vulkan-headers-1.4.346
	>=dev-util/vulkan-utility-libraries-1.4.346
	test? ( dev-util/cmocka )
	$(python_gen_cond_dep 'dev-python/mako[${PYTHON_USEDEP}]')
"

DEPEND="
	${PYTHON_DEPS}
	dev-libs/spdlog:=[${MULTILIB_USEDEP}]
	dev-libs/libfmt:=[${MULTILIB_USEDEP}]
	dev-cpp/nlohmann_json
	x11-libs/libxkbcommon:=[${MULTILIB_USEDEP}]
	dbus? ( sys-apps/dbus[${MULTILIB_USEDEP}] )
	X? ( x11-libs/libX11[${MULTILIB_USEDEP}] )
	video_cards_nvidia? (
		x11-drivers/nvidia-drivers[${MULTILIB_USEDEP}]
		xnvctrl? ( x11-drivers/nvidia-drivers[static-libs] )
	)
	wayland? ( dev-libs/wayland[${MULTILIB_USEDEP}] )
	mangoapp? (
		media-libs/glfw[X(+)?,wayland(+)?]
		media-libs/glew
	)
"

RDEPEND="
	${DEPEND}
	media-libs/libglvnd[${MULTILIB_USEDEP}]
	media-libs/vulkan-loader[${MULTILIB_USEDEP}]
	mangoplot? (
		media-fonts/lato
		$(python_gen_cond_dep '
			|| (
				dev-python/matplotlib[gtk3,${PYTHON_USEDEP}]
				dev-python/matplotlib[qt5(-),${PYTHON_USEDEP}]
				dev-python/matplotlib[qt6(-),${PYTHON_USEDEP}]
				dev-python/matplotlib[wxwidgets,${PYTHON_USEDEP}]
			)
		')
	)
"

PATCHES=(
	"${FILESDIR}/${PN}-9999-vulkan-headers.patch"
	# "${FILESDIR}/${PN}-9999-systemd.patch"
	"${FILESDIR}/${PN}-0.8.4-VkThrottleHintTypeSEC.patch"
)

src_unpack() {
	default

	if [[ $PV == 9999 ]]; then
		git-r3_src_unpack
	fi

	mv \
		"${WORKDIR}/imgui-${IMGUI_VER}" \
		"${WORKDIR}/implot-${IMPLOT_VER}" \
		"${S}/subprojects/" || die

	mv \
		"${WORKDIR}/vk-bootstrap-${VKBOOTSTRAP_VER}" \
		"${S}/subprojects/vk-bootstrap" || die
	mv \
		"${S}/subprojects/packagefiles/vk-bootstrap/"* \
		"${S}/subprojects/vk-bootstrap" || die

	mv \
		"${WORKDIR}/vkroots-${VKROOTS_VER}" \
		"${S}/subprojects/vkroots" || die
	mv \
		"${S}/subprojects/packagefiles/vkroots/"* \
		"${S}/subprojects/vkroots" || die
}

multilib_src_configure() {
	# workaround for lld
	# https://github.com/flightlessmango/MangoHud/issues/1240
	append-ldflags $(test-flags-CCLD -Wl,--undefined-version)

	local emesonargs=(
		-Dappend_libdir_mangohud=false
		-Dinclude_doc=false
		-Duse_system_spdlog=enabled
		$(meson_feature video_cards_nvidia with_nvml)
		$(meson_feature xnvctrl with_xnvctrl)
		$(meson_feature X with_x11)
		$(meson_feature wayland with_wayland)
		$(meson_feature dbus with_dbus)
		$(meson_use mangoapp mangoapp)
		$(meson_use mangohudctl mangohudctl)
		$(meson_feature mangoplot mangoplot)
	)
	meson_src_configure
}

pkg_postinst() {
	if ! use xnvctrl; then
		einfo ""
		einfo "If mangohud can't get GPU load, or other GPU information,"
		einfo "and you have an older Nvidia device."
		einfo ""
		einfo "Try enabling the 'xnvctrl' useflag."
		einfo ""
	fi
}
