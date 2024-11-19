#!/bin/sh

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
	ROCm SMI ->
	ROCm Validation Suite ->
	Omniperf ->
	Omnitrace ->
	ROCm Bandwidth Test ->
	ROCProfiler ->
	ROCProfiler-SDK ->
	ROCTracer -> dev-util/roctracer
	HIPIFY ->
	ROCm CMake -> dev-build/rocm-cmake
	ROCdbgapi -> dev-libs/rocdbgapi
	ROCm Debugger ->
	rocprofiler-register ->
	ROCr Debug Agent ->
	hipCC -> dev-util/hipcc
	AMD CLR ->
	HIP -> dev-util/hip
	ROCR-Runtime -> dev-libs/rocr-runtime
"
DISTINCT_VERSION="half"

find_package_from_compat() {
	COMPAT_KEY="$1"
	echo "${PKGMAP}" | grep -E "^\s*${COMPAT_KEY}\s*->" | cut -d'>' -f2 | xargs
}

process_pkg() {
	PKG=$(find_package_from_compat "$1")
	VERSION="$2"

	if [ -z "${PKG}" ]; then
		return
	fi

	NAME="$(echo "${PKG}" | cut -d'/' -f2)"
	if [ ! -f "ebuilds/${NAME}.ebuild" ]; then
	 	echo "${1} lacks an ebuild (ebuilds/${NAME}.ebuild)"
	 	return
	fi
	echo "$NAME -> $VERSION"
}

echo "$(curl --silent --fail ${COMPAT_MATRIX_URI})" | while IFS="\n" read -r LINE; do
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

process_pkg "$1"
