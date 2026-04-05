# EasyTouch Skills

## 1. 环境要求

- Node.js >= 18（npm 安装场景）
- 或直接使用编译产物：
	- Windows: zig-out/bin/et.exe
	- Linux/macOS: zig-out/bin/et
- 建议系统：Windows（能力最完整）

## 2. 安装方式

### npm 安装

```bash
# 推荐：自动匹配当前平台
npm install -g @whuanle/easytouch

# Windows
npm install -g easytouch-windows

# Linux
npm install -g easytouch-linux

# macOS
npm install -g easytouch-macos
```

安装后直接使用：

```bash
et help
```

### 仓库内构建

```bash
zig build
```

## 3. CLI 命令

### 核心命令

- et help
- et status
- et platforms
- et interfaces
- et requirements
- et mcp-stdio
- et mcp-stdio --output json

### 自动化命令

- system os-info
- system cpu-info
- system memory-info
- system disk-list
- system process-list
- system hardware-info
- system network-info
- mouse position
- mouse move --x <x> --y <y> [--duration-ms <ms>] [--jitter-px <px>] [--step-delay-ms <ms>]
- mouse click [--button <left|right|middle>] [--count <n>]
- mouse scroll --delta <amount>
- window list [--include-hidden] [--pid <pid>]
- window foreground
- window find --title <text> [--match <contains|exact>] [--include-hidden] [--pid <pid>]
- window activate --handle <handle>
- window close --handle <handle>
- app launch --target <path-or-uri>
- clipboard get-text
- clipboard set-text --text <value>
- clipboard get-files
- clipboard set-files --paths <path1;path2;...>
- clipboard set-image --path <image-file>
- keyboard key --key <name>
- keyboard hotkey --keys <combo>
- keyboard type --text <value>
- keyboard type-keys --text <value> [--key-delay-ms <ms>]
- keyboard ime-switch [--strategy <win-space|alt-shift|ctrl-shift>]
- keyboard caps-lock [--state <toggle|on|off>]
- keyboard paste [--expect-title <text>] [--match <contains|exact>]
- screen displays
- screen pixel-color --x <x> --y <y>
- screen capture [--path <file>]
- wait window --title <text> [--timeout-ms <ms>] [--match <contains|exact>] [--foreground-only]
- wait focus --title <text> [--timeout-ms <ms>] [--match <contains|exact>]
- wait activate --handle <handle> [--expect-active <true|false>] [--timeout-ms <ms>]
- wait pixel --x <x> --y <y> --hex <RRGGBB> [--timeout-ms <ms>]
- wait clipboard [--expect-text <value>] [--timeout-ms <ms>] [--match <contains|exact>]
- wait process [--name <text>|--pid <pid>] [--expect-running <true|false>] [--timeout-ms <ms>] [--match <contains|exact>]

等待器说明：
- wait 系列用于“动作后确认状态”，避免页面/窗口未就绪就继续执行下一步。
- 典型场景：点击后等待窗口出现、切换后等待焦点、输入后等待像素或剪贴板变化、启动后等待进程状态。

## 4. MCP 接入

### 查看工具清单（manifest）

```bash
et mcp-stdio --output json
```

### 启动 MCP stdio 服务

```bash
et mcp-stdio
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

## 5. 注意事项

- 推荐流程：观察 -> 动作 -> 等待确认
- 不要连续盲操作（点击/输入后必须确认）
- 建议统一使用 --output json，便于程序解析
- 标题匹配模式统一：contains|exact
- wait 默认超时：timeout_ms=2000
- wait_process 支持 expect_running=true|false
- 高风险动作（鼠标、键盘、窗口激活/关闭、剪贴板写）前后都要做观察或等待
- Linux/macOS 能力存在未覆盖路径，上生产前必须逐项实测
- 失败时优先看 failure.code / failure.message / failure.detail