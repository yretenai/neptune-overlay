# Copyright 2020-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit acct-user

DESCRIPTION="A user for the Polaris server"

ACCT_USER_GROUPS=( "polaris" )
ACCT_USER_ID="780"
ACCT_USER_HOME="/var/lib/polaris"

acct-user_add_deps
