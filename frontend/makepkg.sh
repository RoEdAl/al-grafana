#!/bin/bash -e

# PKG_STAMP=$(git show -s --format=%ct)
PKG_STAMP=1598344037
PKG_DATE=$(date -u --date=@${PKG_STAMP})
echo "Package timestamp: ${PKG_DATE} (${PKG_STAMP})"

/usr/bin/makepkg "$@" SOURCE_DATE_EPOCH=${PKG_STAMP}
