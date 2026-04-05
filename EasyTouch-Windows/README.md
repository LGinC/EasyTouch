# easytouch-windows

Windows 版本建议按下面的顺序落地：

1. `mouse` 和 `keyboard`: `SendInput`、`SetCursorPos`、`GetCursorPos`
2. `screenshot`: 先 `BitBlt`，后续再补 `DXGI Desktop Duplication`
3. `window`: `EnumWindows`、`GetWindowRect`、`GetWindowTextW`、`SetForegroundWindow`
4. `system`: `GetSystemInfo`、`GlobalMemoryStatusEx`、`CreateToolhelp32Snapshot`
5. `element inspection`: `UI Automation COM`

实现重点：

- 统一坐标和 DPI
- 处理权限边界和焦点切换
- 把 UI Automation 做成单独模块，不要和截图逻辑耦合
