---
name: easytouch
description: A cross-platform system automation operation tool that supports Windows, Linux, and macOS. It offers two usage methods: CLI command line and MCP server. It supports functions such as mouse and keyboard control, screen capture, window management, and system information query.
---

# EasyTouch Skill

## Requirements

When installed through npm: Node.js >= 18.

> If you download binaries directly from GitHub Releases, add them to your PATH manually.

## Installation

### Install with npm

```bash
# Recommended: auto-select the current platform
npm install -g @whuanle/easytouch

# Windows
npm install -g easytouch-windows

# Linux
npm install -g easytouch-linux

# macOS
npm install -g easytouch-macos
```

Command entry after installation:

```bash
et help
```

## CLI Commands

### Core Commands

```bash
# Show the command overview and argument format
et help

# Show current runtime status and host platform information
et status

# List platform implementation status and capability modules
et platforms

# Show the CLI/MCP interface overview and capability mapping
et interfaces

# Show runtime requirements and capability prerequisites
et requirements

# Start the MCP stdio server
et mcp-stdio

# Output the MCP manifest (tool list) as JSON
et mcp-stdio --output json
```

### Automation Commands

Command output is JSON by default. Use `--output text` if you want plain text output.

#### System Information

| Command | Purpose |
| --- | --- |
| `system os-info` | Read OS version, architecture, and host name |
| `system cpu-info` | Read CPU architecture and core information |
| `system memory-info` | Read total, available, and used memory |
| `system disk-list` | List disks and capacity information |
| `system process-list` | List current processes |
| `system hardware-info` | Read hardware overview such as architecture, cores, page size, physical memory, virtual memory, and machine name |
| `system network-info` | Read network adapter information such as IPv4, MAC, adapter type, and DHCP state |

Platform notes:

- Windows: fully available.
- Linux: generally available; `system network-info` depends on the `ip` command.
- macOS: generally available; data mainly comes from system tools such as `sysctl`, `vm_stat`, and `ifconfig`.

#### Mouse

| Command | Purpose |
| --- | --- |
| `mouse position` | Read the current mouse position |
| `mouse move --x <x> --y <y> [--duration-ms <ms>] [--jitter-px <px>] [--step-delay-ms <ms>]` | Move the mouse along a progressive path with optional jitter and delay to look more human |
| `mouse click [--button <left\|right\|middle>] [--count <n>]` | Perform a mouse click |
| `mouse scroll --delta <amount>` | Perform a mouse wheel scroll |

Platform notes:

- Windows: fully available.
- Linux: depends on `xdotool` and requires an X11 or XWayland session; native Wayland sessions may block or restrict the behavior.
- macOS: depends on Accessibility permission; reading or injecting mouse input fails if permission is not granted.

Parameter notes:

- `--x` / `--y`: target coordinate as an integer
- `--duration-ms`: total movement duration in milliseconds, default `280`
- `--jitter-px`: trajectory jitter in pixels, default `3`
- `--step-delay-ms`: delay between steps in milliseconds, default `8`
- `--button`: button type, `left`, `right`, or `middle`
- `--count`: click count, default `1`
- `--delta`: scroll amount; positive and negative values represent opposite directions

#### Windows And Apps

| Command | Purpose |
| --- | --- |
| `window list [--include-hidden] [--pid <pid>]` | List windows, optionally filtering by visibility and process |
| `window foreground` | Read the current foreground window |
| `window find --title <text> [--match <contains\|exact>] [--include-hidden] [--pid <pid>]` | Find windows by title |
| `window activate --handle <handle>` | Activate a window by handle |
| `window show --handle <handle>` | Show a window and request activation |
| `window minimize --handle <handle>` | Minimize a window |
| `window maximize --handle <handle>` | Maximize a window |
| `window restore --handle <handle>` | Restore a window from minimized or maximized state |
| `window move --handle <handle> --x <x> --y <y> [--width <n>] [--height <n>]` | Move a window to the target position and optionally resize it |
| `window close --handle <handle>` | Request to close a window by handle |
| `app launch --target <path-or-uri>` | Launch an app, open a file, or open a URI |

Platform notes:

- Windows: fully available.
- Linux: `window list`, `window foreground`, `window activate`, and `window close` are available; `window show` and `window minimize` depend on `xdotool`; `window maximize`, `window restore`, and `window move` depend on `wmctrl` and an EWMH-compatible window manager.
- Linux: an X11 or XWayland session is generally required; native Wayland sessions may restrict window handles and window control.
- macOS: window control depends on Accessibility and Automation permissions; `window show`, `window minimize`, `window maximize`, `window restore`, `window move`, and `window close` are implemented through `System Events`, and when a process has multiple windows with the same title the first match is used.

Parameter notes:

- `--title`: window title keyword
- `--match`: match mode, `contains` or `exact`
- `--include-hidden`: include hidden windows
- `--pid`: filter by process ID
- `--handle`: window handle as a non-negative integer
- `--x` / `--y`: target window position
- `--width` / `--height`: target window size; when omitted, the current size is preserved
- `--target`: executable path, file path, or URI

#### Clipboard

| Command | Purpose |
| --- | --- |
| `clipboard get-text` | Read clipboard text |
| `clipboard set-text --text <value>` | Write clipboard text |
| `clipboard get-files` | Read the file list currently stored in the clipboard |
| `clipboard set-files --paths <path1;path2;...>` | Write a file list to the clipboard for later paste operations |
| `clipboard set-image --path <image-file>` | Write an image to the clipboard for later paste operations |

Platform notes:

- Windows: fully available.
- Linux: depends on `wl-copy` / `wl-paste` or `xclip` / `xsel`; when these tools are missing, related text, file, and image clipboard features are unavailable.
- macOS: text clipboard support uses `pbcopy` / `pbpaste`; file and image clipboard support uses `osascript` / JXA and may fail if the host process lacks Automation permission.

Parameter notes:

- `--text`: text to write
- `--paths`: multiple file paths separated by semicolons `;`
- `--path`: a single image file path

#### Keyboard

| Command | Purpose |
| --- | --- |
| `keyboard key --key <name>` | Send a single key press |
| `keyboard hotkey --keys <combo>` | Send a key combination |
| `keyboard type --text <value>` | Inject text directly |
| `keyboard type-keys --text <value> [--key-delay-ms <ms>]` | Type text key by key to simulate human typing |
| `keyboard ime-switch [--strategy <win-space\|alt-shift\|ctrl-shift>]` | Switch the input method |
| `keyboard caps-lock [--state <toggle\|on\|off>]` | Control caps lock state |
| `keyboard paste [--expect-title <text>] [--match <contains\|exact>]` | Perform a paste action with optional window title protection |

Platform notes:

- Windows: fully available.
- Linux: depends on `xdotool` and requires an X11 or XWayland session; native Wayland sessions usually block or destabilize keyboard injection.
- macOS: depends on Accessibility permission; `keyboard ime-switch` maps strategies to system shortcuts, but whether the input method actually changes depends on the current OS shortcut mapping.
- macOS: `keyboard caps-lock` is currently reliable only for `toggle`; `on` and `off` are not guaranteed.

Parameter notes:

- `--key`: key name such as `enter`, `esc`, or `f5`
- `--keys`: key combination such as `ctrl+c` or `ctrl+shift+s`
- `--text`: input text
- `--key-delay-ms`: delay between key presses in simulated typing mode
- `--strategy`: input method switching shortcut strategy
- `--state`: caps lock state, `toggle`, `on`, or `off`
- `--expect-title`: require the foreground window title to match before pasting
- `--match`: title match mode, `contains` or `exact`

#### Screen And Capture

| Command | Purpose |
| --- | --- |
| `screen displays` | List displays and resolutions |
| `screen pixel-color --x <x> --y <y>` | Read the color of a specific pixel |
| `screen capture [--path <file>] [--display-id <id>] [--window-handle <handle>]` | Capture all screens by default, or capture a specific display or window |

Platform notes:

- Windows: fully available.
- Linux: `screen displays` depends on `xrandr`, and `screen capture` depends on one of `grim`, `gnome-screenshot`, `scrot`, or `import`.
- Linux: `screen capture --display-id` and `screen capture --window-handle` are still not implemented; full-desktop capture is the only guaranteed mode.
- Linux: in native Wayland sessions, screenshots and pixel reads may be restricted by session type or desktop permissions.
- macOS: `screen capture` depends on the system `screencapture` command; when Screen Recording permission is missing, capture and pixel reads fail.
- macOS: directional capture via `--display-id` and `--window-handle` is supported when the target window still exists in the current CoreGraphics snapshot.

Parameter notes:

- `--x` / `--y`: pixel coordinates
- `--path`: output path for the screenshot; when omitted, a default path is used
- `--display-id`: display ID from `screen displays`
- `--window-handle`: window handle from `window list` or `window foreground`

```bash
# Default: capture all screens
screen capture --path ./captures/all.png

# Capture a specific display
screen capture --display-id 1 --path ./captures/display-1.png

# Capture a specific window
screen capture --window-handle 0x001A09F2 --path ./captures/window.png
```

#### Waiters

Waiters are used to confirm state after an action, instead of assuming the action already succeeded.
Typical usage: click, type, or switch windows first, then wait until the expected condition becomes true.
This reduces mistakes caused by delayed refresh, focus stealing, or pixels that have not changed yet.

| Command | Purpose |
| --- | --- |
| `wait window --title <text> [--timeout-ms <ms>] [--match <contains\|exact>] [--foreground-only]` | Wait for a target window to appear or satisfy the foreground constraint |
| `wait focus --title <text> [--timeout-ms <ms>] [--match <contains\|exact>]` | Wait for the focused window title to match |
| `wait activate --handle <handle> [--expect-active <true\|false>] [--timeout-ms <ms>]` | Wait for a specific window handle to become active, or wait for it to lose activation |
| `wait pixel --x <x> --y <y> --hex <RRGGBB> [--timeout-ms <ms>]` | Wait until a pixel reaches the expected color |
| `wait clipboard [--expect-text <value>] [--timeout-ms <ms>] [--match <contains\|exact>]` | Wait for clipboard changes or for clipboard text to match |
| `wait process [--name <text>\|--pid <pid>] [--expect-running <true\|false>] [--timeout-ms <ms>] [--match <contains\|exact>]` | Wait for a process to enter the expected state |

Platform notes:

- Windows: fully available.
- Linux: waiters themselves are available, but they inherit lower-level dependencies; for example, `wait activate` depends on X11/XWayland focus support, `wait clipboard` depends on clipboard backend tools, and `wait pixel` depends on a readable graphical session.
- macOS: waiters are generally available, but commands such as `wait activate`, `wait clipboard`, and `wait pixel` are still limited by system permissions and graphical session state.

Parameter notes:

- `--timeout-ms`: maximum waiting time in milliseconds; timeout returns a failure
- `--match`: text match mode, `contains` or `exact`
- `--foreground-only`: only match the current foreground window, used by `wait window`
- `--handle`: target window handle used by `wait activate`
- `--expect-active`: `true` waits for activation and `false` waits for deactivation
- `--expect-text`: expected clipboard text; when omitted, wait for any change
- `--name` / `--pid`: process name or process ID
- `--expect-running`: expected process existence state; `true` waits for launch and `false` waits for exit

Complex parameter combinations:

```bash
# Exact title match + foreground-only
wait window --title "Notepad" --match exact --foreground-only --timeout-ms 5000

# Wait for a window to become active (handle comes from window list)
wait activate --handle 0x001A09F2 --expect-active true --timeout-ms 5000

# Wait for a pixel color in hexadecimal
wait pixel --x 100 --y 200 --hex FFCC00 --timeout-ms 3000

# Wait for a process to exit
wait process --name "chrome" --expect-running false --match contains --timeout-ms 10000
```

## Notes

The overall feature set was designed around Windows first. Everything listed above is available on Windows. Linux and macOS now cover most common capabilities as well, but they still depend on platform-specific permissions, desktop sessions, and external tools.

Linux:

- Mouse, keyboard, and window control depend on `xdotool` and require an X11 or XWayland session.
- `window maximize`, `window restore`, and `window move` depend on `wmctrl` and an EWMH-compatible window manager.
- Clipboard text, file, and image support depend on `wl-copy` / `wl-paste` or `xclip` / `xsel`.
- `screen displays` depends on `xrandr`, and `screen capture` depends on one of `grim`, `gnome-screenshot`, `scrot`, or `import`.
- `system network-info` depends on the `ip` command.
- `screen capture --display-id` and `screen capture --window-handle` are still not implemented on Linux; full desktop capture is the only guaranteed mode.
- In native Wayland sessions, some window handles, input injection, pixel reads, and window control operations may be restricted by the desktop environment; X11 or XWayland is more reliable.

macOS:

- Window control, keyboard input, and clipboard file or image automation depend on Accessibility and Automation permissions. Commands fail if the host process is not authorized.
- `window show`, `window minimize`, `window maximize`, `window restore`, `window move`, and `window close` operate through `System Events`. If a process owns multiple windows with the same title, the system acts on the first matching window.
- `keyboard ime-switch` maps strategies on macOS as follows: `win-space` -> `Command+Space`, `alt-shift` -> `Option+Space`, and `ctrl-shift` -> `Control+Space`. Whether the input method really changes depends on the current OS shortcut bindings.
- `keyboard caps-lock` currently supports only `toggle`; `on` and `off` are not yet reliable.

Task orchestration:

- Recommended workflow: observe first, act second, confirm last
  - Observe: `window.find` / `window.foreground` / `screen.pixel-color`
  - Act: `window.activate` / `keyboard.*` / `mouse.*` / `app.launch`
  - Confirm: `wait.window` / `wait.focus` / `wait.pixel` / `wait.clipboard` / `wait.process`
- Do not perform blind actions in sequence. After clicking, typing, or switching windows, confirm the resulting state immediately.
- Parameter conventions:
  - match mode: `contains|exact`
  - handle: non-negative integer
  - x/y and delta: signed 32-bit integers
  - default waiter timeout: `timeout_ms=2000`
  - wait process expectation: `expect_running=true|false`
- Insert observation or waiting steps before and after high-risk actions such as mouse input, keyboard input, window activation, window closing, or clipboard writes.
- Some Linux and macOS capabilities still need to be validated in the target environment.
- On failure, read `failure.code`, `failure.message`, and `failure.detail` first.

## MCP Integration

### Start the MCP stdio server

```bash
et mcp-stdio
```

### Export the tool manifest

```bash
et mcp-stdio --output json
```

### Configuration Example

Prefer running `init` after a global install so it copies out the real native `et` binary, then point MCP directly at that file.

```bash
npm i -g @whuanle/easytouch
easytouch init
```

This copies the native `et` binary for the current host directly out of the package.

Default output paths:

- Windows: `<npm root -g>/@whuanle/easytouch/et.exe`
- Linux / macOS: `<npm root -g>/@whuanle/easytouch/et`

It also refreshes the global `et` command.

You can also choose a custom output path with `--output`.

Recommended configuration:

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

On Windows, use `et.exe` as the filename. On Linux and macOS, use `et`.

By default this writes `et` into the globally installed package directory and refreshes the global `et` command. You can also pick a fixed output path:

```bash
easytouch init --output <where-you-want-et>
```

If you install a platform package directly, use `easytouch-windows init`, `easytouch-linux init`, or `easytouch-macos init`.

If you need to inspect the actual paths, run `npm root -g` and `npm prefix -g`.

If the host resolves PATH correctly, MCP can use `command: "et"`; otherwise point it at the real path from `npm prefix -g` or `npm root -g`.

### Semantic Element Tree Targeting

For more reliable targeting, inspect the foreground window tree first and then find, wait for, click, or invoke by element id:

```bash
et element tree --output json
et element find --name "OK" --control-type Button --output json
et wait element --name "Save" --control-type Button --timeout-ms 5000 --output json
et element click --element-id root/0/3 --output json
et element invoke --element-id root/0/3 --output json
```

`element tree` returns fields such as `element_id`, `control_type`, `automation_id`, `class_name`, `framework_id`, `center`, `bounds`, and `children`, which makes model-driven targeting much more stable than screenshot-only coordinates.

`element find` searches by `element_id`, `name`, `automation_id`, `class_name`, `control_type`, and `framework_id`. `wait element` polls until a matching element appears. `element invoke` uses a semantic action or a center-click fallback.

Platform requirements:

- Windows: UI Automation + PowerShell.
- Linux: `python3` or `python` with `pyatspi`; center-click fallback also requires `xdotool`.
- macOS: `osascript` + System Events, and the host process must have Accessibility / Automation permissions.