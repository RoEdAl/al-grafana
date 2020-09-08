#!/bin/bash -e

GIT_PATHSPEC=:/backend

if [ -n "$(git status --porcelain ${GIT_PATHSPEC})" ]; then 
	echo 'There are uncommited changes'
	exit 1
fi

PKG_STAMP=$(git log -n 1 '--pretty=format:%ct' -- ${GIT_PATHSPEC})
if [ -z "${PKG_STAMP}" ]; then
	echo 'Unable to get last commit timestamp'
	exit 1
fi

PKG_DATE=$(date -u --date=@${PKG_STAMP} '+%F %T')
echo "Package timestamp: ${PKG_DATE} [@${PKG_STAMP}]"

/usr/bin/makepkg "$@" SOURCE_DATE_EPOCH=${PKG_STAMP}
