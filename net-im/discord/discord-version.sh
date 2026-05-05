#!/bin/sh

case "$1" in
	canary|development)
		echo $(curl "https://updates.discord.com/distributions/app/manifests/latest?channel=$1&platform=linux&arch=x64" | jq -r '.full.host_version | join(".")' )
		;;
	ptb)
		echo $(curl -I "https://discord.com/api/download/$1?platform=linux&format=tar.gz" 2>/dev/null | grep location | grep -oP '[.\d]+(?=/)')
		;;
	*)
		echo $(curl -I "https://discord.com/api/download?platform=linux&format=tar.gz" 2>/dev/null | grep location | grep -oP '[.\d]+(?=/)')
		;;
esac

