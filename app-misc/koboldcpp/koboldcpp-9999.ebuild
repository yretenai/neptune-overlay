# Copyright 2023-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{11..13} )
LLVM_COMPAT=( 18 )
ROCM_VERSION="6.1.1"

inherit cuda rocm git-r3 python-single-r1 llvm-r1

DESCRIPTION="A simple one-file way to run various GGML models with KoboldAI's UI"
HOMEPAGE="https://github.com/YellowRoseCx/koboldcpp-rocm"

EGIT_REPO_URI="https://github.com/YellowRoseCx/koboldcpp-rocm.git"

if [[ ${PV} != *9999* ]]; then
	if [[ "$(ver_cut 3)" != "0" ]]; then
		EGIT_COMMIT="v$(ver_cut 1-3).yr$(ver_cut 4)-ROCm"
	else
		EGIT_COMMIT="v$(ver_cut 1-2).yr$(ver_cut 4)-ROCm"
	fi
	KEYWORDS="~amd64"
fi

LICENSE="AGPL-3"
SLOT="0"
IUSE="openblas clblast cuda hip vulkan tools"
RESTRICT="test"

REQUIRED_USE="
	${PYTHON_REQUIRED_USE}
	^^ ( hip cuda )
"

RDEPEND="
	${PYTHON_DEPS}
	$(python_gen_cond_dep '
		>=dev-python/numpy-1.24.4[${PYTHON_USEDEP}]
		>=dev-python/gguf-0.1.0[${PYTHON_USEDEP}]
		>=dev-python/customtkinter-5.1.0[${PYTHON_USEDEP}]
		>=dev-python/packaging-23.0[${PYTHON_USEDEP}]
		>=dev-python/protobuf-python-4.21.0[${PYTHON_USEDEP}]
		>=dev-python/urllib3-2.0.0[${PYTHON_USEDEP}]
		>=dev-python/psutil-5.9.4[${PYTHON_USEDEP}]
		>=sci-libs/transformers-4.34.0[${PYTHON_SINGLE_USEDEP}]
		>=sci-libs/sentencepiece-0.1.98[python,${PYTHON_USEDEP}]
	')
	hip? (
		>=sci-libs/hipBLAS-6.1.1:=
		$(llvm_gen_dep '
			>=dev-util/hip-6.1.1:=[llvm_slot_${LLVM_SLOT}]
		')
	)
	cuda? ( dev-util/nvidia-cuda-toolkit:= )
	clblast? ( sci-libs/clblast:=[cuda?] )
	openblas? ( sci-libs/openblas:= )
	vulkan? (
		dev-util/vulkan-headers
		media-libs/vulkan-loader
	)
"

DEPEND="${RDEPEND}
	dev-cpp/eigen:=
"

BDEPEND="
	vulkan? (
		dev-util/vulkan-headers
	)
"

PATCHES="
    ${FILESDIR}/makefile.patch
    ${FILESDIR}/examples.patch
    ${FILESDIR}/gguf.patch
"

src_prepare() {
	default

	if use cuda; then
		cuda_src_prepare
	fi
}

pkg_setup() {
	python-single-r1_pkg_setup
	llvm-r1_pkg_setup
}

src_compile() {
	if use cuda; then
		addwrite /dev/nvidiactl
		MAKEOPTS+=" LLAMA_CUBLAS=1"
	fi
	if use hip; then
		addwrite /dev/kfd
		addwrite /dev/dri
		MAKEOPTS+=" LLAMA_HIPBLAS=1"
	fi
	if use openblas; then
		MAKEOPTS+=" LLAMA_OPENBLAS=1"
	fi
	if use clblast; then
		MAKEOPTS+=" LLAMA_CLBLAST=1"
	fi
	if use vulkan; then
		MAKEOPTS+=" LLAMA_VULKAN=1"
	fi

	default

	if use tools; then
		emake tools
	fi
}

src_install() {
	cp "${FILESDIR}/koboldcpp" koboldcpp
	sed -e "s|EPYTHON|${EPYTHON}|" -i koboldcpp
	sed -e "s|EPREFIX|${EPREFIX}|" -i koboldcpp
	dobin koboldcpp

	insinto /opt/koboldcpp
	exeinto /opt/koboldcpp
	sed -e "s|/usr/bin/env python3|/usr/bin/env ${EPYTHON}|" \
		-i koboldcpp.py \
		-i convert_hf_to_gguf.py \
		-i convert_hf_to_gguf_update.py \
		-i convert_llama_ggml_to_gguf.py \
		-i convert_lora_to_gguf.py

	doins -r \
		kcpp_adapters \
		niko.ico \
		nikogreen.ico \
		kcpp_docs.embd \
		kcpp_sdui.embd \
		klite.embd \
		rwkv_vocab.embd \
		rwkv_world_vocab.embd \
		taesd.embd \
		taesd_xl.embd

	doexe koboldcpp.py \
		koboldcpp_default.so

	if use cuda; then
		doexe koboldcpp_cublas.so
	fi
	if use hip; then
		doexe koboldcpp_hipblas.so
	fi
	if use openblas; then
		doexe koboldcpp_openblas.so
	fi
	if use clblast; then
		doexe koboldcpp_clblast.so
	fi
	if use vulkan; then
		doexe koboldcpp_vulkan.so
	fi

	if use tools; then
		exeinto /opt/koboldcpp/tools
		doexe convert_hf_to_gguf.py \
			convert_hf_to_gguf_update.py \
			convert_llama_ggml_to_gguf.py \
			convert_lora_to_gguf.py \
			export_lora \
			gguf-split \
			quantize_clip \
			quantize_gguf \
			quantize_gpt2 \
			quantize_gptj \
			quantize_mpt \
			quantize_neox \
			sdmain \
			whispermain
	fi
}
