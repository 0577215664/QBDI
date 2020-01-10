#!/usr/bin/bash

set -e
set -x

BASEDIR=$(cd $(dirname "$0") && pwd -P)
GITDIR=$(cd "${BASEDIR}/../.." && pwd -P)

. "${BASEDIR}/../common.sh"

ARCH="X86_64"
DOCKER_IMG="ubuntu"
TAG="18.04"

if [[ -n "$2" ]]; then
    TAG="${2##*:}"
    DOCKER_IMG="${2%%:*}"
fi

if [[ "$1" = "X86" || "$1" = "x86" ]]; then
    ARCH="X86"
    DOCKER_IMG="i386/$DOCKER_IMG"
fi

CMAKE_ARGUMENT="$3"

DISTRIB="${DOCKER_IMG##*/}"

if [[ "$DISTRIB" = "ubuntu" ]]; then
    if [[ "${TAG}" = "18.10" || "${TAG:0:2}" -gt "18" ]]; then
        CMAKE_ARGUMENT="${CMAKE_ARGUMENT} -DQBDI_PACKAGE_LIBNCURSE6=ON"
    fi
elif [[ "$DISTRIB" = "debian" ]]; then
    if [[ "${TAG}" = "buster" || "${TAG:0:2}" = "10" ]]; then
        CMAKE_ARGUMENT="${CMAKE_ARGUMENT} -DQBDI_PACKAGE_LIBNCURSE6=ON"
    fi
fi

DOCKER_TAG="qbdi:x${ARCH: -2}_${DOCKER_IMG##*/}_${TAG}"

prepare_archive

docker build "${BASEDIR}" -t "${DOCKER_TAG}" --build-arg DOCKER_IMG="${DOCKER_IMG}:${TAG}" \
                                             --build-arg QBDI_ARCH="$ARCH" \
                                             --build-arg CMAKE_ARGUMENT="${CMAKE_ARGUMENT}"

delete_archive

echo "Success build ${DOCKER_TAG}"
