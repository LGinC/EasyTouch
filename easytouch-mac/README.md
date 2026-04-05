# easytouch-mac

macOS 版本建议优先使用系统框架，不要绕回浏览器或图像识别侧路。

1. `mouse` 和 `keyboard`: `CGEventCreateMouseEvent`、`CGEventCreateKeyboardEvent`
2. `screenshot`: `CGDisplayCreateImage` 或后续 `ScreenCaptureKit`
3. `window`: `CGWindowListCopyWindowInfo`
4. `system`: `sysctl`、`host_statistics`
5. `element inspection`: `AXUIElement`

实现重点：

- 明确权限检测和错误提示
- 统一坐标系和多显示器换算
- 把 Objective-C runtime bridge 限制在少量封装文件内
