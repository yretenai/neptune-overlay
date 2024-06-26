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
IUSE="hip opencl cuda mkl oneapi openblas openblas64 torch +models sdl2 test cpu_flags_x86_avx512dq cpu_flags_x86_avx512_vbmi2 cpu_flags_x86_avx512_vnni cpu_flags_x86_avx2 cpu_flags_x86_avx cpu_flags_x86_fma3 cpu_flags_x86_f16c"
RESTRICT="!test? ( test )"

# HIP Disabled because it still links to CUDA???
# I don't want to taint my system with NVidia's nerfarious drivers

DEPEND="
	hip? (
		sci-libs/hipBLAS:=
		sys-devel/clang
		dev-util/nvidia-cuda-toolkit
	)
	mkl? ( sci-libs/mkl )
	cuda? ( dev-util/nvidia-cuda-toolkit )
	oneapi? ( dev-libs/intel-compute-runtime )
	opencl? ( sci-libs/clblast )
	openblas? ( sci-libs/openblas:= )
	sdl2? ( media-libs/libsdl2 )
	torch? ( sci-libs/pytorch )
"

RDEPEND="
	${DEPEND}
	models? ( app-accessibility/whisper-cpp-models )
"

REQUIRED_USE="
	^^ ( hip cuda openblas opencl )
	openblas64? ( openblas )
"

PATCHES=(
)

src_configure() {
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

	USE_BLAS="NO"
	if use openblas || use cuda || use hip || use opencl; then
		USE_BLAS="YES"
	fi

	local mycmakeargs=(
		-DWHISPER_BUILD_EXAMPLES=ON # main is an example
		-DWHISPER_BUILD_TESTS=$(usex test)
		-DWHISPER_BLAS=${USE_BLAS}
		-DWHISPER_OPENBLAS=$(usex openblas)
		-DWHISPER_OPENBLAS_INTERFACE64=$(usex openblas64)
		-DWHISPER_CUDA=$(usex cuda)
		-DWHISPER_HIPBLAS=$(usex hip)
		-DWHISPER_CLBLAST=$(usex opencl)
		-DWHISPER_MKL=$(usex mkl)
		-DWHISPER_SYCL=$(usex oneapi)
		-DWHISPER_SDL2=$(usex sdl2)
		-DWHISPER_NO_AVX512=$(usex !cpu_flags_x86_avx512dq)
		-DWHISPER_NO_AVX512_VBMI=$(usex !cpu_flags_x86_avx512_vbmi2)
		-DWHISPER_NO_AVX512_VNNI=$(usex !cpu_flags_x86_avx512_vnni)
		-DWHISPER_NO_AVX2=$(usex !cpu_flags_x86_avx2)
		-DWHISPER_NO_AVX=$(usex !cpu_flags_x86_avx)
		-DWHISPER_NO_FMA=$(usex !cpu_flags_x86_fma3)
		-DWHISPER_NO_F16C=$(usex !cpu_flags_x86_f16c)
		-DWHISPER_STATIC=OFF
		-DWHISPER_OPENVINO=OFF # TODO: Add OpenVINO ebuild
	)

	if use hip; then
		CC=hipcc
		CXX=hipcc
	fi

	cmake_src_configure
}

src_install() {
	doheader whisper.h

	if use torch; then
		docinto tools
		dodoc models/convert-h5-to-ggml.py
		dodoc models/convert-pt-to-ggml.py
	fi

	cd "${BUILD_DIR}" || die

	dolib.so libwhisper.so
	newbin bin/main whisper
	newbin bin/bench whisper-bench
	newbin bin/quantize whisper-quantize
	newbni bin/server whisper-server

	if use sdl2; then
		newbin bin/command whisper-command
		newbin bin/lsp whisper-lsp
		newbin bin/stream whsiper-stream
		newbin bin/talk whisper-talk
		newbin bin/talk-llama whisper-talk-llama
		newbin bin/wchess whisper-wchess
	fi
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
