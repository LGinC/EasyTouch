# EasyTouch Skills 目录说明

本目录用于存放 Skill 侧文档，重点是 Agent 接入和能力边界，不重复讲项目背景。

## 文档导航

- [skills/SKILL.md](SKILL.md): 能力矩阵、平台完成度、参数约定、最小接入集合
- [SKILL.md](../SKILL.md): 根级 Skill 说明，面向接入方的完整约束与工作流建议
- [README.md](../README.md): 项目总览与 CLI 快速开始

## 维护约定

- 新增能力时，先更新源码 capability registry，再同步更新 skills/SKILL.md
- 发布前用 et mcp-stdio --output json 校验工具清单与文档一致
- 若平台 phase 变化，优先更新 skills/SKILL.md 的平台完成度说明
