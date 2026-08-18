# Left 4 Dead 2 Server

## 1. 简述

求生之路 2 插件服务器

**特点：**

- 基于 L4D2 官方专用服务器（Steam app 222860）
- Metamod: Source + SourceMod 插件平台基架
- l4dtoolz 突破人数上限与 Steam 限制
- 镜像不含游戏本体：首次启动自动通过 steamcmd 下载并应用补丁

**可用版本：**

| 游戏模式   | 镜像 tag |
| ---------- | -------- |
| 最新正式版 | `latest` |

## 2. 资源占用信息

### 2.1. 端口

| 端口号 | 协议 | 说明         |
| ------ | ---- | ------------ |
| 27015  | UDP  | 游戏联机端口 |
| 27015  | TCP  | RCON 端口    |

### 2.2. 持久卷

| 容器路径 | 说明                         |
| -------- | ---------------------------- |
| `/app`   | 游戏本体（首次启动自动下载） |

### 2.3. 环境变量

| 变量名           | 必填         | 说明                    |
| ---------------- | ------------ | ----------------------- |
| `STEAM_USERNAME` | 首次启动必填 | 拥有 L4D2 的 Steam 账号 |
| `STEAM_PASSWORD` | 首次启动必填 | 对应账号密码            |

Valve 已移除 L4D2 专用服的匿名下载权限，必须登录一个拥有 L4D2 的账号才可下载服务器文件。

## 3. 构建与运行

### 3.1. 构建并运行（Docker）

```bash
docker build -t left-4-dead-2:temp . && \
    docker run --rm -it \
        -e STEAM_USERNAME=your_steam_name \
        -e STEAM_PASSWORD=your_steam_password \
        -p 27015:27015/udp \
        -p 27015:27015/tcp \
        -v ./app:/app \
        left-4-dead-2:temp
```

### 3.2. 运行服务器（Podman）

```bash
IMAGE=ghcr.io/hm-gamesrv/left-4-dead-2:latest

if ! podman pull "$IMAGE"; then
    exit 1
fi

podman run --rm -it \
    --name left-4-dead-2 \
    --userns keep-id \
    --network pasta \
    -e STEAM_USERNAME=your_steam_name \
    -e STEAM_PASSWORD=your_steam_password \
    -p 27015:27015/udp \
    -p 27015:27015/tcp \
    -v ./app:/app \
    "$IMAGE"
```

## 4. 首次启动与维护

- 首次启动会下载数 GB 的游戏本体，完成后写入 `/app/.INSTALLED` 标记，后续启动直接跳过下载
- 补丁（插件、配置）在首次启动时应用一次，完成后写入 `/app/.PATCHED` 标记，后续启动跳过应用补丁
- 强制更新游戏：删除 `/app/.INSTALLED` 后重启容器，会重新执行 `validate` 校验并更新。建议同时删除 `/app/.PATCHED` 文件以确保补丁再次应用
