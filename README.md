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

推荐安装带初始化 helper 的聚合包；如果你只想安装当前系统，也可以直接安装对应平台包：

```bash
# 推荐：聚合包，执行 easytouch init 生成 et
npm i -g @whuanle/easytouch

# 只安装当前系统的平台包
npm i -g easytouch-windows
npm i -g easytouch-linux
npm i -g easytouch-macos
```

`@whuanle/easytouch` 会在包内直接附带 Windows、Linux、macOS 的 x64 和 arm64 原生二进制。执行 `easytouch init` 后，会按当前主机平台和 CPU 架构复制出真正可直接调用的 `et` 文件。

初始化命令：

```bash
# 聚合包
easytouch init

# 只安装当前系统的平台包时
easytouch-windows init
easytouch-linux init
easytouch-macos init
```

`init` 默认会把原生文件写回安装包目录，并同步刷新 `et` 命令入口。



### 使用示例

以下示例假设你已经通过 `init` 生成好了原生 `et`：

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



**全局安装后（推荐）**

如果你已经全局安装了聚合包，可以直接使用 helper 命令生成原生 `et`：

```bash
npm i -g @whuanle/easytouch
easytouch init
```

默认会把 `et` 生成到全局安装目录下的包目录里，并同步刷新全局 `et` 命令。

默认路径通常是：

- Windows：`<npm root -g>/@whuanle/easytouch/et.exe`
- Linux / macOS：`<npm root -g>/@whuanle/easytouch/et`

全局命令入口通常是：

- Windows：`<npm prefix -g>/et.cmd`
- Linux / macOS：`<npm prefix -g>/bin/et`

如果需要查看你自己机器上的真实路径，可以执行：

```bash
npm root -g
npm prefix -g
```

也可以显式指定输出位置：

```bash
easytouch init --output <你想放置 et 的路径>
```

如果你安装的是平台包，初始化命令分别是 `easytouch-windows init`、`easytouch-linux init`、`easytouch-macos init`。

生成完原生文件后，MCP 直接调用这个文件即可：

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

如果宿主程序不走 PATH，再改成 `npm prefix -g` 或 `npm root -g` 对应的实际路径。

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