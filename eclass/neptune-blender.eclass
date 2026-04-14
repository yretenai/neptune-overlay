# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: neptune-blender.eclass
# @SUPPORTED_EAPIS: 8
# @BLURB: Eclass to set up branch info
# @MAINTAINER:
# Ada <ada@chronovore.dev>
# @AUTHOR:
# Ada <ada@chronovore.dev>

# @ECLASS_VARIABLE: EGIT_BRANCH
# @OUTPUT_VARIABLE
# @DESCRIPTION:
# blender git branch name

# @ECLASS_VARIABLE: BRANCH_NAME
# @OUTPUT_VARIABLE
# @DESCRIPTION:
# name of a given branch

# @ECLASS_VARIABLE: IS_BRANCH
# @OUTPUT_VARIABLE
# @DESCRIPTION:
# 1 if we are on a blender branch

if [[ -z ${_NEPTUNE_BLENDER_ECLASS} ]]; then
	_NEPTUNE_BLENDER_ECLASS=1

	if [[ ${PV} != 9999 ]]; then
		EGIT_BRANCH="blender-v$(ver_cut 1-2)-release"
		SLOT="$(ver_cut 1-2)/alpha"
	else
		SLOT="alpha"
		# special branches
		if [[ "${PR}" != "r0" ]]; then
			case $PR in
				r100)
					EGIT_BRANCH="npr-prototype"
					BRANCH_NAME="NPR Prototype"
					;;
				r101)
					EGIT_BRANCH="cycles-tx"
					BRANCH_NAME="Texture Cache"
					;;
			esac

			IS_BRANCH=1
			SLOT="${EGIT_BRANCH}"
		fi
	fi
fi
