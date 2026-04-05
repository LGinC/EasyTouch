---
name: easytouch
description: EasyTouch Skill 接入文档（CLI + MCP）。
---

# EasyTouch Skill

## 环境要求

使用 npm 安装时：Node.js >= 18（npm 安装场景）

>  直接从 Github Release 下载文件后添加环境变量。



## 安装方式

### npm 安装

```bash
npm install easytouch
```

安装后命令入口：

```bash
et help
```



## CLI 命令

### 核心命令

```bash
# 显示命令总览与参数格式
et help

# 显示当前运行时状态与主机平台信息
et status

# 列出各平台实现状态与能力模块
et platforms

# 显示 CLI/MCP 接口与能力映射概览
et interfaces

# 显示能力接入和运行时要求清单
et requirements

# 启动 MCP stdio 服务
et mcp-stdio

# 输出 MCP manifest（工具清单）JSON
et mcp-stdio --output json
```



### 自动化命令

默认命令执行输出结果内容为 json，如需直接输出文本可使用 `-output text` 指定。



#### 系统信息

| 命令 | 用途 |
| --- | --- |
| `system os-info` | 读取操作系统版本、架构、主机名等信息 |
| `system cpu-info` | 读取 CPU 架构与核心信息 |
| `system memory-info` | 读取内存总量、可用量与占用情况 |
| `system disk-list` | 列出磁盘与容量信息 |
| `system process-list` | 列出当前进程列表 |
| `system hardware-info` | 读取硬件概览（架构、核心、页大小、物理内存、虚拟内存、机器名） |
| `system network-info` | 读取网络适配器信息（IPv4、MAC、网卡类型、DHCP 状态） |



#### 鼠标操作

| 命令 | 用途 |
| --- | --- |
| `mouse position` | 读取当前鼠标坐标 |
| `mouse move --x <x> --y <y> [--duration-ms <ms>] [--jitter-px <px>] [--step-delay-ms <ms>]` | 以渐进轨迹移动鼠标，支持抖动与延迟，更接近人类操作 |
| `mouse click [--button <left\|right\|middle>] [--count <n>]` | 执行鼠标点击 |
| `mouse scroll --delta <amount>` | 执行鼠标滚轮滚动 |



参数说明：

- `--x` / `--y`：目标坐标（整数）
- `--duration-ms`：总移动时长（毫秒），默认 `280`
- `--jitter-px`：轨迹抖动幅度（像素），默认 `3`
- `--step-delay-ms`：每一步移动间隔（毫秒），默认 `8`
- `--button`：按键类型，`left`、`right`、`middle`
- `--count`：点击次数，默认 `1`
- `--delta`：滚动量，正负值分别代表不同方向



#### 窗口与应用

| 命令 | 用途 |
| --- | --- |
| `window list [--include-hidden] [--pid <pid>]` | 列出窗口，可按可见性和进程过滤 |
| `window foreground` | 读取当前前台窗口信息 |
| `window find --title <text> [--match <contains\|exact>] [--include-hidden] [--pid <pid>]` | 按标题查找窗口 |
| `window activate --handle <handle>` | 按句柄激活窗口 |
| `window show --handle <handle>` | 显示窗口并请求激活 |
| `window minimize --handle <handle>` | 最小化窗口 |
| `window maximize --handle <handle>` | 最大化窗口 |
| `window restore --handle <handle>` | 恢复窗口（从最小化/最大化） |
| `window move --handle <handle> --x <x> --y <y> [--width <n>] [--height <n>]` | 拖曳/移动窗口到指定坐标，可选调整尺寸 |
| `window close --handle <handle>` | 按句柄请求关闭窗口 |
| `app launch --target <path-or-uri>` | 启动应用、打开文件或 URI |

参数说明：
- `--title`：窗口标题关键字
- `--match`：匹配模式，`contains` 或 `exact`
- `--include-hidden`：包含隐藏窗口
- `--pid`：按进程 ID 过滤
- `--handle`：窗口句柄（非负整数）
- `--x` / `--y`：窗口目标位置
- `--width` / `--height`：窗口目标尺寸（可选，不传则保持原尺寸）
- `--target`：可执行路径、文件路径或 URI



#### 剪贴板

| 命令 | 用途 |
| --- | --- |
| `clipboard get-text` | 读取剪贴板文本 |
| `clipboard set-text --text <value>` | 写入剪贴板文本 |
| `clipboard get-files` | 读取剪贴板中的文件列表 |
| `clipboard set-files --paths <path1;path2;...>` | 写入剪贴板文件列表（用于后续粘贴文件） |
| `clipboard set-image --path <image-file>` | 写入剪贴板图片（用于后续粘贴图片） |

参数说明：
- `--text`：要写入的文本内容
- `--paths`：多个文件路径，使用分号 `;` 分隔
- `--path`：单个图片文件路径



#### 键盘操作

| 命令 | 用途 |
| --- | --- |
| `keyboard key --key <name>` | 发送单个按键 |
| `keyboard hotkey --keys <combo>` | 发送组合键 |
| `keyboard type --text <value>` | 直接注入文本内容（直输模式） |
| `keyboard type-keys --text <value> [--key-delay-ms <ms>]` | 按键位逐字输入（模拟人类打字模式） |
| `keyboard ime-switch [--strategy <win-space\|alt-shift\|ctrl-shift>]` | 切换输入法 |
| `keyboard caps-lock [--state <toggle\|on\|off>]` | 控制大小写状态 |
| `keyboard paste [--expect-title <text>] [--match <contains\|exact>]` | 发送粘贴动作，可加窗口标题保护 |

参数说明：
- `--key`：按键名（如 `enter`、`esc`、`f5`）
- `--keys`：组合键（如 `ctrl+c`、`ctrl+shift+s`）
- `--text`：输入文本
- `--key-delay-ms`：模拟键位输入时每个按键之间的延迟
- `--strategy`：输入法切换快捷键策略
- `--state`：大小写状态，`toggle`、`on`、`off`
- `--expect-title`：执行粘贴前要求前台窗口标题匹配
- `--match`：标题匹配模式，`contains` 或 `exact`



#### 屏幕与截图

| 命令 | 用途 |
| --- | --- |
| `screen displays` | 列出显示器与分辨率信息 |
| `screen pixel-color --x <x> --y <y>` | 读取指定像素颜色 |
| `screen capture [--path <file>] [--display-id <id>] [--window-handle <handle>]` | 默认截取所有屏幕，或按屏幕/窗口定向截图 |

参数说明：
- `--x` / `--y`：像素坐标
- `--path`：截图输出路径，不传则使用默认路径
- `--display-id`：指定屏幕 ID（来自 `screen displays`）
- `--window-handle`：指定窗口句柄（来自 `window list` / `window foreground`）

```bash
# 默认：截取所有屏幕
screen capture --path ./captures/all.png

# 截取指定屏幕
screen capture --display-id 1 --path ./captures/display-1.png

# 截取指定窗口
screen capture --window-handle 0x001A09F2 --path ./captures/window.png
```



#### 等待器

等待器用于“动作后确认状态”，避免脚本只执行动作却不验证结果。
典型用法：点击/输入/窗口切换之后，先等待目标条件成立，再继续下一步。
这样可以降低因为界面刷新延迟、窗口抢焦点、颜色尚未变化导致的误操作。

| 命令 | 用途 |
| --- | --- |
| `wait window --title <text> [--timeout-ms <ms>] [--match <contains\|exact>] [--foreground-only]` | 等待目标窗口出现或满足前台条件 |
| `wait focus --title <text> [--timeout-ms <ms>] [--match <contains\|exact>]` | 等待焦点窗口标题匹配 |
| `wait activate --handle <handle> [--expect-active <true\|false>] [--timeout-ms <ms>]` | 监听指定窗口句柄是否成为前台激活窗口（或等待其失去激活） |
| `wait pixel --x <x> --y <y> --hex <RRGGBB> [--timeout-ms <ms>]` | 等待指定像素达到目标颜色 |
| `wait clipboard [--expect-text <value>] [--timeout-ms <ms>] [--match <contains\|exact>]` | 等待剪贴板变化或匹配目标文本 |
| `wait process [--name <text>\|--pid <pid>] [--expect-running <true\|false>] [--timeout-ms <ms>] [--match <contains\|exact>]` | 等待进程进入期望状态 |

参数说明：
- `--timeout-ms`：最长等待时间（毫秒），超时会返回失败
- `--match`：文本匹配模式，`contains` 或 `exact`
- `--foreground-only`：仅匹配当前前台窗口（仅 wait window）
- `--handle`：目标窗口句柄（用于 wait activate）
- `--expect-active`：`true` 等待激活，`false` 等待失去激活
- `--expect-text`：剪贴板期望文本，不传则等待任意变化
- `--name` / `--pid`：进程名称或进程 ID
- `--expect-running`：期望进程是否存在，`true` 表示等待启动，`false` 表示等待退出



复杂参数组合示例：

```bash
# 标题精确匹配 + 只接受前台窗口
wait window --title "记事本" --match exact --foreground-only --timeout-ms 5000

# 监听窗口激活（句柄来自 window list）
wait activate --handle 0x001A09F2 --expect-active true --timeout-ms 5000

# 颜色等待（十六进制）
wait pixel --x 100 --y 200 --hex FFCC00 --timeout-ms 3000

# 进程退出等待
wait process --name "chrome" --expect-running false --match contains --timeout-ms 10000
```



## MCP 接入

### 启动 MCP stdio 服务

```bash
et mcp-stdio
```



### 导出工具清单（manifest）

```bash
et mcp-stdio --output json
```



### 配置示例

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



## 注意事项

- 建议工作流：先观察，再动作，最后等待确认
  - 观察：window.find / window.foreground / screen.pixel-color
  - 动作：window.activate / keyboard.* / mouse.* / app.launch
  - 确认：wait.window / wait.focus / wait.pixel / wait.clipboard / wait.process
- 不要连续盲操作（点击、输入、窗口切换后应立即确认状态）
- 参数约定：
  - 匹配模式：contains|exact
  - handle：非负整数
  - x/y、delta：32 位有符号整数
  - wait 默认超时：timeout_ms=2000
  - wait_process：expect_running=true|false
- 高风险动作（鼠标/键盘/窗口激活/窗口关闭/剪贴板写）前后都应插入观察或等待
- Linux/macOS 的部分能力仍需以目标环境实测为准
- 失败时优先读取：failure.code / failure.message / failure.detail
