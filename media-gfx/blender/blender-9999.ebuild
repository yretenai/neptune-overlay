# Copyright 2023-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# TODO
# - Package Hydra
# 	https://github.com/Ray-Tracing-Systems/HydraCore
# 	https://github.com/Ray-Tracing-Systems/HydraAPI
# - Package USD
# 	https://github.com/PixarAnimationStudios/OpenUSD
# - Package Draco
# 	https://github.com/google/draco

EAPI=8

PYTHON_COMPAT=( python3_13 )
LLVM_COMPAT=( 18 )
EGIT_LFS="yes"
ROCM_VERSION="6.1.2"

inherit rocm git-r3 check-reqs cmake cuda flag-o-matic pax-utils python-single-r1 toolchain-funcs xdg-utils llvm-r1

DESCRIPTION="3D Creation/Animation/Publishing System"
HOMEPAGE="https://www.blender.org"
LICENSE="GPL-3+ cycles? ( Apache-2.0 )"
SLOT="$(ver_cut 1-2)"

EGIT_REPO_URI="https://projects.blender.org/blender/blender.git"

if [[ ${PV} != *9999* ]]; then
	if [[ ${PV} != *_beta* ]]; then
		EGIT_COMMIT="v${PV}"
	else
		EGIT_BRANCH="blender-v$(ver_cut 1-2)-release"
	fi
	KEYWORDS="~amd64"
fi

IUSE="+bullet +fluid +openexr +tbb vulkan experimental llvm
	alembic collada +color-management cuda +cycles +cycles-bin-kernels
	debug doc +embree +ffmpeg +fftw +gmp hip hiprt jack jemalloc jpeg2k
	man +nanovdb ndof nls openal +oidn +openmp +openpgl +opensubdiv
	+openvdb optix osl +pdf +potrace +pugixml pulseaudio sdl
	+sndfile +tiff valgrind +wayland +webp X +otf renderdoc"
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
	>=media-libs/openimageio-2.4.6.0:=
	sys-libs/zlib:=
	virtual/glu
	virtual/libintl
	virtual/opengl
	alembic? ( >=media-gfx/alembic-1.8.3-r2[boost(+),hdf(+)] )
	collada? ( >=media-libs/opencollada-1.6.68 )
	color-management? ( media-libs/opencolorio:= )
	cuda? ( dev-util/nvidia-cuda-toolkit:= )
	embree? ( >=media-libs/embree-3.13.0:=[raymask] )
	ffmpeg? ( media-video/ffmpeg:=[x264,mp3,encode,theora,jpeg2k?,vpx,vorbis,opus,xvid] )
	fftw? ( sci-libs/fftw:3.0= )
	gmp? ( dev-libs/gmp )
	hip? (
		$(llvm_gen_dep "
			>=dev-util/hip-${ROCM_VERSION}:=[llvm_slot_\${LLVM_SLOT}]
		")
	)
	jack? ( virtual/jack )
	jemalloc? ( dev-libs/jemalloc:= )
	jpeg2k? ( media-libs/openjpeg:2= )
	ndof? (
		app-misc/spacenavd
		dev-libs/libspnav
	)
	nls? ( virtual/libiconv )
	openal? ( media-libs/openal )
	oidn? (
		$(llvm_gen_dep '
			>=media-libs/oidn-2.3.0:=[llvm_slot_${LLVM_SLOT}]
		')
	)
	openexr? (
		>=dev-libs/imath-3.1.4-r2:=
		>=media-libs/openexr-3:0=
	)
	openpgl? ( media-libs/openpgl:= )
	opensubdiv? ( >=media-libs/opensubdiv-3.6.0-r2[opengl,cuda?,openmp?,tbb?] )
	openvdb? (
		>=media-gfx/openvdb-10.1.0:=[nanovdb?]
		dev-libs/c-blosc:=
	)
	optix? ( <dev-libs/optix-7.5.0 )
	osl? (
		$(llvm_gen_dep '
			>=media-libs/osl-1.13.10.0:=[llvm_slot_${LLVM_SLOT}]
			>=media-libs/mesa-24.1.2[llvm_slot_${LLVM_SLOT}]
		')
	)
	pdf? ( media-libs/libharu )
	potrace? ( media-gfx/potrace )
	pugixml? ( dev-libs/pugixml )
	pulseaudio? ( media-libs/libpulse )
	sdl? ( media-libs/libsdl2[sound,joystick] )
	sndfile? ( media-libs/libsndfile )
	tbb? ( dev-cpp/tbb:= )
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
	llvm? (
		$(llvm_gen_dep '
			sys-devel/clang:${LLVM_SLOT}
			sys-devel/llvm:${LLVM_SLOT}
		')
	)
	hiprt? (
		$(llvm_gen_dep '
			=dev-libs/hiprt-2.3:=[llvm_slot_${LLVM_SLOT}]
		')
	)
"

DEPEND="${RDEPEND}
	dev-cpp/eigen:=
"

BDEPEND="
	virtual/pkgconfig
	doc? (
		app-text/doxygen[dot]
		dev-python/sphinx[latex]
		dev-texlive/texlive-bibtexextra
		dev-texlive/texlive-fontsextra
		dev-texlive/texlive-fontutils
		dev-texlive/texlive-latex
		dev-texlive/texlive-latexextra
	)
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
			sys-devel/clang:${LLVM_SLOT}
			sys-devel/llvm:${LLVM_SLOT}
		')
	)
"

PATCHES=(
	"${FILESDIR}/${PN}-9999-openvdb-11.patch"
	"${FILESDIR}/${PN}-9999-clang.patch"
	"${FILESDIR}/${PN}-9999-hiprt-parallel.patch"
	"${FILESDIR}/${PN}-9999-hipcc-path.patch"
	"${FILESDIR}/${PN}-9999-cycles-runtime-path.patch"
)

blender_check_requirements() {
	[[ ${MERGE_TYPE} != binary ]] && use openmp && tc-check-openmp

	REQ_TOT=2

	use debug && ((REQ_TOT += 1))
	[[ ${MERGE_TYPE} != binary ]] && has splitdebug $FEATURES && ((REQ_TOT += 9))
	use doc && ((REQ_TOT += 2))

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

src_prepare() {
	cmake_src_prepare

	blender_get_version

	# Disable MS Windows help generation. The variable doesn't do what it
	# it sounds like.
	sed -e "s|GENERATE_HTMLHELP      = YES|GENERATE_HTMLHELP      = NO|" \
		-i doc/doxygen/Doxyfile || die

	# Prepare icons and .desktop files for slotting.
	sed \
		-e "s|blender.svg|blender-${BV}.svg|" \
		-e "s|blender-symbolic.svg|blender-${BV}-symbolic.svg|" \
		-e "s|blender.desktop|blender-${BV}.desktop|" \
		-e "s|org.blender.Blender.metainfo.xml|blender-${BV}.metainfo.xml|" \
		-i source/creator/CMakeLists.txt || die

	sed \
		-e "s|Name=Blender|Name=Blender ${BV}|" \
		-e "s|Exec=blender|Exec=blender-${BV}|" \
		-e "s|Icon=blender|Icon=blender-${BV}|" \
		-i release/freedesktop/blender.desktop || die

	mv \
		release/freedesktop/icons/scalable/apps/blender.svg \
		"release/freedesktop/icons/scalable/apps/blender-${BV}.svg" || die
	mv \
		release/freedesktop/icons/symbolic/apps/blender-symbolic.svg \
		"release/freedesktop/icons/symbolic/apps/blender-${BV}-symbolic.svg" || die
	mv release/freedesktop/blender.desktop "release/freedesktop/blender-${BV}.desktop" || die
	mv release/freedesktop/org.blender.Blender.metainfo.xml "release/freedesktop/blender-${BV}.metainfo.xml"
	mv release/freedesktop/org.blender.Blender.appdata.xml "release/freedesktop/blender-${BV}.appdata.xml"

	if use vulkan; then
		sed -e "s/extern_vulkan_memory_allocator/extern_vulkan_memory_allocator\nSPIRV-Tools-opt\nSPIRV-Tools\nSPIRV-Tools-link\nglslang\nSPIRV\nSPVRemapper/" -i source/blender/gpu/CMakeLists.txt || die
	fi
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
		-DHIP_HIPCC_FLAGS="-fcf-protection=none"
		-DHIP_LINKER_EXECUTABLE="$(get_llvm_prefix)/bin/clang++"
		-DPYTHON_INCLUDE_DIR="$(python_get_includedir)"
		-DPYTHON_LIBRARY="$(python_get_library_path)"
		-DPYTHON_VERSION="${EPYTHON/python/}"
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
		-DWITH_CYCLES_DEVICE_ONEAPI=no
		-DWITH_CYCLES_DEVICE_OPTIX=$(usex optix)
		-DWITH_CYCLES_EMBREE=$(usex embree)
		-DWITH_CYCLES_HIP_BINARIES=$(usex hip $(usex cycles-bin-kernels))
		-DCYCLES_HIP_BINARIES_ARCH="$(get_amdgpu_flags)"
		-DWITH_CYCLES_HYDRA_RENDER_DELEGATE=no # TODO: package Hydra
		-DWITH_CYCLES_ONEAPI_BINARIES=no
		-DWITH_CYCLES_OSL=$(usex osl)
		-DWITH_CYCLES_PATH_GUIDING=$(usex openpgl)
		-DWITH_CYCLES_STANDALONE_GUI=no
		-DWITH_CYCLES_STANDALONE=no
		-DWITH_CYCLES=$(usex cycles)
		-DWITH_DOC_MANPAGE=$(usex man)
		-DWITH_DRACO=no # TODO: Package Draco
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
		-DWITH_HEADLESS=$($(use X || use wayland) && echo OFF || echo ON)
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
		-DWITH_MEM_JEMALLOC=$(usex jemalloc)
		-DWITH_MEM_VALGRIND=$(usex valgrind)
		-DWITH_MOD_FLUID=$(usex fluid)
		-DWITH_MOD_OCEANSIM=$(usex fftw)
		-DWITH_NANOVDB=$(usex nanovdb)
		-DWITH_OPENAL=$(usex openal)
		-DWITH_OPENCOLLADA=$(usex collada)
		-DWITH_OPENCOLORIO=$(usex color-management)
		-DWITH_OPENIMAGEDENOISE=$(usex oidn)
		-DWITH_OPENMP=$(usex openmp)
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
	blender_get_version

	# Pax mark blender for hardened support.
	pax-mark m "${BUILD_DIR}"/bin/blender

	cmake_src_install

	if use man; then
		# Slot the man page
		mv "${ED}/usr/share/man/man1/blender.1" "${ED}/usr/share/man/man1/blender-${BV}.1" || die
	fi

	if use doc; then
		# Define custom blender data/script file paths. Otherwise Blender will not be able to find them during doc building.
		# (Because the data is in the image directory and it will default to look in /usr/share)
		export BLENDER_SYSTEM_SCRIPTS=${ED}/usr/share/blender/${BV}/scripts
		export BLENDER_SYSTEM_DATAFILES=${ED}/usr/share/blender/${BV}/datafiles

		# Workaround for binary drivers.
		addwrite /dev/ati
		addwrite /dev/dri
		addwrite /dev/nvidiactl

		einfo "Generating Blender C/C++ API docs ..."
		cd "${CMAKE_USE_DIR}"/doc/doxygen || die
		doxygen -u Doxyfile || die
		doxygen || die "doxygen failed to build API docs."

		cd "${CMAKE_USE_DIR}" || die
		einfo "Generating (BPY) Blender Python API docs ..."
		"${BUILD_DIR}"/bin/blender --background --python doc/python_api/sphinx_doc_gen.py -noaudio || die "sphinx failed."

		cd "${CMAKE_USE_DIR}"/doc/python_api || die
		sphinx-build sphinx-in BPY_API || die "sphinx failed."

		docinto "html/API/python"
		dodoc -r "${CMAKE_USE_DIR}"/doc/python_api/BPY_API/.

		docinto "html/API/blender"
		dodoc -r "${CMAKE_USE_DIR}"/doc/doxygen/html/.
	fi

	# Fix doc installdir
	docinto html
	dodoc "${CMAKE_USE_DIR}"/release/text/readme.html
	rm -r "${ED}"/usr/share/doc/blender || die

	python_optimize "${ED}/usr/share/blender/${BV}/scripts"

	mv "${ED}/usr/bin/blender-thumbnailer" "${ED}/usr/bin/blender-${BV}-thumbnailer" || die
	mv "${ED}/usr/bin/blender" "${ED}/usr/bin/blender-${BV}" || die
}

pkg_postinst() {
	elog
	elog "Blender uses python integration. As such, may have some"
	elog "inherent risks with running unknown python scripts."
	elog
	elog "It is recommended to change your blender temp directory"
	elog "from /tmp to /home/user/tmp or another tmp file under your"
	elog "home directory. This can be done by starting blender, then"
	elog "changing the 'Temporary Files' directory in Blender preferences."
	elog

	if use osl; then
		ewarn
		if use hip; then
			ewarn "OSL is know to cause runtime segfaults if Mesa and/or HIP have been"
			ewarn "linked to an other LLVM version than what OSL is linked to."
		else
			ewarn "OSL is know to cause runtime segfaults if Mesa has been linked to"
			ewarn "an other LLVM version than what OSL is linked to."
		fi
		ewarn "Bug: https://bugs.gentoo.org/880671"
		ewarn
	fi

	if ! use python_single_target_python3_13; then
		ewarn
		ewarn "You are building Blender with a newer python version than"
		ewarn "supported by this version upstream."
		ewarn "If you experience breakages with e.g. plugins, please switch to"
		ewarn "python_single_target_python3_13 instead."
		ewarn "Bug: https://bugs.gentoo.org/737388"
		ewarn
	fi

	xdg_icon_cache_update
	xdg_mimeinfo_database_update
	xdg_desktop_database_update
}

pkg_postrm() {
	xdg_icon_cache_update
	xdg_mimeinfo_database_update
	xdg_desktop_database_update

	ewarn
	ewarn "You may want to remove the following directory."
	ewarn "~/.cache/cycles/"
	ewarn "It may contain extra render kernels not tracked by portage"
	ewarn
}
