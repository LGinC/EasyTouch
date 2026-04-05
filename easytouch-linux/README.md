# easytouch-linux

Linux 建议拆成两个阶段，不要一开始同时做 X11 和 Wayland。

## 第一阶段

- `mouse` 和 `keyboard`: `XTest`
- `screenshot`: `XGetImage` 或 `XShm`
- `window`: `Xlib` + EWMH
- `system`: `/proc`、`/sys`
- `element inspection`: `AT-SPI2` over D-Bus

## 第二阶段

- Wayland 权限模型
- PipeWire/portal 截图
- 不同 compositor 的窗口和输入策略

实现重点：

- 先把 X11 路线做稳定
- AT-SPI 单独封装
- 对权限不足和环境不支持给出明确错误
