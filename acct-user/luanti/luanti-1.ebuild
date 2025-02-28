# Copyright 2020-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit acct-user

DESCRIPTION="A user for the Luanti server"

ACCT_USER_GROUPS=( "luanti" )
ACCT_USER_ID="480"
ACCT_USER_HOME="/var/lib/luanti"

acct-user_add_deps
