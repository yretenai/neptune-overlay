# Copyright 2020-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake git-r3

DESCRIPTION="The open source OpenXR runtime"
HOMEPAGE="https://monado.dev"
EGIT_REPO_URI="https://gitlab.freedesktop.org/monado/monado.git"
LICENSE="Boost-1.0"
SLOT="0"

IUSE="doc test onnx bluetooth dbus ffmpeg gstreamer opencv sdl systemd uvc vulkan wayland steam zlib hid X
monado_drivers_arduino monado_drivers_daydream monado_drivers_euroc monado_drivers_twrap monado_drivers_hdk
monado_drivers_hydra monado_drivers_ns monado_drivers_opengloves monado_drivers_psmv monado_drivers_pssense
monado_drivers_psvr monado_drivers_qwerty monado_drivers_remote monado_drivers_rift monado_drivers_rokid
monado_drivers_steamvr monado_drivers_vf monado_drivers_vive monado_drivers_wmr monado_drivers_xreal
monado_drivers_simulavr monado_drivers_handtracking
"

# monado_drivers_depthai monado_drivers_handtracking monado_drivers_illixr
# monado_drivers_openhmd monado_drivers_realsense monado_drivers_survive
# monado_drivers_ulv2 monado_drivers_ulv5

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
	onnx? ( sci-libs/onnxruntime )
"
RDEPEND="
	${DEPEND}	
	media-libs/basalt-xr
"
BDEPEND="
	doc? (
		app-text/doxygen
		media-gfx/graphviz
	)
"

REQUIRED_USE="
	monado_drivers_arduino? ( dbus )
	monado_drivers_daydream? ( dbus )
	monado_drivers_euroc? ( opencv )
	monado_drivers_opengloves? ( bluetooth )
	monado_drivers_psvr? ( hid )
	monado_drivers_qwerty? ( sdl )
	monado_drivers_steamvr? ( steam monado_drivers_vive )
	monado_drivers_vf? ( gstreamer )
	monado_drivers_vive? ( zlib )
	monado_drivers_handtracking? ( onnx )
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
		-DXRT_HAVE_ONNXRUNTIME=$(usex onnx)
		-DXRT_HAVE_OPENCV=$(usex opencv)
		-DXRT_HAVE_PERCETTO=OFF # todo
		-DXRT_HAVE_SDL2=$(usex sdl)
		-DXRT_HAVE_STEAM=$(usex steam)
		-DXRT_HAVE_SYSTEM_CJSON=ON
		-DXRT_HAVE_TRACY=OFF # todo

		-DXRT_BUILD_DRIVER_ANDROID=OFF
		-DXRT_BUILD_DRIVER_ARDUINO=$(usex monado_drivers_arduino)
		-DXRT_BUILD_DRIVER_DAYDREAM=$(usex monado_drivers_daydream)
		-DXRT_BUILD_DRIVER_DEPTHAI=OFF # todo: DepthAI
		-DXRT_BUILD_DRIVER_EUROC=$(usex monado_drivers_euroc)
		-DXRT_BUILD_DRIVER_HANDTRACKING=$(usex monado_drivers_handtracking)
		-DXRT_BUILD_DRIVER_HDK=$(usex monado_drivers_hdk)
		-DXRT_BUILD_DRIVER_HYDRA=$(usex monado_drivers_hydra)
		-DXRT_BUILD_DRIVER_ILLIXR=OFF # todo: ILLIXR
		-DXRT_BUILD_DRIVER_NS=$(usex monado_drivers_ns)
		-DXRT_BUILD_DRIVER_OHMD=OFF # todo: OpenHMD
		-DXRT_BUILD_DRIVER_OPENGLOVES=$(usex monado_drivers_opengloves)
		-DXRT_BUILD_DRIVER_PSMV=$(usex monado_drivers_psmv)
		-DXRT_BUILD_DRIVER_PSSENSE=$(usex monado_drivers_pssense)
		-DXRT_BUILD_DRIVER_PSVR=$(usex monado_drivers_psvr)
		-DXRT_BUILD_DRIVER_QWERTY=$(usex monado_drivers_qwerty)
		-DXRT_BUILD_DRIVER_REALSENSE=OFF # todo: RealSense SDK
		-DXRT_BUILD_DRIVER_REMOTE=$(usex monado_drivers_remote)
		-DXRT_BUILD_DRIVER_RIFT_S=$(usex monado_drivers_rift)
		-DXRT_BUILD_DRIVER_ROKID=$(usex monado_drivers_rokid)
		-DXRT_BUILD_DRIVER_SIMULAVR=$(usex monado_drivers_simulavr)
		-DXRT_BUILD_DRIVER_STEAMVR_LIGHTHOUSE=$(usex monado_drivers_steamvr)
		-DXRT_BUILD_DRIVER_SURVIVE=OFF # todo: survive
		-DXRT_BUILD_DRIVER_TWRAP=$(usex monado_drivers_twrap)
		-DXRT_BUILD_DRIVER_ULV2=OFF # todo: LeapV2 SDK
		-DXRT_BUILD_DRIVER_ULV5=OFF # todo: LeapV5 SDK
		-DXRT_BUILD_DRIVER_VF=$(usex monado_drivers_vf)
		-DXRT_BUILD_DRIVER_VIVE=$(usex monado_drivers_vive)
		-DXRT_BUILD_DRIVER_WMR=$(usex monado_drivers_wmr)
		-DXRT_BUILD_DRIVER_XREAL_AIR=$(usex monado_drivers_xreal)

		-DXRT_INSTALL_SYSTEMD_UNIT_FILES=$(usex systemd)

		-DBUILD_TESTING=$(usex test)
		-DBUILD_DOC=$(usex doc)
	)

	cmake_src_configure
}
