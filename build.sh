#!/usr/bin/env bash
# 静态编译 plow，产物不依赖 glibc，可运行于任意 Linux x86_64 机器
# Usage:
#   ./build.sh                 # 编译当前平台 (linux/amd64) 静态二进制
#   ./build.sh linux arm64     # 交叉编译指定平台
#   ./build.sh all             # 同时构建 linux amd64 / arm64

set -euo pipefail

cd "$(dirname "$0")"

APP_NAME="plow"
LDFLAGS="-s -w"

build_one() {
    local goos="$1"
    local goarch="$2"
    local output="$3"

    echo ">>> Building ${output} (GOOS=${goos} GOARCH=${goarch}, CGO disabled)"
    CGO_ENABLED=0 GOOS="${goos}" GOARCH="${goarch}" \
        go build -trimpath -ldflags="${LDFLAGS}" -o "${output}" .

    echo "    -> $(file "${output}" | cut -d: -f2-)"
    echo "    -> size: $(ls -lh "${output}" | awk '{print $5}')"
}

mode="${1:-default}"

case "${mode}" in
    all)
        mkdir -p dist
        build_one linux amd64  "dist/${APP_NAME}-linux-amd64"
        build_one linux arm64  "dist/${APP_NAME}-linux-arm64"
        ;;
    default)
        build_one linux amd64 "${APP_NAME}"
        ;;
    *)
        # ./build.sh <goos> <goarch>
        goos="$1"
        goarch="${2:-amd64}"
        mkdir -p dist
        build_one "${goos}" "${goarch}" "dist/${APP_NAME}-${goos}-${goarch}"
        ;;
esac

echo "Done."
