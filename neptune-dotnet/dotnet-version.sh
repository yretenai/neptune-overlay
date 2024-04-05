#!/bin/sh
dotnet_version_head=$(curl -I https://aka.ms/dotnet/$2/$1-productVersion.txt 2>/dev/null)
if [[ $dotnet_version_head == *"301 Moved Permanently"* ]]; then
    dotnet_version=$(curl -L https://aka.ms/dotnet/$2/$1-productVersion.txt 2>/dev/null)
    echo $dotnet_version | tr -d '\r\n'
else
    echo $2
fi
