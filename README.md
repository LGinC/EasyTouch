# EasyTouch

跨平台系统自动化操作工具，支持 Windows、Linux、macOS。提供 CLI 命令行和 MCP 服务器两种使用方式，支持鼠标键盘控制、屏幕截图、窗口管理、系统信息查询等功能。

目前：

- [x] Windows

- [x] Linux
- [ ] MAC（目前缺少设备验证功能）

大家平时使用各类 AI 编程工具，写页面是不是经常碰到 AI 写的页面怎么也不满意，写出来跟设计稿差异很大，这是因为 AI 只能通过读写代码来改进代码，它看不到界面，不像人类有感官。

所以 EasyTouch 是给 AI 装上手和眼睛。



**你能用它做什么？**

- 系统信息：系统、CPU、内存、磁盘、进程
- 屏幕能力：显示器枚举、像素取色、截图
- 窗口控制：枚举、查找、激活、关闭、前台窗口读取
- 输入控制：鼠标移动/点击/滚轮，键盘按键/组合键/输入/粘贴
- 剪贴板：读文本、写文本、读文件列表
- 等待器：等待窗口、焦点、像素、剪贴板、进程状态
- 应用启动：按路径或 URI 启动目标



### 安装

按照操作系统安装，安装命令：

```
# Windows
npm i  -g easytouch-windows

# Linux
npm i  -g easytouch-linux

# macOS
npm i -g easytouch-mac
```



### 使用示例





### 作为 Skills 给 AI 使用

只需要执行命令安装 skills 即可。

```bash
npx skills add https://github.com/whuanle/EasyTouch
```



注：skills 里面不带脚本，需提前使用 `npm i easytouch-windows` 安装工具。

![image-20260224090411080](images/image-20260224090411080.png)



### 作为 MCP 工具使用

如果只是给 AI 工具使用，建议使用 skills 即可，配置 MCP 可能会麻烦一些。

在 Claude、Cursor 等工具中，配置 MCP 的方式都是大同小异，通过 npm/bun 等方式安装的 EasyTouch，程序文件在 `$basedir/node_modules/easytouch-windows` 下面，。



在配置文件中添加：

**Windows**

```json
{
  "mcpServers": {
    "easytouch": {
      "command": "C:\\path\\to\\et.exe",
      "args": ["--mcp"]
    }
  }
}
```

**NPM 安装方式**

```json
{
  "mcpServers": {
    "easytouch": {
      "command": "npx",
      "args": ["-y", "easytouch-windows", "--mcp"]
    }
  }
}
```

**Linux / macOS**

```json
{
  "mcpServers": {
    "easytouch": {
      "command": "/path/to/et",
      "args": ["--mcp"]
    }
  }
}
```





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