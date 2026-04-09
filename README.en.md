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

Install the aggregated package if you want the `init` helper. If you only want the package for the current host OS, you can install the platform package directly.

```bash
# Recommended: aggregated package, then run easytouch init
npm i -g @whuanle/easytouch

# Install only the current host platform package
npm i -g easytouch-windows
npm i -g easytouch-linux
npm i -g easytouch-macos
```

`@whuanle/easytouch` now bundles the Windows, Linux, and macOS native binaries for both x64 and arm64 directly inside the package. Running `easytouch init` copies out the correct native `et` file for the current host OS and CPU architecture.

Initialization commands:

```bash
# Aggregated package
easytouch init

# When you install a platform package directly
easytouch-windows init
easytouch-linux init
easytouch-macos init
```

`init` writes the native binary back into the installed package directory and refreshes the `et` command entry.

### Usage Example

The following examples assume you have already generated the native `et` binary with `init`.

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

In tools such as Claude, Cursor, VS Code, and Sidecar, MCP configuration is broadly similar. After installing through npm, prefer running the package `init.js` first so it copies out the real native binary for the current OS and CPU, then point MCP directly at that binary. That avoids bridge layers such as `et.cmd`, `et.sh`, or `npx.cmd`.

Add the following to your configuration:

**After Global Installation (Recommended)**

If you install the aggregated package globally, use the helper command to generate the native `et` file:

```bash
npm i -g @whuanle/easytouch
easytouch init
```

By default this writes `et` into the globally installed package directory and refreshes the global `et` command.

The default locations are usually:

- Windows: `<npm root -g>/@whuanle/easytouch/et.exe`
- Linux / macOS: `<npm root -g>/@whuanle/easytouch/et`

The global command entry is usually:

- Windows: `<npm prefix -g>/et.cmd`
- Linux / macOS: `<npm prefix -g>/bin/et`

If you want to inspect the actual paths on your machine, run:

```bash
npm root -g
npm prefix -g
```

You can also choose a fixed output path:

```bash
easytouch init --output <where-you-want-et>
```

If you install a platform package directly, use `easytouch-windows init`, `easytouch-linux init`, or `easytouch-macos init`.

After the native binary is prepared, point MCP to that file:

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

If the host does not resolve PATH correctly, switch `command` to the real path from `npm prefix -g` or `npm root -g`.

### Semantic Element Targeting

When a screenshot is sent to an AI model, coordinate guessing is usually the weakest part of the loop. EasyTouch can now inspect the semantic accessibility tree first and then find, wait for, click, or invoke by element identity:

```bash
et element tree --output json
et element find --name "OK" --control-type Button --output json
et wait element --name "Save" --control-type Button --timeout-ms 5000 --output json
et element click --element-id root/0/3 --output json
et element invoke --element-id root/0/3 --output json
```

Notes:

- `element tree` reads the current foreground window by default, or a specific one through `--window-handle`.
- The response includes `element_id`, `control_type`, `automation_id`, `class_name`, `framework_id`, `center`, `bounds`, and `children`, so an AI can reason about the UI more like a DOM tree instead of raw pixels.
- `element find` searches the tree by `element_id`, `name`, `automation_id`, `class_name`, `control_type`, and `framework_id`, then returns the first match.
- `wait element` polls the semantic tree until a matching element appears, which is useful for delayed dialogs, async rendering, or wizard flows.
- `element click` resolves the `element_id` again, activates the target window, and clicks the element center, so the model does not need to estimate coordinates from the screenshot.
- `element invoke` currently uses a platform semantic action or a center-click fallback so tools can express a single high-level “activate this control” intent.
- Use `--max-depth`, `--max-children`, and `--max-nodes` to keep large window trees bounded.

Platform notes:

- Windows: implemented through UI Automation + PowerShell.
- Linux: requires `python3` or `python` with `pyatspi`; center-click fallback also requires `xdotool` on X11/XWayland.
- macOS: requires `osascript` + System Events UI scripting, and the host process must have Accessibility and Automation permissions.

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