if [[ -z "$1" ]]; then
	discord_version=$(curl -I "https://discord.com/api/download?platform=linux&format=tar.gz" 2>/dev/null | grep location | grep -oP '\d+(?=/)')
else
	discord_version=$(curl -I "https://discord.com/api/download/$1?platform=linux&format=tar.gz" 2>/dev/null | grep location | grep -oP '\d+(?=/)')
fi

echo $discord_version
