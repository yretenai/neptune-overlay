# Copyright 2020-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake git-r3

DESCRIPTION="The open source OpenXR runtime"
HOMEPAGE="https://monado.dev"
EGIT_REPO_URI="https://gitlab.freedesktop.org/monado/monado.git"
LICENSE="Boost-1.0"
SLOT="0"

IUSE="doc test bluetooth dbus ffmpeg gstreamer opencv sdl systemd uvc vulkan wayland steam zlib hid X
monado_driver_arduino monado_driver_daydream monado_driver_euroc monado_driver_twrap monado_driver_hdk
monado_driver_hydra monado_driver_ns monado_driver_opengloves monado_driver_psmv monado_driver_pssense
monado_driver_psvr monado_driver_qwerty monado_driver_remote monado_driver_rift monado_driver_rokid
monado_driver_steamvr monado_driver_vf monado_driver_vive monado_driver_wmr monado_driver_xreal
monado_driver_simulavr
"

# monado_driver_depthai monado_driver_handtracking monado_driver_illixr
# monado_driver_openhmd monado_driver_realsense monado_driver_survive
# monado_driver_ulv2 monado_driver_ulv5

DEPEND="
	media-libs/openxr-loader
	media-libs/mesa[egl(+)]
	dev-cpp/eigen:3
	dev-util/glslang
	virtual/libusb:=
	virtual/libudev
	virtual/opengl:=
	media-libs/libv4l
	dev-libs/libbsd
	dev-libs/cJSON
	wayland? (
		dev-libs/wayland
		dev-libs/wayland-protocols
		dev-util/wayland-scanner
	)
	X? (
		x11-libs/libX11
		x11-libs/libXrandr
		x11-libs/libxcb
	)
	vulkan? (
		media-libs/vulkan-loader
		dev-util/vulkan-headers
	)
	opencv? ( media-libs/opencv:= )
	dbus? ( sys-apps/dbus )
	systemd? ( sys-apps/systemd:= )
	uvc? ( media-libs/libuvc )
	ffmpeg? ( media-video/ffmpeg:= )
	sdl? ( media-libs/libsdl2 )
	gstreamer? ( media-libs/gstreamer )
	hid? ( dev-libs/hidapi )
	zlib? ( sys-libs/zlib:= )
	bluetooth? ( net-wireless/bluez:= )
"
RDEPEND="${DEPEND}"
BDEPEND="
	doc? (
		app-text/doxygen
		media-gfx/graphviz
	)
"

REQUIRED_USE="
	monado_driver_arduino? ( dbus )
	monado_driver_daydream? ( dbus )
	monado_driver_euroc? ( opencv )
	monado_driver_opengloves? ( bluetooth )
	monado_driver_psvr? ( hid )
	monado_driver_qwerty? ( sdl )
	monado_driver_steamvr? ( steam monado_driver_vive )
	monado_driver_vf? ( gstreamer )
	monado_driver_vive? ( zlib )
"
RESTRICT="
	!test? ( test )
"

src_configure() {
	local mycmakeargs=(
		-DXRT_HAVE_WAYLAND=$(usex wayland)
		-DXRT_HAVE_WAYLAND_DIRECT=$(usex wayland)
		-DXRT_HAVE_XLIB=$(usex X)
		-DXRT_HAVE_XRANDR=$(usex X)
		-DXRT_HAVE_XCB=$(usex X)
		-DXRT_HAVE_D3D11=OFF
		-DXRT_HAVE_D3D12=OFF

		-DXRT_HAVE_VULKAN=$(usex vulkan)
		-DXRT_HAVE_OPENGL=ON
		-DXRT_HAVE_OPENGL_GLX=ON
		-DXRT_HAVE_OPENGLES=ON
		-DXRT_HAVE_EGL=ON
		-DXRT_HAVE_LIBBSD=ON
		-DXRT_HAVE_SYSTEMD=$(usex systemd)
		-DXRT_HAVE_DXGI=OFF
		-DXRT_HAVE_WIL=OFF
		-DXRT_HAVE_WINRT=OFF

		-DXRT_HAVE_DBUS=$(usex dbus)
		-DXRT_HAVE_GST=$(usex gstreamer)
		-DXRT_HAVE_JPEG=ON
		-DXRT_HAVE_LIBUDEV=ON
		-DXRT_HAVE_LIBUSB=ON
		-DXRT_HAVE_LIBUVC=$(usex uvc)
		-DXRT_HAVE_LINUX=ON
		-DXRT_HAVE_ONNXRUNTIME=OFF # todo
		-DXRT_HAVE_OPENCV=$(usex opencv)
		-DXRT_HAVE_PERCETTO=OFF # todo
		-DXRT_HAVE_SDL2=$(usex sdl)
		-DXRT_HAVE_STEAM=$(usex steam)
		-DXRT_HAVE_SYSTEM_CJSON=ON
		-DXRT_HAVE_TRACY=OFF # todo

		-DXRT_BUILD_DRIVER_ANDROID=OFF
		-DXRT_BUILD_DRIVER_ARDUINO=$(usex monado_driver_arduino)
		-DXRT_BUILD_DRIVER_DAYDREAM=$(usex monado_driver_daydream)
		-DXRT_BUILD_DRIVER_DEPTHAI=OFF # todo: DepthAI
		-DXRT_BUILD_DRIVER_EUROC=$(usex monado_driver_euroc)
		-DXRT_BUILD_DRIVER_HANDTRACKING=OFF # todo: ONNXRuntime
		-DXRT_BUILD_DRIVER_HDK=$(usex monado_driver_hdk)
		-DXRT_BUILD_DRIVER_HYDRA=$(usex monado_driver_hydra)
		-DXRT_BUILD_DRIVER_ILLIXR=OFF # todo: ILLIXR
		-DXRT_BUILD_DRIVER_NS=$(usex monado_driver_ns)
		-DXRT_BUILD_DRIVER_OHMD=OFF # todo: OpenHMD
		-DXRT_BUILD_DRIVER_OPENGLOVES=$(usex monado_driver_opengloves)
		-DXRT_BUILD_DRIVER_PSMV=$(usex monado_driver_psmv)
		-DXRT_BUILD_DRIVER_PSSENSE=$(usex monado_driver_pssense)
		-DXRT_BUILD_DRIVER_PSVR=$(usex monado_driver_psvr)
		-DXRT_BUILD_DRIVER_QWERTY=$(usex monado_driver_qwerty)
		-DXRT_BUILD_DRIVER_REALSENSE=OFF # todo: RealSense SDK
		-DXRT_BUILD_DRIVER_REMOTE=$(usex monado_driver_remote)
		-DXRT_BUILD_DRIVER_RIFT_S=$(usex monado_driver_rift)
		-DXRT_BUILD_DRIVER_ROKID=$(usex monado_driver_rokid)
		-DXRT_BUILD_DRIVER_SIMULAVR=$(usex monado_driver_simulavr)
		-DXRT_BUILD_DRIVER_STEAMVR_LIGHTHOUSE=$(usex monado_driver_steamvr)
		-DXRT_BUILD_DRIVER_SURVIVE=OFF # todo: survive
		-DXRT_BUILD_DRIVER_TWRAP=$(usex monado_driver_twrap)
		-DXRT_BUILD_DRIVER_ULV2=OFF # todo: LeapV2 SDK
		-DXRT_BUILD_DRIVER_ULV5=OFF # todo: LeapV5 SDK
		-DXRT_BUILD_DRIVER_VF=$(usex monado_driver_vf)
		-DXRT_BUILD_DRIVER_VIVE=$(usex monado_driver_vive)
		-DXRT_BUILD_DRIVER_WMR=$(usex monado_driver_wmr)
		-DXRT_BUILD_DRIVER_XREAL_AIR=$(usex monado_driver_xreal)

		-DXRT_INSTALL_SYSTEMD_UNIT_FILES=$(usex systemd)

		-DBUILD_TESTING=$(usex test)
		-DBUILD_DOC=$(usex doc)
	)

	cmake_src_configure
}
