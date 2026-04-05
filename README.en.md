# EasyTouch

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

Install the package for your current operating system. If you want a single command that auto-selects the current platform, install the scoped launcher package.

```bash
# Auto-detect the current platform
npm i -g @whuanle/easytouch

# Windows
npm i -g easytouch-windows

# Linux
npm i -g easytouch-linux

# macOS
npm i -g easytouch-macos
```

Each platform package contains both x64 and arm64 binaries. After installation, the correct binary is selected automatically based on the current CPU architecture.

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

In tools such as Claude and Cursor, MCP configuration is broadly similar. After installing through npm or bun, prefer calling `et` or `npx` directly. If you must reference the real binary inside a platform package, it is located under `bin/x64` or `bin/arm64`. For example, on Windows the directory is `AppData/Roaming/npm/node_modules/easytouch-windows/bin`.

Add the following to your configuration:

**NPM Installation (Recommended)**

When using `npx`, use the package name for the current platform: `easytouch-windows` on Windows, `easytouch-linux` on Linux, and `easytouch-macos` on macOS.

```json
{
  "mcpServers": {
    "easytouch": {
      "command": "npx",
      "args": ["-y", "easytouch-windows", "mcp-stdio"]
    }
  }
}
```

> Replace `easytouch-windows` with the package name for the current operating system.

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