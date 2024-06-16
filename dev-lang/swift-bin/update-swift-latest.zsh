#!/bin/zsh
SWIFTBIN_ROOT='/var/db/repos/neptune/dev-lang/swift-bin'

DEV_VERSION=$(env python3 get-filename.py swift-6_0-branch)
echo $DEV_VERSION
VERSION_BUMP=$(env python3 strip-filename.py "${DEV_VERSION}")

find "${SWIFTBIN_ROOT}" -iname "*_pre.ebuild" -print -delete

cp swift-bin-pre.ebuild ${SWIFTBIN_ROOT}/swift-bin-6.0.0.${VERSION_BUMP}_pre.ebuild
sed -i "/__SWIFT_VERSION__/s//${DEV_VERSION}/g" "${SWIFTBIN_ROOT}/swift-bin-6.0.0.${VERSION_BUMP}_pre.ebuild"
ebuild "${SWIFTBIN_ROOT}/swift-bin-6.0.0.${VERSION_BUMP}_pre.ebuild" manifest
