# Left 4 Dead 2 Server

## 简述

求生之路 2 插件服务器

**特点：**

- 基于 L4D2 官方专用服务器（Steam app 222860）
- Metamod: Source + SourceMod 插件平台基架
- l4dtoolz 突破人数上限与 Steam 限制
- 镜像不含游戏本体：首次启动自动通过 steamcmd 下载并应用补丁

## 首次启动与维护

- 首次启动会下载数 GB 的游戏本体，完成后写入 `/app/.INSTALLED` 标记，后续启动直接跳过下载
- 补丁（插件、配置）在首次启动时应用一次，完成后写入 `/app/.PATCHED` 标记，后续启动跳过应用补丁
- 强制更新游戏：删除 `/app/.INSTALLED` 后重启容器，会重新执行 `validate` 校验并更新。建议同时删除 `/app/.PATCHED` 文件以确保补丁再次应用
