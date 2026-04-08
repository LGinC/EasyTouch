# EasyTouch

## 中文 | [English](README.en.md) 

跨平台系统自动化操作工具，支持 Windows、Linux、macOS。提供 CLI 命令行和 MCP 服务器两种使用方式，支持鼠标键盘控制、屏幕截图、窗口管理、系统信息查询等功能。

目前支持以下操作系统的 x64 和 ARM64 两种 CPU 架构：

- [x] Windows

- [x] Linux
- [x] MACOS（目前缺少设备验证功能）



**你能用它做什么？**

大家平时使用各类 AI 编程工具，写页面是不是经常碰到 AI 写的页面怎么也不满意，写出来跟设计稿差异很大，这是因为 AI 只能通过读写代码来改进代码，它看不到界面，不像人类有感官。

如果你想通过 OpenClaw 接入微信、飞书，让它截图桌面发给你，但是 OpenClaw 像弱智一样搞不好，或者你希望 AI 能够操作你电脑的设备为你工作，那么 EasyTouch 非常适合你。



因为 EasyTouch 是给 AI 装上手和眼睛，它支持以下功能：

- 系统信息：系统、CPU、内存、磁盘、进程
- 屏幕能力：显示器枚举、像素取色、截图
- 窗口控制：枚举、查找、激活、关闭、前台窗口读取
- 输入控制：鼠标移动/点击/滚轮，键盘按键/组合键/输入/粘贴
- 剪贴板：读文本、写文本、读文件列表
- 等待器：等待窗口、焦点、像素、剪贴板、进程状态
- 应用启动：按路径或 URI 启动目标



### 安装

推荐安装带自动平台选择能力的启动包；如果你只想安装当前系统，也可以直接安装对应平台包：

```bash
# 推荐：自动匹配当前平台
npm i -g @whuanle/easytouch

# Windows
npm i -g easytouch-windows

# Linux
npm i -g easytouch-linux

# macOS
npm i -g easytouch-macos
```



`@whuanle/easytouch` 会在当前主机上调用对应的平台包；平台包内部同时包含 x64 和 arm64 二进制，安装后会根据当前 CPU 架构自动选择对应程序文件。

如果是 Windows，安装后在 `AppData/Roaming/npm` 目录会发现名为 `et` 的文件。

![image-20260405194137861](images/image-20260405194137861.png)



### 使用示例

截取屏幕。

```
 et screen capture --path a.png
```



![image-20260405194600430](images/image-20260405194600430.png)



<img src="images/d4ba9a4e7b88e26b30118b3c76f2dce5.jpg" alt="d4ba9a4e7b88e26b30118b3c76f2dce5" style="zoom: 25%;" />



### 作为 Skills 给 AI 使用（推荐）

只需要执行命令安装 skills 即可。

```bash
npx skills add https://github.com/whuanle/EasyTouch
```

> 注：skills 里面不带脚本，需提前安装当前平台包，第一次使用 AI 会自动安装，或者手动安装，例如 `npm i -g easytouch-windows`、`npm i -g easytouch-linux` 或 `npm i -g easytouch-macos`。



![image-20260224090411080](images/image-20260224090411080.png)



### 作为 MCP 工具使用

如果只是给 AI 工具使用，建议使用 skills 即可，配置 MCP 可能会麻烦一些。

在 Claude、Cursor、VS Code、Sidecar 等工具中，配置 MCP 的方式基本一致。通过 npm 安装后，推荐先执行包内 `init.js`，把当前操作系统和 CPU 对应的原生二进制复制成真正的 `et` 程序，然后让 MCP 直接调用这个原生文件。这样可以避免 `et.cmd`、`et.sh`、`npx.cmd` 这类桥接层。



在配置文件中添加：



**本地安装后（推荐）**

先执行：

```bash
npm i @whuanle/easytouch
npx @whuanle/easytouch init
```

如果安装的是 `@whuanle/easytouch`，这一步会先自动安装当前系统对应的平台包，再复制出原生 `et` 文件。

如果你已经在项目里安装了依赖，也可以直接执行 `node ./node_modules/@whuanle/easytouch/init.js`，但这只适用于本地安装目录。

执行后会生成：

- Windows：`./node_modules/@whuanle/easytouch/et.exe`
- Linux / macOS：`./node_modules/@whuanle/easytouch/et`

然后在 MCP 配置里直接指向这个原生文件：

```json
{
  "mcpServers": {
    "easytouch": {
      "command": "<你的项目路径>/node_modules/@whuanle/easytouch/et",
      "args": ["mcp-stdio"]
    }
  }
}
```

> Windows 请把文件名写成 `et.exe`。Linux / macOS 写 `et`。

**全局安装后**

如果你已经全局安装并且宿主能正确处理 PATH，也仍然可以直接使用全局 `et`。首次运行时，如果平台包还没装好，启动器也会自动补装当前平台包：

```bash
npm i -g @whuanle/easytouch
et init
```

生成完原生文件后，MCP 仍然可以直接使用全局 `et`：

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

如果你只是想手工执行脚本而不走 `et init`，需要先找到全局安装目录，例如：

```bash
npm root -g
```

然后再执行对应路径下的 `init.js`，而不是 `./node_modules/...`：

```bash
node <全局安装目录>/@whuanle/easytouch/init.js
```

**宿主程序不走 PATH 时（旧方式）**

- Windows：把 `command` 改成 `C:\\Users\\<你自己的用户名>\\AppData\\Roaming\\npm\\et.cmd`
- Linux / macOS：先执行 `npm prefix -g`，然后把 `command` 改成 `<prefix>/bin/et`

**不想初始化原生文件时（备用）**

如果你不想先执行 `init.js`，也可以临时通过 `npx` 启动。这里同样建议统一使用 `@whuanle/easytouch`，不要再按平台分别写包名。首次运行可能会多花一点时间，因为会自动安装当前平台包。

- Windows：`command` 推荐写 `npx.cmd`
- Linux / macOS：`command` 写 `npx`

```json
{
  "mcpServers": {
    "easytouch": {
      "command": "npx.cmd",
      "args": ["-y", "@whuanle/easytouch", "mcp-stdio"]
    }
  }
}
```

> 如果是在 Windows 的 GUI 程序中配置 MCP，直接用 `init.js` 生成的 `et.exe` 最稳。只有在走 `npx` 或全局 npm 命令时，才需要关心 `npx.cmd`、`et.cmd` 这些桥接文件；常见失败表现就是 `LOCAL_PROCESS_ERROR`。

Linux / macOS 如果使用这段备用配置，把 `command` 改回 `npx` 即可。

### 语义元素定位

当截图交给 AI 后，单靠图片反推点击坐标通常不够稳定。EasyTouch 现在支持先读取当前窗口的语义元素树，再按元素查找、等待、点击或 invoke：

```bash
et element tree --output json
et element find --name "确定" --control-type Button --output json
et wait element --name "保存" --control-type Button --timeout-ms 5000 --output json
et element click --element-id root/0/3 --output json
et element invoke --element-id root/0/3 --output json
```

说明：

- `element tree` 默认读取当前前台窗口，也可以通过 `--window-handle` 指定目标窗口。
- 返回结果里会包含 `element_id`、`control_type`、`automation_id`、`class_name`、`framework_id`、`center`、`bounds` 和 `children`，适合让 AI 像读 HTML DOM 一样选元素。
- `element find` 会基于 `element_id`、`name`、`automation_id`、`class_name`、`control_type`、`framework_id` 搜索元素树，并返回第一个匹配元素。
- `wait element` 会轮询元素树，直到匹配元素出现，适合弹窗、延迟渲染按钮、异步加载表单等场景。
- `element click` 会重新解析 `element_id`，激活目标窗口，再点击元素中心点，不需要 AI 自己从截图里估算坐标。
- `element invoke` 当前会走平台语义动作或元素中心点击回退，适合让模型统一表达“点这个控件”。
- 还可以用 `--max-depth`、`--max-children`、`--max-nodes` 控制树的规模，避免把过大的界面树一次性都送给模型。

平台说明：

- Windows：通过 UI Automation + PowerShell 工作。
- Linux：依赖 `python3` 或 `python` 能导入 `pyatspi`，点击回退依赖 `xdotool`，当前以 X11/XWayland 会话为主。
- macOS：依赖 `osascript` + System Events UI Scripting，宿主进程需要授予 Accessibility 和 Automation 权限。





### 平台说明

Windows

- 完全支持所有功能
- 部分功能可能需要管理员权限

Linux

- 官方验证环境：Ubuntu Desktop（22.04 / 24.04）
- 其他发行版和桌面环境为 best-effort，建议先用测试脚本验证
- 建议在图形界面环境中使用（优先 X11 会话）
- 有些功能可能需要 sudo 管理员权限

Linux 依赖可手动安装（Ubuntu）：

```bash
# 基础依赖（推荐）
sudo apt install xdotool xclip xsel imagemagick gnome-screenshot

# Wayland 补充依赖（按需）
sudo apt install ydotool wl-clipboard grim
```

安装后可执行脚本测试兼容性：

```bash
node scripts/test-easytouch.js --cli-only --verbose
```

macOS

- 需要授予辅助功能权限（系统设置 → 隐私与安全性 → 辅助功能）
- 截图功能需要屏幕录制权限



## 许可证

MIT License