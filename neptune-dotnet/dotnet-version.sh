#!/bin/sh
dotnet_version=$(curl -L https://dotnetcli.azureedge.net/dotnet/$1/$2/latest.version 2>/dev/null)
echo $dotnet_version | tr -d '\r\n'
