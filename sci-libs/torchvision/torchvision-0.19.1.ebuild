# Copyright 2020-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{10,11,12} )
DISTUTILS_EXT=1
DISTUTILS_SINGLE_IMPL=1
DISTUTILS_USE_PEP517=setuptools

inherit cuda distutils-r1 multiprocessing git-r3

DESCRIPTION="Datasets, transforms and models to specific to computer vision"
HOMEPAGE="https://github.com/pytorch/vision"

EGIT_REPO_URI="https://github.com/pytorch/vision.git"
if [[ "${PV}" != *9999* ]]; then
	EGIT_COMMIT="v${PV}"
	KEYWORDS="~amd64"
fi

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64"
IUSE="cuda"

# shellcheck disable=SC2016
RDEPEND="$(python_gen_cond_dep '
		dev-python/numpy[${PYTHON_USEDEP}]
		dev-python/typing-extensions[${PYTHON_USEDEP}]
		dev-python/pillow[${PYTHON_USEDEP}]
		dev-python/requests[${PYTHON_USEDEP}]
		dev-python/scipy[${PYTHON_USEDEP}]
	')
	sci-libs/pytorch[${PYTHON_SINGLE_USEDEP}]
	media-video/ffmpeg
	sci-libs/caffe2
	media-libs/libjpeg-turbo
	media-libs/libpng
	dev-qt/qtcore:5
"
DEPEND="${RDEPEND}"

BDEPEND="
	test? ( $(python_gen_cond_dep '
		dev-python/mock[${PYTHON_USEDEP}]
		')
	)
"

distutils_enable_tests pytest

src_prepare() {
	default

	addpredict /proc/self/task/
	addwrite /dev/ati
	addwrite /dev/dri
	addwrite /dev/kfd
	
	MAX_JOBS=$(makeopts_jobs)
	MAKEOPTS=-j1
	export MAKEOPTS MAX_JOBS
	
	if use cuda; then
		FORCE_CUDA=1
		NVCC_FLAGS="$(cuda_gccdir -f | tr -d \")"
		export FORCE_CUDA NVCC_FLAGS
		addwrite /dev/nvidiactl
	fi
}
