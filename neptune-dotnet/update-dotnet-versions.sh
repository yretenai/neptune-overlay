#!/bin/zsh
ADADOTNET_ROOT='/var/db/repos/neptune/neptune-dotnet'

DOTNET_6_0_VERSION=$(./dotnet-version.sh runtime "6.0")
DOTNET_7_0_VERSION=$(./dotnet-version.sh runtime "7.0")
DOTNET_8_0_VERSION=$(./dotnet-version.sh runtime "8.0")
DOTNET_9_0_VERSION=$(./dotnet-version-preview.sh Runtime "9.0")
DOTNET_9_0_VERSION_SAFE=${DOTNET_9_0_VERSION/-rc/}
DOTNET_9_0_VERSION_SAFE=${DOTNET_9_0_VERSION_SAFE/-preview/}

echo runtime versions: $DOTNET_6_0_VERSION $DOTNET_7_0_VERSION $DOTNET_8_0_VERSION $DOTNET_9_0_VERSION

DOTNET_6_0_ASP_VERSION=$DOTNET_6_0_VERSION
DOTNET_7_0_ASP_VERSION=$DOTNET_7_0_VERSION
DOTNET_8_0_ASP_VERSION=$DOTNET_8_0_VERSION
DOTNET_9_0_ASP_VERSION=$(./dotnet-version-preview.sh aspnetcore/Runtime "9.0")
DOTNET_9_0_ASP_VERSION_SAFE=${DOTNET_9_0_ASP_VERSION/-rc/}
DOTNET_9_0_ASP_VERSION_SAFE=${DOTNET_9_0_ASP_VERSION_SAFE/-preview/}

echo aspnet versions: $DOTNET_6_0_ASP_VERSION $DOTNET_7_0_ASP_VERSION $DOTNET_8_0_ASP_VERSION $DOTNET_9_0_ASP_VERSION

DOTNET_6_0_SDK_VERSION=$(./dotnet-version.sh sdk "6.0")
DOTNET_7_0_SDK_VERSION=$(./dotnet-version.sh sdk "7.0")
DOTNET_8_0_SDK_VERSION=$(./dotnet-version.sh sdk "8.0")
DOTNET_9_0_SDK_VERSION=$(./dotnet-version-preview.sh Sdk "9.0")
DOTNET_9_0_SDK_VERSION_SAFE=${DOTNET_9_0_SDK_VERSION/-rc/}
DOTNET_9_0_SDK_VERSION_SAFE=${DOTNET_9_0_SDK_VERSION_SAFE/-preview/}

echo sdk versions: $DOTNET_6_0_SDK_VERSION $DOTNET_7_0_SDK_VERSION $DOTNET_8_0_SDK_VERSION $DOTNET_9_0_SDK_VERSION

LATEST_VERSION=$DOTNET_8_0_VERSION
NEXT_VERSION=$DOTNET_9_0_VERSION
NEXT_VERSION_SAFE=$DOTNET_9_0_VERSION_SAFE
LATEST_SDK_VERSION=$DOTNET_8_0_SDK_VERSION
LATEST_NETSTANDARD_VERSION="2.1.0"

find "${ADADOTNET_ROOT}/dotnet-aspnetcore-runtime" -iname "*.ebuild" -print -delete
find "${ADADOTNET_ROOT}/dotnet-runtime" -iname "*.ebuild" -print -delete
find "${ADADOTNET_ROOT}/dotnet-sdk" -iname "*.ebuild" -print -delete
find "${ADADOTNET_ROOT}/dotnet-cli-bin" -iname "*.ebuild" -print -delete
find "${ADADOTNET_ROOT}/dotnet-man" -iname "*.ebuild" -print -delete
find "${ADADOTNET_ROOT}/netstandard" -iname "*.ebuild" -print -delete

cp dotnet-aspnetcore-runtime.ebuild "${ADADOTNET_ROOT}/dotnet-aspnetcore-runtime/dotnet-aspnetcore-runtime-${DOTNET_6_0_ASP_VERSION}.ebuild"
cp dotnet-aspnetcore-runtime.ebuild "${ADADOTNET_ROOT}/dotnet-aspnetcore-runtime/dotnet-aspnetcore-runtime-${DOTNET_7_0_ASP_VERSION}.ebuild"
cp dotnet-aspnetcore-runtime.ebuild "${ADADOTNET_ROOT}/dotnet-aspnetcore-runtime/dotnet-aspnetcore-runtime-${DOTNET_8_0_ASP_VERSION}.ebuild"
cp dotnet-aspnetcore-runtime.ebuild "${ADADOTNET_ROOT}/dotnet-aspnetcore-runtime/dotnet-aspnetcore-runtime-${DOTNET_9_0_ASP_VERSION_SAFE}.ebuild"
sed -i "/\${PV}/s//${DOTNET_9_0_ASP_VERSION}/g" "${ADADOTNET_ROOT}/dotnet-aspnetcore-runtime/dotnet-aspnetcore-runtime-${DOTNET_9_0_ASP_VERSION_SAFE}.ebuild"

cp dotnet-runtime.ebuild "${ADADOTNET_ROOT}/dotnet-runtime/dotnet-runtime-${DOTNET_6_0_VERSION}.ebuild"
cp dotnet-runtime.ebuild "${ADADOTNET_ROOT}/dotnet-runtime/dotnet-runtime-${DOTNET_7_0_VERSION}.ebuild"
cp dotnet-runtime.ebuild "${ADADOTNET_ROOT}/dotnet-runtime/dotnet-runtime-${DOTNET_8_0_VERSION}.ebuild"
cp dotnet-runtime.ebuild "${ADADOTNET_ROOT}/dotnet-runtime/dotnet-runtime-${DOTNET_9_0_VERSION_SAFE}.ebuild"
sed -i "/\${PV}/s//${DOTNET_9_0_VERSION}/g" "${ADADOTNET_ROOT}/dotnet-runtime/dotnet-runtime-${DOTNET_9_0_VERSION_SAFE}.ebuild"

cp dotnet-sdk.ebuild "${ADADOTNET_ROOT}/dotnet-sdk/dotnet-sdk-${DOTNET_6_0_SDK_VERSION}.ebuild"
cp dotnet-sdk.ebuild "${ADADOTNET_ROOT}/dotnet-sdk/dotnet-sdk-${DOTNET_7_0_SDK_VERSION}.ebuild"
cp dotnet-sdk.ebuild "${ADADOTNET_ROOT}/dotnet-sdk/dotnet-sdk-${DOTNET_8_0_SDK_VERSION}.ebuild"
cp dotnet-sdk.ebuild "${ADADOTNET_ROOT}/dotnet-sdk/dotnet-sdk-${DOTNET_9_0_SDK_VERSION_SAFE}.ebuild"
sed -i "/\${PV}/s//${DOTNET_9_0_SDK_VERSION}/g" "${ADADOTNET_ROOT}/dotnet-sdk/dotnet-sdk-${DOTNET_9_0_SDK_VERSION_SAFE}.ebuild"

cp dotnet-cli-bin.ebuild "${ADADOTNET_ROOT}/dotnet-cli-bin/dotnet-cli-bin-${LATEST_VERSION}.ebuild"
cp dotnet-cli-bin.ebuild "${ADADOTNET_ROOT}/dotnet-cli-bin/dotnet-cli-bin-${NEXT_VERSION_SAFE}.ebuild"
sed -i "/\${PV}/s//${NEXT_VERSION}/g" "${ADADOTNET_ROOT}/dotnet-cli-bin/dotnet-cli-bin-${NEXT_VERSION_SAFE}.ebuild"

cp dotnet-man.ebuild ${ADADOTNET_ROOT}/dotnet-man/dotnet-man-${LATEST_SDK_VERSION}.ebuild

cp netstandard.ebuild ${ADADOTNET_ROOT}/netstandard/netstandard-${LATEST_NETSTANDARD_VERSION}.ebuild
sed -i "/__DOTNET_VERSION__/s//${LATEST_SDK_VERSION}/g" "${ADADOTNET_ROOT}/netstandard/netstandard-${LATEST_NETSTANDARD_VERSION}.ebuild"

ebuild "${ADADOTNET_ROOT}/dotnet-aspnetcore-runtime/dotnet-aspnetcore-runtime-${LATEST_VERSION}.ebuild" manifest
ebuild "${ADADOTNET_ROOT}/dotnet-runtime/dotnet-runtime-${LATEST_VERSION}.ebuild" manifest
ebuild "${ADADOTNET_ROOT}/dotnet-sdk/dotnet-sdk-${LATEST_SDK_VERSION}.ebuild" manifest
ebuild "${ADADOTNET_ROOT}/dotnet-cli-bin/dotnet-cli-bin-${LATEST_VERSION}.ebuild" manifest
ebuild "${ADADOTNET_ROOT}/dotnet-man/dotnet-man-${LATEST_SDK_VERSION}.ebuild" manifest
ebuild "${ADADOTNET_ROOT}/netstandard/netstandard-${LATEST_NETSTANDARD_VERSION}.ebuild" manifest
