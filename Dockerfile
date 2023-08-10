# syntax=docker/dockerfile:1.6
FROM golang:1.21-bullseye AS golang-builder

ARG PACKAGE=ini-file
ARG TARGET_DIR=common
# renovate: datasource=github-releases depName=bitnami/ini-file extractVersion=^v(?<version>\d+\.\d+.\d+)
ARG VERSION=1.4.6
ARG REF=v${VERSION}
ARG CGO_ENABLED=0

RUN mkdir -p /opt/bitnami
RUN --mount=type=cache,target=/root/.cache/go-build <<EOT /bin/bash
    set -ex

    rm -rf ${PACKAGE} || true
    mkdir -p ${PACKAGE}
    git clone -b "${REF}" https://github.com/bitnami/ini-file ${PACKAGE}

    pushd ${PACKAGE}
    go mod download
    go build -v -ldflags '-d -s -w' .

    mkdir -p /opt/bitnami/${TARGET_DIR}/licenses
    mkdir -p /opt/bitnami/${TARGET_DIR}/bin
    cp -f LICENSE.md /opt/bitnami/${TARGET_DIR}/licenses/${PACKAGE}-${VERSION}.md
    echo "${PACKAGE}-${VERSION},GPL2,https://github.com/bitnami/ini-file/archive/${REF}.tar.gz" > /opt/bitnami/common/licenses/gpl-source-links.txt
    cp -f ${PACKAGE} /opt/bitnami/${TARGET_DIR}/bin/${PACKAGE}
    popd

    rm -rf ${PACKAGE}
EOT

FROM bitnami/minideb:bullseye as stage-0

COPY --link --from=golang-builder /opt/bitnami /opt/bitnami
