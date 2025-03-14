# Copyright 2023-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

LLVM_COMPAT=( {18..20} )
inherit ffmpeg-compat cmake llvm-r1

DESCRIPTION="Port of OpenAI's Whisper model in C/C++ "
HOMEPAGE="https://github.com/ggerganov/whisper.cpp"
LICENSE="MIT"
SLOT="0"

if [[ "${PV}" == *9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/ggerganov/whisper.cpp"
else
	SRC_URI="https://github.com/ggerganov/whisper.cpp/archive/refs/tags/v${PV}.tar.gz -> ${PN}-${PV}.tar.gz"
	S="${WORKDIR}/whisper.cpp-${PV}"
	KEYWORDS="~amd64"
fi

IUSE="hip hipuma cuda openblas vulkan torch ffmpeg +models sdl test cpu_flags_x86_avx512dq cpu_flags_x86_avx512_vbmi2 cpu_flags_x86_avx512_vnni cpu_flags_x86_avx2 cpu_flags_x86_avx cpu_flags_x86_fma3 cpu_flags_x86_f16c"
RESTRICT="!test? ( test )"

DEPEND="
	hip? (
		sci-libs/hipBLAS:=
		dev-util/hip:=
	)
	cuda? ( dev-util/nvidia-cuda-toolkit:= )
	vulkan? ( media-libs/vulkan-loader )
	openblas? ( sci-libs/openblas:= )
	sdl? ( media-libs/libsdl2:= )
	torch? ( sci-libs/pytorch )
	ffmpeg? ( media-video/ffmpeg-compat:6= )
	media-fonts/roboto
"

RDEPEND="
	${DEPEND}
	vulkan? ( dev-util/vulkan-headers )
	models? ( dev-misc/whispercpp-models )
"

BDEPEND="
	app-text/dos2unix
"

REQUIRED_USE="
	hipuma? ( hip )
	?? ( hip cuda vulkan openblas )
"

src_prepare() {
	# :(
	dos2unix "${S}/examples/sycl/CMakeLists.txt"
	cmake_src_prepare
}

src_configure() {
	# fix hardcoded model path to the one installed by us
	sed -e "s|models/ggml-base.en.bin|${EPREFIX}/usr/share/whisper/ggml-models/base.en.bin|" \
		-i "examples/bench/bench.cpp" \
		-i "examples/command/command.cpp" \
		-i "examples/lsp/lsp.cpp" \
		-i "examples/cli/cli.cpp" \
		-i "examples/server/server.cpp" \
		-i "examples/stream/stream.cpp" \
		-i "examples/talk-llama/talk-llama.cpp" \
		-i "examples/wchess/wchess.cmd/wchess.cmd.cpp" || die "can't fix default model path"

	# fix hardcoded macOS specific path
	sed -e "s|/System/Library/Fonts/Supplemental/Courier New Bold.ttf|${EPREFIX}/usr/share/fonts/roboto/Roboto-Bold.ttf|" \
		-i "examples/server/server.cpp" \
		-i "examples/cli/cli.cpp" || die "can't fix default font path"

	local mycmakeargs=(
		-DWHISPER_BUILD_EXAMPLES=ON # cli is an example
		-DWHISPER_CURL=OFF
		-DWHISPER_BUILD_SERVER=ON
		-DWHISPER_BUILD_TESTS=$(usex test)
		-DWHISPER_FFMPEG=$(usex ffmpeg)
		-DWHISPER_SDL2=$(usex sdl)
		-DGGML_BLAS=$(usex openblas)
		-DGGML_CUDA=$(usex cuda)
		-DGGML_HIP=$(usex hip)
		-DGGML_HIP_UMA=$(usex hipuma)
		-DGGML_VULKAN=$(usex vulkan)
		-DGGML_SYCL=OFF # $(usex sycl)
		-DGGML_STATIC=OFF
		-DGGML_LTO=OFF # breaks shared
		-DGGML_CCACHE=OFF
		-DGGML_AVX512=$(usex cpu_flags_x86_avx512dq)
		-DGGML_AVX512_VBMI=$(usex cpu_flags_x86_avx512_vbmi2)
		-DGGML_AVX512_VNNI=$(usex cpu_flags_x86_avx512_vnni)
		-DGGML_AVX2=$(usex cpu_flags_x86_avx2)
		-DGGML_AVX=$(usex cpu_flags_x86_avx)
		-DGGML_FMA=$(usex cpu_flags_x86_fma3)
		-DGGML_F16C=$(usex cpu_flags_x86_f16c)
	)

	if use ffmpeg; then
		ffmpeg_compat_setup 6
		ffmpeg_compat_add_flags
	fi

	if use hip; then
		# it looks in /usr/local otherwise
		mycmakeargs+=(
			-DCMAKE_HIP_COMPILER_ROCM_ROOT=$(hipconfig -p)
		)
	fi

	cmake_src_configure
}

src_install() {
	doheader \
		include/whisper.h \
		ggml/include/ggml-alloc.h \
		ggml/include/ggml-backend.h \
		ggml/include/ggml-blas.h \
		ggml/include/ggml-cuda.h \
		ggml/include/ggml-kompute.h \
		ggml/include/ggml-metal.h \
		ggml/include/ggml-rpc.h \
		ggml/include/ggml-sycl.h \
		ggml/include/ggml-vulkan.h \
		ggml/include/ggml.h

	if use torch; then
		docinto tools
		dodoc models/convert-h5-to-ggml.py
		dodoc models/convert-pt-to-ggml.py
		dodoc models/convert-h5-to-coreml.py
		dodoc models/convert-whisper-to-coreml.py
		dodoc models/convert-whisper-to-openvino.py
		dodoc models/ggml_to_pt.py
	fi

	cmake_src_install
}

pkg_postinst() {
	elog "The main binary has been installed as \"whisper\""
	elog
	elog "The main binary will look for models installed in"
	elog "\t${EROOT}/usr/share/whisper/ggml-models"
	elog
	if use torch; then
		elog
		elog "Python scripts to convert custom models have been installed in"
		elog "\t${EROOT}/usr/share/doc/${P}/tools"
		elog
	fi
}
