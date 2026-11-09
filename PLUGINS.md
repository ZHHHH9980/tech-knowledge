# 插件安装

## everything-claude-code（ECC）

按[官方安装说明](https://github.com/affaan-m/ECC)安装；当前插件名为 `ecc@ecc`，安装后包含 agents。

```text
/plugin marketplace add https://github.com/affaan-m/ECC
/plugin install ecc@ecc
```

`rules/common` 需另行安装，在新机器获取官方仓库后保留整个目录：

```bash
git clone https://github.com/affaan-m/ECC.git
cd ECC
mkdir -p ~/.claude/rules/ecc
cp -R rules/common ~/.claude/rules/ecc/
```

## caveman

按[官方安装说明](https://github.com/JuliusBrussee/caveman/blob/main/INSTALL.md)，在 Claude Code 中执行：

```text
/plugin marketplace add JuliusBrussee/caveman
/plugin install caveman@caveman
```

## agentbridge

以下是[公开同名插件](https://github.com/raysonmeng/agent-bridge)的安装方式；未读取本机插件配置，恢复前需核对是否为原安装来源。先安装 Bun，再在 Claude Code 中执行：

```text
/plugin marketplace add raysonmeng/agent-bridge
/plugin install agentbridge@agentbridge
/reload-plugins
```

## rtk

按[官方安装说明](https://github.com/rtk-ai/rtk/blob/develop/docs/guide/getting-started/installation.md)，在 macOS 安装后运行初始化，生成 RTK.md 并配置 hook：

```bash
brew install rtk-ai/tap/rtk
rtk init
```
