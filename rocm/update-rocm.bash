#!/bin/bash

set -o pipefail

rm rocm.log prepare.log

NEPTUNE_REPO_ROOT="/var/db/repos/neptune-rocm"
GENTOO_REPO_ROOT="/var/db/repos/gentoo"

ROCM_TARGET_VERSION="$1"

COMPAT_MATRIX_URI="https://raw.githubusercontent.com/ROCm/ROCm/refs/tags/rocm-${ROCM_TARGET_VERSION}/docs/compatibility/compatibility-matrix-historical-6.0.csv"

PKGMAP="
	Composable Kernel -> sci-libs/composable-kernel
	MIGraphX ->
	MIOpen -> sci-libs/miopen
	MIVisionX ->
	rocAL ->
	rocDecode ->
	rocPyDecode ->
	RPP -> sci-libs/rpp
	RCCL -> dev-libs/rccl
	half -> dev-libs/half
	hipBLAS -> sci-libs/hipBLAS
	hipBLASLt -> sci-libs/hipBLASLt
	hipFFT -> sci-libs/hipFFT
	hipFORT -> 
	hipRAND -> sci-libs/hipRAND
	hipSOLVER -> sci-libs/hipSOLVER
	hipSPARSE -> sci-libs/hipSPARSE
	hipSPARSELt -> 
	rocALUTION -> 
	rocBLAS -> sci-libs/rocBLAS
	rocFFT -> sci-libs/rocFFT
	rocRAND -> sci-libs/rocRAND
	rocSOLVER -> sci-libs/rocSOLVER
	rocSPARSE -> sci-libs/rocSPARSE
	rocWMMA -> sci-libs/rocWMMA
	Tensile -> dev-util/Tensile
	hipCUB -> sci-libs/hipCUB
	hipTensor ->
	rocPRIM -> sci-libs/rocPRIM
	rocThrust -> sci-libs/rocThrust
	hipother -> dev-libs/hipother
	rocm-core ->
	ROCT-Thunk-Interface -> dev-libs/roct-thunk-interface
	AMD SMI ->
	ROCm Data Center Tool ->
	rocminfo -> dev-util/rocminfo
	ROCm SMI -> dev-util/rocm-smi
	ROCm Validation Suite ->
	Omniperf ->
	Omnitrace ->
	ROCm Bandwidth Test ->
	ROCProfiler -> dev-util/rocprofiler
	ROCProfiler-SDK -> dev-util/rocprofiler-sdk
	ROCTracer -> dev-util/roctracer
	HIPIFY -> dev-util/hipify-clang
	ROCm CMake -> dev-build/rocm-cmake
	ROCdbgapi -> dev-libs/rocdbgapi
	ROCm Debugger ->
	rocprofiler-register -> dev-util/rocprofiler-register
	ROCr Debug Agent ->
	hipCC -> dev-util/hipcc
	AMD CLR ->
	HIP -> dev-util/hip
	ROCR-Runtime -> dev-libs/rocr-runtime
	llvm-project -> dev-libs/rocm-comgr dev-libs/rocm-device-libs
"
DISTINCT_VERSION="dev-libs/half"

find_package_from_compat() {
	COMPAT_KEY="$1"
	echo "${PKGMAP}" | grep -E "^\s*${COMPAT_KEY}\s*->" | cut -d'>' -f2 | xargs
}

process_pkg_actual() {
	TARGET_PKG="$1"
	VERSION="$2"
	PKG="$3"

	NAME="$(echo "${PKG}" | cut -d'/' -f2)"
	if [ ! -f "ebuilds/${NAME}.ebuild" ]; then
		echo "${1} lacks an ebuild (ebuilds/${NAME}.ebuild)"
	 	return
	fi

	TARGET_VER="${ROCM_TARGET_VERSION}"
	if [[ $DISTINCT_VERSION == *"${PKG}"* ]]; then
		TARGET_VER="${VERSION}"
	fi

	if [ -n "$(find "${GENTOO_REPO_ROOT}/${PKG}" -maxdepth 1 -name "${NAME}-${TARGET_VER}*.ebuild" -print -quit)" ]; then
		echo "skipping ${NAME}, exists in ::gentoo"
		return
	fi

	if [ -n "$(find "${NEPTUNE_REPO_ROOT}/${PKG}" -maxdepth 1 -name "${NAME}-${TARGET_VER}*.ebuild" -print -quit)" ]; then
		echo "skipping ${NAME}, exists in ::neptune-rocm"
		return
	fi

	echo "${NAME} -> ${TARGET_VER} ($VERSION)"

	TARGET_EBUILD="${NEPTUNE_REPO_ROOT}/${PKG}/${NAME}-${TARGET_VER}.ebuild"

	cp "ebuilds/${NAME}.ebuild" "${TARGET_EBUILD}"
	if ebuild "${TARGET_EBUILD}" clean manifest; then
		if (ebuild "${TARGET_EBUILD}" prepare | tee -a prepare.log); then
			ebuild "${TARGET_EBUILD}" clean
		else
			echo "!!! ${PKG} failed to unpack !!!" | tee -a rocm.log
		fi
	else
		echo "!!! ${PKG} failed to generate manifest !!!" | tee -a rocm.log
	fi

	pushd "${NEPTUNE_REPO_ROOT}/${PKG}/"
		git add .
		pkgdev commit
	popd
}

process_pkg() {
	TARGET_PKG="$1"
	VERSION="$2"

	PKGS=$(find_package_from_compat "${TARGET_PKG}")

	if [ -z "${PKGS}" ]; then
		return
	fi

	for PKG in ${PKGS}; do
		process_pkg_actual "${TARGET_PKG}" "${VERSION}" "${PKG}"
	done
}


curl --silent --fail ${COMPAT_MATRIX_URI} | while IFS="\n" read -r LINE; do
	# skip headers
	if [[ ${LINE} != *"<"* ]]; then
		continue
	fi
	if [[ ${LINE} = *"Ubuntu"* ]]; then
		continue
	fi
	if [[ ${LINE} = *":reference"* ]]; then
		continue
	fi

	# (:doc:)?`Name\s+\(\w+\)\s+<uri>
	MODULE="$(echo ${LINE} | awk -F'[`,(<]' '{print $2}' | xargs)"
	
	if [ -z "${MODULE}" ]; then
		continue
	fi

	VERSION="$(echo ${LINE} | awk -F'[,]' '{print $3}' | xargs)"
	
	process_pkg "${MODULE}" "${VERSION}"
done
