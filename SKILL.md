---
name: easytouch
description: EasyTouch 是一个 Zig 构建的跨平台桌面自动化 runtime，统一提供 CLI 和 MCP stdio 接口。
---

# EasyTouch Skill

## 1. 角色定位

这份文档面向将 EasyTouch 作为 Skill 接入的 Agent 或自动化编排系统，不是普通终端用户入门文档。

对外入口是 et 二进制（npm 安装后由 bin/et.js 自动分发到平台包二进制）。

## 2. 接入前提

- Node.js >= 18（npm 包分发场景）
- 或可直接执行仓库构建产物：
  - Windows: zig-out/bin/et.exe
  - Linux/macOS: zig-out/bin/et
- 建议默认启用 --output json，确保结构化结果可被 Agent 稳定解析

## 3. Agent 工作流建议

推荐每一步都遵循：

1. 观察：window.find / window.foreground / screen.pixel-color
2. 动作：window.activate / keyboard.* / mouse.* / app.launch
3. 确认：wait.window / wait.focus / wait.pixel / wait.clipboard / wait.process

不要直接连续触发高风险动作（如鼠标点击、键盘输入），中间至少插入一次观察或等待确认。

## 4. CLI 入口与关键命令

通用格式：

```bash
et <command> [subcommand] [options]
```

公共选项：

- --output text|json（默认 json）

核心命令：

- et help
- et status
- et platforms
- et interfaces
- et requirements
- et mcp-stdio
- et mcp-stdio --output json

## 5. MCP 接入与协议面

启动：

```bash
et mcp-stdio
```

导出 manifest：

```bash
et mcp-stdio --output json
```

服务支持的方法：

- initialize
- ping
- tools/list
- tools/call

配置示例：

```json
{
  "mcpServers": {
    "easytouch": {
      "command": "et",
      "args": ["mcp-stdio"]
    }
  }
}
```

## 6. Tool 列表（当前实现）

系统：

- system_os_info
- system_cpu_info
- system_memory_info
- system_disk_list
- system_process_list

鼠标：

- mouse_position
- mouse_move
- mouse_click
- mouse_scroll

窗口：

- window_list
- window_foreground
- window_find
- window_activate
- window_close

应用：

- app_launch

剪贴板：

- clipboard_get_text
- clipboard_set_text
- clipboard_get_files

键盘：

- keyboard_key_press
- keyboard_hotkey
- keyboard_type_text
- keyboard_paste

屏幕：

- screen_displays
- screen_pixel_color
- screen_capture

等待器：

- wait_window
- wait_focus
- wait_pixel
- wait_clipboard
- wait_process

## 7. 关键参数约定

- 匹配模式统一为 contains|exact
- 窗口句柄参数 handle 为非负整数
- 坐标参数 x/y、滚动 delta 为 32 位有符号整数
- wait 系列默认 timeout_ms 为 2000
- wait_process 支持 expect_running=true|false

## 8. 兼容性与风险

- Windows 能力最完整，可优先作为主验证平台
- Linux/macOS 部分能力处于 basic 或 stub 阶段，接入前必须实测目标能力
- 键盘、鼠标、窗口激活属于 mutating 操作，建议在执行前后都做状态确认

## 9. 错误处理建议

将失败视为正常分支，至少处理：

- invalid_args
- timeout
- not_found
- not_implemented
- permission_denied
- system_error

建议在 Agent 中实现统一重试策略：

- 只对可恢复错误重试（如 timeout）
- 参数错误和权限错误立即上报
- 高风险动作失败后先回到观察命令再决策下一步

## 10. 关联文档

- [README.md](README.md)
- [skills/SKILL.md](skills/SKILL.md)
- [skills/README.md](skills/README.md)
