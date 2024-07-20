# Copyright 2023-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake git-r3

DESCRIPTION="Port of OpenAI's Whisper model in C/C++ "
HOMEPAGE="https://github.com/ggerganov/whisper.cpp"
EGIT_REPO_URI="https://github.com/ggerganov/whisper.cpp"

if [[ "${PV}" != *9999* ]]; then
	EGIT_COMMIT="v${PV}"
	KEYWORDS="~amd64"
fi

LICENSE="MIT"
SLOT="0"
IUSE="hip hipuma cuda openblas vulkan torch ffmpeg +models sdl test cpu_flags_x86_avx512dq cpu_flags_x86_avx512_vbmi2 cpu_flags_x86_avx512_vnni cpu_flags_x86_avx2 cpu_flags_x86_avx cpu_flags_x86_fma3 cpu_flags_x86_f16c"
RESTRICT="!test? ( test )"

# HIP Disabled because it still links to CUDA???
# I don't want to taint my system with NVidia's nerfarious drivers

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
	ffmpeg? ( media-video/ffmpeg:= )
	media-fonts/roboto
"

RDEPEND="
	${DEPEND}
	vulkan? ( dev-util/vulkan-headers )
	models? ( app-accessibility/whisper-cpp-models )
"

REQUIRED_USE="
	hipuma? ( hip )
"

src_configure() {
	# fix hardcoded model path to the one installed by us
	sed -e "s|models/ggml-base.en.bin|${EPREFIX}/usr/share/whisper/ggml-models/base.en.bin|" \
		-i "examples/bench/bench.cpp" \
		-i "examples/lsp/lsp.cpp" \
		-i "examples/server/server.cpp" \
		-i "examples/talk-llama/talk-llama.cpp" \
		-i "examples/talk/talk.cpp" \
		-i "examples/command/command.cpp" \
		-i "examples/wchess/wchess.cmd/wchess.cmd.cpp" \
		-i "examples/main/main.cpp" \
		-i "examples/stream/stream.cpp" || die "can't fix default model path"
	
	# fix hardcoded macOS specific path
	sed -e "s|/System/Library/Fonts/Supplemental/Courier New Bold.ttf|${EPREFIX}/usr/share/fonts/roboto/Roboto-Bold.ttf|" \
		-i "examples/server/server.cpp" \
		-i "examples/main/main.cpp" || die "can't fix default font path"

	# fix ffmpeg 3.0 requirement
	if use ffmpeg; then
		sed -e "s|av_register_all|// av_register_all|" \
			-i "examples/ffmpeg-transcode.cpp" || die "can't fix ffmpeg" 
	fi

	local mycmakeargs=(
		-DWHISPER_BUILD_EXAMPLES=ON # main is an example
		-DWHISPER_BUILD_SERVER=ON
		-DWHISPER_BUILD_TESTS=$(usex test)
		-DWHISPER_FFMPEG=$(usex ffmpeg)
		-DWHISPER_SDL2=$(usex sdl)
		-DGGML_BLAS=$(usex openblas)
		-DGGML_CUDA=$(usex cuda)
		-DGGML_HIPBLAS=$(usex hip)
		-DGGML_HIP_UMA=$(usex hipuma)
		-DGGML_VULKAN=$(usex vulkan)
		-DGGML_SYCL=OFF # $(usex sycl)
		-DGGML_STATIC=OFF
		-DGGML_LTO=OFF # breaks shared
		-DGGML_AVX512=$(usex cpu_flags_x86_avx512dq)
		-DGGML_AVX512_VBMI=$(usex cpu_flags_x86_avx512_vbmi2)
		-DGGML_AVX512_VNNI=$(usex cpu_flags_x86_avx512_vnni)
		-DGGML_AVX2=$(usex cpu_flags_x86_avx2)
		-DGGML_AVX=$(usex cpu_flags_x86_avx)
		-DGGML_FMA=$(usex cpu_flags_x86_fma3)
		-DGGML_F16C=$(usex cpu_flags_x86_f16c)
	)

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

	cd "${BUILD_DIR}" || die

	dolib.so \
		src/libwhisper.so.1.6.2 \
		ggml/src/libggml.so
	dosym "${EPREFIX}/usr/lib64/libwhisper.so.1.6.2" "usr/lib64/libwhisper.so.1"
	dosym "${EPREFIX}/usr/lib64/libwhisper.so.1" "usr/lib64/libwhisper.so"
	newbin bin/main whisper
	newbin bin/bench whisper-bench
	newbin bin/quantize whisper-quantize
	newbin bin/server whisper-server

	if use sdl; then
		newbin bin/command whisper-command
		newbin bin/lsp whisper-lsp
		newbin bin/stream whsiper-stream
		newbin bin/talk whisper-talk
		newbin bin/talk-llama whisper-talk-llama
		newbin bin/wchess whisper-wchess
	fi

	insinto /usr/share/cmake/whisper
	doins whisper-config.cmake whisper-version.cmake
	insinto /usr/share/pkgconfig
	doins whisper.pc
}

pkg_postinst() {
	elog "The main binary has been installed as \"whisper\""
	elog
	elog "The main binary will look for models installed in"
	elog "   ${EROOT}/usr/share/whisper/ggml-models"
	elog
	if use torch; then
		elog
		elog "Python scripts to convert custom models have been installed in"
		elog "   ${EROOT}/usr/share/doc/${P}/tools"
		elog
	fi
}
