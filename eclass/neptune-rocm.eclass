# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: neptune-rocm.eclass
# @SUPPORTED_EAPIS: 8
# @BLURB: Eclass for normative AMDGPU target selection
# @PROVIDES: rocm
# @MAINTAINER:
# Ada <ada@chronovore.dev>
# @AUTHOR:
# Ada <ada@chronovore.dev>

# @ECLASS_VARIABLE: NEPTUNE_ROCM_SKIP_GLOBALS
# @DESCRIPTION:
# Controls whether _rocm_set_globals() is executed.

# @ECLASS_VARIABLE: NEPTUNE_ROCM_MIN_VERSION
# @REQUIRED
# @PRE_INHERIT
# @DESCRIPTION:
# The minimum ROCm version, falls back to 5.7

# @ECLASS_VARIABLE: NEPTUNE_ROCM_MAX_VERSION
# @REQUIRED
# @PRE_INHERIT
# @DESCRIPTION:
# The maximum ROCm version, falls back to 9999

if [[ -z ${_NEPTUNE_ROCM_ECLASS} ]]; then
_NEPTUNE_ROCM_ECLASS=1

ROCM_SKIP_GLOBALS=1
NEPTUNE_ROCM_MIN_VERSION=${NEPTUNE_ROCM_MIN_VERSION:=5.7}
NEPTUNE_ROCM_MAX_VERSION=${NEPTUNE_ROCM_MAX_VERSION:=9999}
inherit rocm
unset ROCM_SKIP_GLOBALS

_neptune_rocm_set_globals() {
	[[ -n ${NEPTUNE_ROCM_SKIP_GLOBALS} ]] && return

	# https://github.com/ROCm/ROCm/blob/develop/docs/compatibility/compatibility-matrix.rst
	# cross reference with https://llvm.org/docs/AMDGPUUsage.html for RDNA level
	local amdgpu_targets=()
	if ver_test "5.7.1" -ge "${NEPTUNE_ROCM_MIN_VERSION}" && ver_test "5.7.1" -le "${NEPTUNE_ROCM_MAX_VERSION}" ; then
		amdgpu_targets+=(
			gfx801 gfx802 gfx803 # Volcanic Islands
			gfx900 gfx902 gfx904 gfx906 gfx908 gfx90a gfx90c gfx940 gfx941 gfx942 # Vega
			gfx1010 gfx1011 gfx1012 # RDNA 1
			gfx1030 gfx1031 gfx1032 gfx1033 gfx1034 gfx1035 gfx1036 # RDNA 2
		)
		# gfx805, gfx810 is unused
		# gfx909, gfx950 is unused
		# gfx1013 is unused
	fi
	if ver_test "6.0.0" -ge "${NEPTUNE_ROCM_MIN_VERSION}" && ver_test "6.0.0" -le "${NEPTUNE_ROCM_MAX_VERSION}" ; then
		amdgpu_targets+=(
			gfx1100 gfx1101 gfx1102 gfx1103 # RDNA 3
		)
	fi
	# RDNA 3.5 and RDNA 4 are not supported yet
	# if ver_test "6.4.0" -ge "${NEPTUNE_ROCM_MIN_VERSION}" && ver_test "6.4.0" -le "${NEPTUNE_ROCM_MAX_VERSION}" ; then
	# 	amdgpu_targets+=(
	#		gfx1150 gfx1151 gfx1152 gfx1153 # RDNA 3.5
	# 		gfx1200 gfx1201 # RDNA 4
	# 	)
	# fi

	local iuse_flags=(
		"${amdgpu_targets[@]/#/amdgpu_targets_}"
	)
	IUSE="${iuse_flags[*]}"
}
_neptune_rocm_set_globals
unset -f _neptune_rocm_set_globals

fi
