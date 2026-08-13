#!/bin/bash
set -euo pipefail

# 首次启动：下载游戏本体
if [ ! -f /app/.INSTALLED ]; then
    echo "[init] /app 未安装，开始通过 steamcmd 下载 L4D2 服务端..."

    # 下载前检查所需的环境变量
    if [ -z "${STEAM_USERNAME:-}" ] || [ -z "${STEAM_PASSWORD:-}" ]; then
        echo "[init] 错误：需要设置 STEAM_USERNAME 与 STEAM_PASSWORD 环境变量" >&2
        exit 1
    fi

    /opt/steamcmd/steamcmd.sh \
        +@sSteamCmdForcePlatformType linux \
        +force_install_dir /app \
        +login "$STEAM_USERNAME" "$STEAM_PASSWORD" \
        +app_update 222860 validate \
        +quit

    # 下载成功后再标记，避免半截安装被当成已完成
    if [ ! -x /app/srcds_run ]; then
        echo "[init] 错误：steamcmd 执行结束但 /app/srcds_run 不存在，下载可能失败" >&2
        exit 1
    fi

    touch /app/.INSTALLED
fi

# 应用补丁
if [ ! -f /app/.PATCHED ]; then
    echo "[init] 应用补丁 /app-patch -> /app"
    cp -rf /app-patch/. /app/
    touch /app/.PATCHED
fi

exec "$@"
