# Copyright 2023-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{13..14} python3_14t )
LLVM_COMPAT=( {18..20} )
LLVM_OPTIONAL=1
ROCM_VERSION="6.3"

inherit neptune-rocm check-reqs cmake cuda flag-o-matic python-single-r1 toolchain-funcs llvm-r1

DESCRIPTION="3D Creation/Animation/Publishing System"
HOMEPAGE="https://www.blender.org"
LICENSE="GPL-3+ cycles? ( Apache-2.0 )"
SLOT="0/$(ver_cut 1-2)"

if [[ ${PV} != *9999* && ${PV} != *_beta* ]]; then
	HAS_RELEASED=1
	IS_LIVE=0
	SRC_URI="
		https://download.blender.org/source/blender-${PV}.tar.xz
	"
	S="${WORKDIR}/blender-${PV}"

	KEYWORDS="~amd64"
else
	HAS_RELEASED=0
	EGIT_LFS="yes"
	inherit git-r3
	EGIT_REPO_URI="https://projects.blender.org/blender/blender.git"
	ASSETS_EGIT_REPO_URI="https://projects.blender.org/blender/blender-assets.git"
	if [[ ${PV} != *_beta* ]]; then
		EGIT_BRANCH="main"
	else
		EGIT_BRANCH="blender-v$(ver_cut 1-2)-release"
	fi
	ASSETS_EGIT_BRANCH="main"
fi

IUSE="
alembic +bullet collada +color-management cuda +cycles-bin-kernels +cycles
debug +embree experimental +ffmpeg +fftw +fluid +gmp hip hiprt jack jpeg2k
llvm +nanovdb ndof nls +oidn oneapi openal +openexr +openpgl +opensubdiv
+openvdb optix osl +otf +pdf +potrace +pugixml pulseaudio renderdoc
sdl +sndfile +tbb +tiff valgrind vulkan +wayland +webp X
"
RESTRICT="test"

REQUIRED_USE="${PYTHON_REQUIRED_USE}
	alembic? ( openexr )
	cuda? ( cycles )
	cycles? ( openexr tiff tbb )
	fluid? ( tbb )
	hip? ( cycles llvm )
	hiprt? ( hip )
	nanovdb? ( openvdb )
	openvdb? ( tbb openexr )
	optix? ( cuda )
	osl? ( cycles pugixml llvm )"

# Library versions for official builds can be found in the blender source directory in:
# build_files/build_environment/install_deps.sh
RDEPEND="${PYTHON_DEPS}
	app-arch/zstd
	dev-libs/boost:=[nls?]
	dev-libs/lzo:2=
	$(python_gen_cond_dep '
		dev-python/cython[${PYTHON_USEDEP}]
		dev-python/numpy[${PYTHON_USEDEP}]
		dev-python/zstandard[${PYTHON_USEDEP}]
		dev-python/requests[${PYTHON_USEDEP}]
	')
	media-libs/freetype:=[brotli]
	media-libs/libepoxy:=
	media-libs/libjpeg-turbo:=
	media-libs/libpng:=
	media-libs/libsamplerate
	>=media-libs/openimageio-2.5.6.0:=
	sys-libs/zlib:=
	>sci-mathematics/manifold-3.0.1:=
	virtual/glu
	virtual/libintl
	virtual/opengl
	alembic? ( >=media-gfx/alembic-1.8.3-r2[boost(+),hdf(+)] )
	collada? ( >=media-libs/opencollada-1.6.68 )
	color-management? ( media-libs/opencolorio:= )
	cuda? ( dev-util/nvidia-cuda-toolkit:= )
	embree? ( media-libs/embree:=[raymask] )
	ffmpeg? (
		media-video/ffmpeg:=[encode(+),jpeg2k?,opus,theora,vorbis,vpx,x264,xvid]
		|| ( media-video/ffmpeg[lame(-)] media-video/ffmpeg[mp3(-)] )
	)
	fftw? ( sci-libs/fftw:3.0= )
	gmp? ( dev-libs/gmp[cxx] )
	hip? ( dev-util/hip:= )
	jack? ( virtual/jack )
	jpeg2k? ( media-libs/openjpeg:2= )
	ndof? (
		app-misc/spacenavd
		dev-libs/libspnav
	)
	nls? ( virtual/libiconv )
	openal? ( media-libs/openal )
	oidn? ( >=media-libs/oidn-2.3.2:= )
	oneapi? ( || (
			dev-libs/intel-compute-runtime:0
			dev-libs/intel-compute-runtime:legacy
		)
	)
	openexr? (
		>=dev-libs/imath-3.1.7:=
		>=media-libs/openexr-3.2.1:0=
	)
	openpgl? ( media-libs/openpgl:= )
	opensubdiv? ( >=media-libs/opensubdiv-3.6.0-r2[opengl,cuda?,tbb?] )
	openvdb? (
		>=media-gfx/openvdb-11.0.0:=[nanovdb?]
		dev-libs/c-blosc:=
	)
	optix? ( dev-libs/optix )
	osl? (
		>=media-libs/osl-1.13:=[${LLVM_USEDEP}]
		media-libs/mesa[${LLVM_USEDEP}]
	)
	pdf? ( media-libs/libharu )
	potrace? ( media-gfx/potrace )
	pugixml? ( dev-libs/pugixml )
	pulseaudio? ( media-libs/libpulse )
	sdl? ( media-libs/libsdl2[sound,joystick] )
	sndfile? ( media-libs/libsndfile )
	tbb? ( >=dev-cpp/tbb-2021.13.0:= )
	tiff? ( media-libs/tiff:= )
	valgrind? ( dev-debug/valgrind )
	wayland? (
		>=dev-libs/wayland-1.12
		>=dev-libs/wayland-protocols-1.15
		>=x11-libs/libxkbcommon-0.2.0
		dev-util/wayland-scanner
		media-libs/mesa[wayland]
		sys-apps/dbus
	)
	vulkan? (
		media-libs/shaderc
		dev-util/spirv-tools
		dev-util/glslang
		media-libs/vulkan-loader
	)
	otf? (
		media-libs/harfbuzz
	)
	renderdoc? (
		media-gfx/renderdoc
	)
	X? (
		x11-libs/libX11
		x11-libs/libXi
		x11-libs/libXxf86vm
	)
	hiprt? ( dev-libs/hiprt:2.5=[${LLVM_USEDEP}] )
"

DEPEND="${RDEPEND}
	dev-cpp/eigen:=
"

BDEPEND="
	virtual/pkgconfig
	vulkan? (
		dev-util/spirv-headers
		dev-util/vulkan-headers
	)
	nls? ( sys-devel/gettext )
	wayland? (
		dev-util/wayland-scanner
	)
	llvm? (
		$(llvm_gen_dep '
			llvm-core/clang:${LLVM_SLOT}
			llvm-core/llvm:${LLVM_SLOT}
		')
	)
"

PATCHES=(
	"${FILESDIR}/${PN}-4.1.1-clang.patch"
	"${FILESDIR}/${PN}-4.4.0-hiprt-parallel.patch"
	"${FILESDIR}/${PN}-4.3.2-hipcc-path.patch"
	"${FILESDIR}/${PN}-4.4.0-cycles-runtime-path.patch"
	"${FILESDIR}/${PN}-4.5.0-freethreading.patch"
)

blender_check_requirements() {
	REQ_TOT=2

	use debug && ((REQ_TOT += 1))
	[[ ${MERGE_TYPE} != binary ]] && has splitdebug $FEATURES && ((REQ_TOT += 9))

	CHECKREQS_DISK_BUILD="${REQ_TOT}G" check-reqs_pkg_pretend
}

blender_get_version() {
	# Get blender version from blender itself.
	BV=$(grep "BLENDER_VERSION " source/blender/blenkernel/BKE_blender_version.h | cut -d " " -f 3; assert)
	if ((${BV:0:1} < 3)); then
		# Add period (290 -> 2.90).
		BV=${BV:0:1}.${BV:1}
	else
		# Add period and skip the middle number (301 -> 3.1)
		BV=${BV:0:1}.${BV:2}
	fi
}

pkg_pretend() {
	blender_check_requirements
}

pkg_setup() {
	blender_check_requirements
	python-single-r1_pkg_setup

	if use llvm; then
		llvm-r1_pkg_setup
	fi
}

src_unpack() {
	if [ "${HAS_RELEASED}" -eq 1 ]; then
		default
	else
		git-r3_fetch "${ASSETS_EGIT_REPO_URI}" "refs/heads/${ASSETS_EGIT_BRANCH}" "${CATEGORY}/${PN}/${SLOT%/*}/${ASSETS_EGIT_BRANCH}"
		git-r3_checkout "${ASSETS_EGIT_REPO_URI}" "${WORKDIR}/blender-assets" "${CATEGORY}/${PN}/${SLOT%/*}/${ASSETS_EGIT_BRANCH}"
		git-r3_src_unpack
	fi
}

src_prepare() {
	cmake_src_prepare

	blender_get_version

	# Disable MS Windows help generation. The variable doesn't do what it
	# it sounds like.
	sed -e "s|GENERATE_HTMLHELP      = YES|GENERATE_HTMLHELP      = NO|" \
		-i doc/doxygen/Doxyfile || die

	sed -e "s/\"libhiprt64.so\"/\"libhiprt64.so.2.5\"/" -i extern/hipew/src/hiprtew.cc || die
}

src_configure() {
	filter-lto
	append-ldflags $(test-flags-CCLD -Wl,--undefined-version)
	append-lfs-flags
	blender_get_version

	if use llvm; then
		CC="${CHOST}-clang"
		CXX="${CHOST}-clang++"
		AR=llvm-ar
		append-ldflags "-fuse-ld=lld"
	fi

	local mycmakeargs=(
		-DBUILD_SHARED_LIBS=no
		-DHIPRT_ROOT_DIR="/usr/include/hiprt/02005/"
		-DPYTHON_INCLUDE_DIR="$(python_get_includedir)"
		-DPYTHON_LIBRARY="$(python_get_library_path)"
		-DPYTHON_VERSION="${EPYTHON/python/}"
		-DWITH_BLENDER_THUMBNAILER=no
		-DWITH_ALEMBIC=$(usex alembic)
		-DWITH_BOOST=yes
		-DWITH_BULLET=$(usex bullet)
		-DWITH_CLANG=$(usex llvm)
		-DWITH_CODEC_FFMPEG=$(usex ffmpeg)
		-DWITH_CODEC_SNDFILE=$(usex sndfile)
		-DWITH_CPU_CHECK=no
		-DWITH_CYCLES_CUDA_BINARIES=$(usex cuda $(usex cycles-bin-kernels))
		-DWITH_CYCLES_DEVICE_CUDA=$(usex cuda)
		-DWITH_CYCLES_DEVICE_HIP=$(usex hip)
		-DWITH_CYCLES_DEVICE_HIPRT=$(usex hiprt)
		-DWITH_CYCLES_DEVICE_OPTIX=$(usex optix)
		-DWITH_CYCLES_EMBREE=$(usex embree)
		-DWITH_CYCLES_HIP_BINARIES=$(usex hip $(usex cycles-bin-kernels))
		-DWITH_CYCLES_DEVICE_ONEAPI="$(usex oneapi)"
		-DWITH_CYCLES_ONEAPI_BINARIES="$(usex oneapi $(usex cycles-bin-kernels))"
		-DCYCLES_HIP_BINARIES_ARCH="$(get_amdgpu_flags)"
		-DWITH_CYCLES_HYDRA_RENDER_DELEGATE=no # TODO: package Hydra
		-DWITH_CYCLES_ONEAPI_BINARIES=no
		-DWITH_CYCLES_OSL=$(usex osl)
		-DWITH_CYCLES_PATH_GUIDING=$(usex openpgl)
		-DWITH_CYCLES_STANDALONE_GUI=no
		-DWITH_CYCLES_STANDALONE=no
		-DWITH_CYCLES=$(usex cycles)
		-DWITH_DOC_MANPAGE=no
		-DWITH_DRACO=yes # TODO: Package Draco
		-DWITH_EXPERIMENTAL_FEATURES=$(usex experimental)
		-DWITH_FFTW3=$(usex fftw)
		-DWITH_GHOST_WAYLAND_APP_ID="blender-${BV}"
		-DWITH_GHOST_WAYLAND_DYNLOAD=no
		-DWITH_GHOST_WAYLAND_LIBDECOR=no
		-DWITH_GHOST_WAYLAND=$(usex wayland)
		-DWITH_GHOST_X11=$(usex X)
		-DWITH_GMP=$(usex gmp)
		-DWITH_GTESTS=no
		-DWITH_HARFBUZZ=$(usex otf)
		-DWITH_HARU=$(usex pdf)
		-DWITH_HEADLESS="$(usex !X "$(usex !wayland)")"
		-DWITH_HYDRA=no # TODO: Package Hydra
		-DWITH_IMAGE_OPENEXR=$(usex openexr)
		-DWITH_IMAGE_OPENJPEG=$(usex jpeg2k)
		-DWITH_IMAGE_WEBP=$(usex webp)
		-DWITH_INPUT_NDOF=$(usex ndof)
		-DWITH_INSTALL_PORTABLE=no
		-DWITH_INTERNATIONAL=$(usex nls)
		-DWITH_JACK=$(usex jack)
		-DWITH_LIBS_PRECOMPILED=no
		-DWITH_LLVM=$(usex llvm)
		-DWITH_MATERIALX=no # TODO: Package MaterialX
		-DWITH_MEM_JEMALLOC=off
		-DWITH_MEM_VALGRIND=$(usex valgrind)
		-DWITH_MOD_FLUID=$(usex fluid)
		-DWITH_MOD_OCEANSIM=$(usex fftw)
		-DWITH_NANOVDB=$(usex nanovdb)
		-DWITH_OPENAL=$(usex openal)
		-DWITH_OPENCOLLADA=$(usex collada)
		-DWITH_OPENCOLORIO=$(usex color-management)
		-DWITH_OPENIMAGEDENOISE=$(usex oidn)
		-DWITH_OPENSUBDIV=$(usex opensubdiv)
		-DWITH_OPENVDB_BLOSC=$(usex openvdb)
		-DWITH_OPENVDB=$(usex openvdb)
		-DWITH_POTRACE=$(usex potrace)
		-DWITH_PUGIXML=$(usex pugixml)
		-DWITH_PULSEAUDIO=$(usex pulseaudio)
		-DWITH_PYTHON_INSTALL_NUMPY=no
		-DWITH_PYTHON_INSTALL_ZSTANDARD=no
		-DWITH_PYTHON_INSTALL=no
		-DWITH_RENDERDOC=$(usex renderdoc)
		-DWITH_SDL=$(usex sdl)
		-DWITH_STATIC_LIBS=no
		-DWITH_STRICT_BUILD_OPTIONS=yes
		-DWITH_SYSTEM_EIGEN3=yes
		-DWITH_SYSTEM_FREETYPE=yes
		-DWITH_SYSTEM_LZO=yes
		-DWITH_TBB=$(usex tbb)
		-DWITH_USD=no # TODO: Package USD
		-DWITH_VULKAN_BACKEND=$(usex vulkan)
		-DWITH_XR_OPENXR=no
		-DWITH_PYTHON=on
		-DWITH_PYTHON_SECURITY=on
		-DWITH_PYTHON_MODULE=on
	)

	if has_version ">=dev-python/numpy-2"; then
		mycmakeargs+=(
			-DPYTHON_NUMPY_INCLUDE_DIRS="$(python_get_sitedir)/numpy/_core/include"
			-DPYTHON_NUMPY_PATH="$(python_get_sitedir)/numpy/_core/include"
		)
	fi

	if use optix; then
		mycmakeargs+=(
			-DCYCLES_RUNTIME_OPTIX_ROOT_DIR="${EPREFIX}"/opt/optix
			-DOPTIX_ROOT_DIR="${EPREFIX}"/opt/optix
		)
	fi

	if use llvm; then
		mycmakeargs+=(
			-DLLVM_LIBRARY="$(llvm-config --libdir)"
		)
	fi

	# This is currently needed on arm64 to get the NEON SIMD wrapper to compile the code successfully
	use arm64 && append-flags -flax-vector-conversions

	append-cflags $(usex debug '-DDEBUG' '-DNDEBUG')
	append-cppflags $(usex debug '-DDEBUG' '-DNDEBUG')

	if tc-is-gcc; then
		# These options only exist when GCC is detected.
		# We disable these to respect the user's choice of linker.
		mycmakeargs+=(
			-DWITH_LINKER_GOLD=no
			-DWITH_LINKER_LLD=no
		)
	fi

	# Ease compiling with required gcc similar to cuda_sanitize but for cmake
	use cuda && use cycles-bin-kernels && mycmakeargs+=( -DCUDA_HOST_COMPILER="$(cuda_gccdir)" )

	cmake_src_configure
}

src_install() {
	cmake_src_install

	python_optimize "${D}$(python_get_sitedir)"
}

pkg_postinst() {
	if ! use python_single_target_python3_13; then
		ewarn
		ewarn "You are building Blender with a newer python version than"
		ewarn "supported by this version upstream."
		ewarn "If you experience breakages with e.g. plugins, please switch to"
		ewarn "python_single_target_python3_13 instead."
		ewarn "Bug: https://bugs.gentoo.org/737388"
		ewarn
	fi
}
