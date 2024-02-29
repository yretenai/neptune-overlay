#!/bin/sh
dotnet_version=$(curl -L https://aka.ms/dotnet/$2/$1-productVersion.txt 2>/dev/null)
echo $dotnet_version | tr -d '\r\n'
