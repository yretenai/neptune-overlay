# Copyright 2023-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: neptune-dotnet.eclass
# @SUPPORTED_EAPIS: 8
# @PROVIDES: dotnet-pkg-base dotnet-pkg nuget
# @BLURB: Eclass for dotnet build processes using dotnet-pkg
# @MAINTAINER:
# Ada <ada@chronovore.dev>
# @AUTHOR:
# Ada <ada@chronovore.dev>

# @ECLASS_VARIABLE: DOTNET_PKG_RUNTIME
# @DEFAULT_UNSET
# @OUTPUT_VARIABLE
# @DESCRIPTION:
# Sets the runtime used to build a package.
#
# This variable is set automatically by the "neptune-dotnet-base_setup" function.

# @ECLASS_VARIABLE: DOTNET_PKG_EXECUTABLE
# @DEFAULT_UNSET
# @OUTPUT_VARIABLE
# @DESCRIPTION:
# Sets path of a "dotnet" executable.
#
# This variable is set automatically by the "neptune-dotnet-base_setup" function.

# @ECLASS_VARIABLE: DOTNET_PKG_CONFIGURATION
# @DEFAULT_UNSET
# @OUTPUT_VARIABLE
# @DESCRIPTION:
# Configuration value passed to "dotnet" in the compile phase.
# Is either Debug or Release, depending on the "debug" USE flag.
#
# This variable is set automatically by the "neptune-dotnet-base_setup" function.

# @ECLASS_VARIABLE: DOTNET_PKG_OUTPUT
# @DEFAULT_UNSET
# @OUTPUT_VARIABLE
# @DESCRIPTION:
# Path of the output directory, where the package artifacts are placed during
# the building of packages with "dotnet-pkg-base_build" function.
#
# This variable is set automatically by the "neptune-dotnet-base_setup" function.

# @ECLASS_VARIABLE: DOTNET_PKG_RDEPS
# @OUTPUT_VARIABLE
# @DESCRIPTION:
# Populated with important dependencies on .NET ecosystem packages for running
# .NET packages.
#
# "DOTNET_PKG_RDEPS" should appear (or conditionally appear) in "RDEPEND".

# @ECLASS_VARIABLE: DOTNET_PKG_BDEPS
# @OUTPUT_VARIABLE
# @DESCRIPTION:
# Populated with important dependencies on .NET ecosystem packages for building
# .NET packages.
#
# "DOTNET_PKG_BDEPS" should appear (or conditionally appear) in "BDEPEND".

# @ECLASS_VARIABLE: DOTNET_NEPTUNE_OPTIONAL
# @PRE_INHERIT
# @OUTPUT_VARIABLE
# @DESCRIPTION:
# When set to 1, will not do anything by default.

# @ECLASS_VARIABLE: DOTNET_NEPTUNE_PROJECT_ROOT
# @PRE_INHERIT
# @DEFAULT_UNSET
# @DESCRIPTION:
# The root path of the dotnet solution

# @ECLASS_VARIABLE: DOTNET_NEPTUNE_SOLUTIONS
# @PRE_INHERIT
# @DEFAULT_UNSET
# @DESCRIPTION:
# The list of solutions to compile

# @ECLASS_VARIABLE: DOTNET_NEPTUNE_TARGETS
# @PRE_INHERIT
# @DEFAULT_UNSET
# @DESCRIPTION:
# The SDKs this project targets

# @ECLASS_VARIABLE: DOTNET_NEPTUNE_NUGET_LEVELS
# @PRE_INHERIT
# @DEFAULT_UNSET
# @DESCRIPTION:
# The Runtime levels this targets, leave unspecified to default to sdk level

# @ECLASS_VARIABLE: DOTNET_NEPTUNE_ASPNETCORE
# @PRE_INHERIT
# @DEFAULT_UNSET
# @DESCRIPTION:
# Target aspnetcore instead of the regular runtime

if [[ -z ${_NEPTUNE_DOTNET_ECLASS} ]]; then
_NEPTUNE_DOTNET_ECLASS=1

DOTNET_PKG_EXECUTABLE="${EPREFIX}/opt/neptune-dotnet/dotnet"
DOTNET_ROOT="${EPREFIX}/opt/neptune-dotnet"
inherit dotnet-pkg-base nuget

# nasty, nasty override for deps.
if [[ -n "${DOTNET_NEPTUNE_TARGETS}" ]]; then
	DOTNET_PKG_RDEPS="
		dev-dotnet/csharp-gentoodotnetinfo
	"
	DOTNET_PKG_BDEPS=""
	for DOTNET_NEPTUNE_TARGET in "${DOTNET_NEPTUNE_TARGETS[@]}"; do
		if [[ "${DOTNET_NEPTUNE_ASPNETCORE:-1}" == 0 ]]; then
			DOTNET_PKG_RDEPS+="
				virtual/neptune-dotnet:${DOTNET_NEPTUNE_TARGET}
			"
			DOTNET_PKG_BDEPS+="
				neptune-dotnet/dotnet-runtime-nugets:${DOTNET_NEPTUNE_TARGET}
			"
		else
			DOTNET_PKG_RDEPS+="
				virtual/neptune-dotnet:${DOTNET_NEPTUNE_TARGET}[asp]
			"
			DOTNET_PKG_BDEPS+="
				neptune-dotnet/dotnet-runtime-nugets:${DOTNET_NEPTUNE_TARGET}
				neptune-dotnet/dotnet-aspnetcore-nugets:${DOTNET_NEPTUNE_TARGET}
			"
		fi

		DOTNET_PKG_BDEPS+="
			virtual/neptune-dotnet:${DOTNET_NEPTUNE_TARGET}[sdk]
		"
	done
	for DOTNET_NEPTUNE_NUGET_LEVEL in "${DOTNET_NEPTUNE_NUGET_LEVELS[@]}"; do
		if [[ "${DOTNET_NEPTUNE_ASPNETCORE:-1}" == 1 ]]; then
			DOTNET_PKG_BDEPS+="
				neptune-dotnet/dotnet-aspnetcore-nugets:${DOTNET_NEPTUNE_NUGET_LEVEL}
			"
		fi
		DOTNET_PKG_BDEPS+="
			neptune-dotnet/dotnet-runtime-nugets:${DOTNET_NEPTUNE_NUGET_LEVEL}
		"
	done
else
	die "Need to set DOTNET_NEPTUNE_TARGETS"
fi

inherit dotnet-pkg

# @FUNCTION: neptune-dotnet_dolauncher
# @USAGE: <executable-path> [filename]
# @DESCRIPTION:
# Make a wrapper script to launch an executable built from a .NET package.
#
# If no file name is given, the `basename` of the executable is used.
#
# Parameters:
# ${1} - path of the executable to launch,
# ${2} - filename of launcher to create (optional).
#
# Example:
# @CODE
# dotnet-pkg-base_install
# neptune-dotnet_dolauncher /usr/share/${P}/${PN^}
# @CODE
#
# The path is prepended by "EPREFIX".
neptune-dotnet_dolauncher() {
	debug-print-function ${FUNCNAME} "$@"

	local executable_path executable_name

	if [[ -n "${1}" ]] ; then
		local executable_path="${1}"
		shift
	else
		die "${FUNCNAME[0]}: No executable path given."
	fi

	if [[ ${#} -eq 0 ]] ; then
		executable_name="$(basename "${executable_path}")"
	else
		executable_name="${1}"
		shift
	fi

	local executable_target="${T}/${executable_name}"

	cat <<-EOF > "${executable_target}" || die
	#!/bin/sh

	# Launcher script for ${executable_path} (${executable_name}),
	# created from package "${CATEGORY}/${P}",

	DOTNET_ROOT="${EPREFIX}/opt/neptune-dotnet"
	export DOTNET_ROOT

	$(for var in "${_DOTNET_PKG_LAUNCHERVARS[@]}" ; do
		echo "${var}"
		echo "export ${var%%=*}"
	done)

	exec "${EPREFIX}${executable_path}" "\${@}"
	EOF

	exeinto "${_DOTNET_PKG_LAUNCHERDEST}"
	doexe "${executable_target}"
}

# @FUNCTION: neptune-dotnet_restore
# @USAGE: [args] ...
# @DESCRIPTION:
# Restore the package using "dotnet restore".
# Restore is performed in current directory unless a different directory is
# passed via "args".
#
# Additionally any number of "args" maybe be given, they are appended to
# the "dotnet" command invocation.
neptune-dotnet_restore() {
	debug-print-function ${FUNCNAME} "$@"

	local -a restore_args=(
		--runtime "${DOTNET_PKG_RUNTIME}"
		--verbosity "${DOTNET_VERBOSITY}"
		-maxCpuCount:$(makeopts_jobs)
		"${@}"
	)

	edotnet restore "${restore_args[@]}"
}

# @FUNCTION: neptune-dotnet_foreach-solution
# @USAGE: <args> ...
# @DESCRIPTION:
# Run a specified command for each solution listed inside the "DOTNET_PKG_PROJECTS"
# variable.
#
# Used by "dotnet-pkg_src_configure" and "dotnet-pkg_src_compile".
neptune-dotnet_foreach-solution() {
	debug-print-function ${FUNCNAME} "$@"

	DOTNET_LOCAL_PATH="${S}/${DOTNET_NEPTUNE_PROJECT_ROOT}"
	cd "${DOTNET_LOCAL_PATH}" || die

	if [[ -z "${DOTNET_NEPTUNE_SOLUTIONS}" ]]; then
		dotnet-pkg-base_foreach-solution "$(pwd)" "$@"
	else
		local dotnet_solution
		for dotnet_solution in "${DOTNET_NEPTUNE_SOLUTIONS[@]}" ; do
			ebegin "Running \"${*}\" for solution: \"${dotnet_solution##*/}\""
			"${@}" "${dotnet_solution}"
			eend $? "${FUNCNAME[0]}: failed for solution: \"${dotnet_solution}\"" || die
		done
	fi
}

# @FUNCTION: neptune-dotnet_src_unpack
# @DESCRIPTION:
# Default "src_unpack" for the "neptune-dotnet" eclass.
# Restores nuget packages.
neptune-dotnet_src_unpack() {
	debug-print-function ${FUNCNAME} "$@"

	addpredict "${EPREFIX}/opt/neptune-dotnet/metadata/"
	if has live "${PROPERTIES}"; then
		DOTNET_LOCAL_PATH="${S}/${DOTNET_NEPTUNE_PROJECT_ROOT}"
		cd "${DOTNET_LOCAL_PATH}" || die
		echo ${DOTNET_LOCAL_PATH}

		dotnet-pkg-base_info

		dotnet-pkg_foreach-project \
			neptune-dotnet_restore "${DOTNET_PKG_RESTORE_EXTRA_ARGS[@]}"

		neptune-dotnet_foreach-solution \
			neptune-dotnet_restore "${DOTNET_PKG_RESTORE_EXTRA_ARGS[@]}"
	else
		nuget_link-system-nugets
		nuget_link-nuget-archives
	fi

	if [[ "${DOTNET_NEPTUNE_OPTIONAL:-0}" == 0 ]]; then
		nuget_unpack-non-nuget-archives
	fi
}

# @FUNCTION: neptune-dotnet_src_configure
# @DESCRIPTION:
# Default "src_configure" for the "neptune-dotnet" eclass.
# Configure the package.
neptune-dotnet_src_configure() {
	debug-print-function ${FUNCNAME} "$@"

	if ! has live "${PROPERTIES}"; then
		DOTNET_LOCAL_PATH="${S}/${DOTNET_NEPTUNE_PROJECT_ROOT}"
		cd "${DOTNET_LOCAL_PATH}" || die
		dotnet-pkg_src_configure
	fi
}

# @FUNCTION: neptune-dotnet_pkg_setup
# @DESCRIPTION:
# Sets up "DOTNET_PKG_EXECUTABLE" variable for later use in "edotnet".
# Also sets up "DOTNET_PKG_CONFIGURATION" and "DOTNET_PKG_OUTPUT"
# for "neptune-dotnet_src_configure" and "dotnet-pkg_src_compile".
neptune-dotnet_pkg_setup() {
	debug-print-function ${FUNCNAME} "$@"

	export DOTNET_PKG_EXECUTABLE="${EPREFIX}/opt/neptune-dotnet/dotnet"
	export DOTNET_ROOT="${EPREFIX}/opt/neptune-dotnet"
	export PATH="${DOTNET_ROOT}:${PATH}"
	export DOTNET_PKG_RUNTIME="$(dotnet-pkg-base_get-runtime)"
	export DOTNET_PKG_CONFIGURATION="$(dotnet-pkg-base_get-configuration)"
	export DOTNET_PKG_OUTPUT="$(dotnet-pkg-base_get-output "${P}")"
}

# @FUNCTION: neptune-dotnet_src_prepare
# @DESCRIPTION:
# Sets dotnet up to properly locate and restore nugets
neptune-dotnet_src_prepare() {
	debug-print-function ${FUNCNAME} "$@"

	DOTNET_LOCAL_PATH="${S}/${DOTNET_NEPTUNE_PROJECT_ROOT}"

	dotnet-pkg-base_remove-global-json
	dotnet-pkg-base_foreach-solution "${DOTNET_LOCAL_PATH}" dotnet-pkg_remove-bad

	if ! has live "${PROPERTIES}"; then
		find "${DOTNET_LOCAL_PATH}" -maxdepth 1 -iname "nuget.config" -delete ||
			die "${FUNCNAME[0]}: failed to remove unwanted \"NuGet.config\" config files"
		nuget_writeconfig "${DOTNET_LOCAL_PATH}/"
	fi

	if [[ "${DOTNET_NEPTUNE_OPTIONAL:-0}" == 0 ]]; then
		default
	fi
}

if [[ "${DOTNET_NEPTUNE_OPTIONAL:-0}" == 0 ]]; then
	EXPORT_FUNCTIONS pkg_setup src_prepare src_configure
fi

fi
