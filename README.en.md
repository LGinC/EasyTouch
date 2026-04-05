# EasyTouch

## [中文](README.md) | English 

EasyTouch is a cross-platform desktop automation tool for Windows, Linux, and macOS. It provides both a CLI and an MCP server, with support for mouse and keyboard control, screenshots, window management, and system information queries.

Currently supported CPU architectures on the following operating systems:

- [x] Windows
- [x] Linux
- [x] macOS (device validation is still incomplete)

**What Can You Do With It?**

When AI coding tools generate UI code, they still cannot actually see the screen the way a human can. They can read and write files, but they lack eyes and hands.

If you want to connect tools such as OpenClaw to WeChat or Feishu and let them inspect the desktop, or you want AI to operate your machine for you, EasyTouch is a good fit.

EasyTouch gives AI a pair of eyes and hands. It currently supports:

- System information: OS, CPU, memory, disks, processes
- Screen capabilities: display enumeration, pixel color sampling, screenshots
- Window control: enumerate, find, activate, close, read foreground window
- Input control: mouse move/click/wheel, keyboard key, hotkey, type, paste
- Clipboard: read text, write text, read file lists
- Waiters: wait for windows, focus, pixels, clipboard changes, process state
- App launch: start a target by path or URI

### Installation

Install the scoped launcher package if you want automatic platform selection. If you only want the package for the current host OS, you can install the platform package directly.

```bash
# Recommended: auto-select the current platform
npm i -g @whuanle/easytouch

# Windows
npm i -g easytouch-windows

# Linux
npm i -g easytouch-linux

# macOS
npm i -g easytouch-macos
```

`@whuanle/easytouch` delegates to the correct platform package on the current host. Each platform package contains both x64 and arm64 binaries, and the correct one is selected automatically based on the current CPU architecture.

On Windows, after installation you will find an executable entry named `et` under `AppData/Roaming/npm`.

![image-20260405194137861](images/image-20260405194137861.png)

### Usage Example

Capture the screen:

```bash
et screen capture --path a.png
```

![image-20260405194600430](images/image-20260405194600430.png)

<img src="images/d4ba9a4e7b88e26b30118b3c76f2dce5.jpg" alt="desktop screenshot" style="zoom: 25%;" />

### Use As Skills For AI (Recommended)

You only need to install the skills package:

```bash
npx skills add https://github.com/whuanle/EasyTouch
```

> Note: the skills package does not bundle the executable itself. On first use, the AI tool can install the matching platform package automatically, or you can install it yourself first, such as `npm i -g easytouch-windows`, `npm i -g easytouch-linux`, or `npm i -g easytouch-macos`.

![image-20260224090411080](images/image-20260224090411080.png)

### Use As An MCP Tool

If you only need EasyTouch for AI tool integration, using skills is usually simpler than configuring MCP manually.

In tools such as Claude, Cursor, VS Code, and Sidecar, MCP configuration is broadly similar. After installing through npm, prefer calling the global `et` command directly. That gives you one configuration that works across Windows, Linux, and macOS. Only fall back to a full path or `npx` when the host application cannot resolve commands from PATH.

Add the following to your configuration:

**After Global Installation (Recommended, Same On All Platforms)**

First run `npm i -g @whuanle/easytouch`, or install the matching platform package, then use:

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

**When The Host App Does Not Use PATH**

- Windows: set `command` to `C:\\Users\\<your-user>\\AppData\\Roaming\\npm\\et.cmd`
- Linux / macOS: run `npm prefix -g` first, then set `command` to `<prefix>/bin/et`

**Without Global Installation**

If you do not want a global install, you can start the server through `npx`. In that case, use `@whuanle/easytouch` so the package name stays the same across platforms.

- Windows: set `command` to `npx.cmd`
- Linux / macOS: set `command` to `npx`

```json
{
  "mcpServers": {
    "easytouch": {
      "command": "npx",
      "args": ["-y", "@whuanle/easytouch", "mcp-stdio"]
    }
  }
}
```

> In Windows GUI applications, `command` often needs to be written explicitly as `npx.cmd` or `et.cmd` rather than plain `npx`, because some hosts do not resolve `.ps1` / `.cmd` the same way PowerShell does.

### Platform Notes

Windows

- Fully supports all features
- Some capabilities may require administrator privileges

Linux

- Officially validated on Ubuntu Desktop 22.04 and 24.04
- Other distributions and desktop environments are best-effort; run the test script first
- Recommended in a graphical environment, preferably an X11 session
- Some capabilities may require `sudo`

Linux dependencies can be installed manually on Ubuntu:

```bash
# Basic dependencies (recommended)
sudo apt install xdotool xclip xsel imagemagick gnome-screenshot

# Additional Wayland dependencies (optional)
sudo apt install ydotool wl-clipboard grim
```

After installation, run the test script to validate compatibility:

```bash
node scripts/test-easytouch.js --cli-only --verbose
```

macOS

- Accessibility permission is required: System Settings -> Privacy & Security -> Accessibility
- Screen capture requires Screen Recording permission

## License

MIT License