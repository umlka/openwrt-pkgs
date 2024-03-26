#!/bin/bash

set -x
revision="${1:-HEAD}"
TMP_DIR="$(mktemp -d)" || exit 1
trap 'rm -rf "${TMP_DIR}"' 0 1 2 3
export CUR_DIR="$(cd "$(dirname ${0})" ; pwd)"

cd "${TMP_DIR}" && \
git clone https://github.com/daeuniverse/dae . && \
fullSHA="$(git rev-parse --verify ${revision})"
if [ "${?}" -ne 0 ]; then
	echo -e "\e[33mInvalid option \e[0mpassed to '\e[31m`basename ${0}`\e[0m' (options:\e[31m${@}\e[0m)"
	exit 1
fi

git show -s "${fullSHA}"
tag="$(git describe --tags --abbrev=0 ${fullSHA} | sed 's/^v//i')"
date="$(git log -1 --format='%cd' --date=short ${fullSHA} | sed 's/-//g')"
count="$(git rev-list --count ${fullSHA})"
commit="$(git rev-parse --short ${fullSHA})"
sed -i "s/^\(PKG_VERSION:=\).*/\1${tag}-${date}.r${count}.${commit}/" "${CUR_DIR}/Makefile"
sed -i "s/^\(PKG_SOURCE_VERSION:=\).*/\1${fullSHA}/" "${CUR_DIR}/Makefile"
sed -i 's/^\(PKG_MIRROR_HASH:=\).*/\1skip/' "${CUR_DIR}/Makefile"
echo -e "\e[31mdae\e[0m \e[33mhas been updated to the commit.\e[0m(\e[92mhttps://github.com/daeuniverse/dae/commit/${fullSHA}\e[0m)"
