# Mod2：Capricorn 原模组 + AI API / 中文互动扩展

控制面板、小聊天窗口及扩展提示跟随游戏界面语言：简体中文、繁体中文、其他语言英文回退。
AI 请求包含当前游戏语言；原 Capricorn 预设剧情台词/语音保留原版本。
启动 API 使用 `StartAIBridge.cmd`，配置位于 `AIBridge/config.json`。

## 快捷聊天窗口（已安装更新）

重启游戏后，关闭 CET 覆盖层，在正常游玩时按 **F10** 打开右侧小聊天窗。
输入消息后点“发送”，按 **Esc / F10** 关闭。窗口包含聊聊、治疗、奇美拉指令按钮。
改键位置：CET → Bindings → CapricornRelic → **Toggle chat window / 打开关闭聊天**。
这次增加了 redscript 文件，必须重启游戏一次；仅 Reload all mods 不足以加载新界面。

按最终要求，以下载的 Capricorn 包为基础，仅增加 API 与互动扩展。

## 安装

双击 `Install.cmd`，或者将 `GameRoot` 中的文件夹复制进GameRoot：

`D:\steam\steamapps\common\Cyberpunk 2077`

已封装前置：CET、RED4ext、redscript 0.5.32、Codeware、ArchiveXL、TweakXL、Audioware、Input Loader、Mod Settings。
不需要 CDPR 账号。

## 离线使用

- CET 面板中打开 **摩羯 / CAPRICORN · RELIC**。
- 可以聊聊、治疗、使用黑客指令、领取原模组的 Capricorn 接入仓。
- 人物：短路、过热、义眼重启、义体失灵、武器故障、记忆清除、赛博精神病、黑墙。
- 车辆：制动、加速、接管、自毁。目标是当前准星所指的实体。
- 额外指令通过脚本直接调用效果，不耗 RAM；特殊任务实体仍可能受引擎自身免疫逻辑影响。
- 战斗开始、结束、低血量都有额外中文回应。
- 安装 Mod1 后可说“召唤奇美拉”“跟随”“警戒”“摧毁目标”“停火”“召回”。
- 推荐在 CET → Bindings 为黑墙、治疗等绑定按键。
- 原模组的任务、接入仓、600 多条预设台词与已有语音保留；原模组自身的互动仍按其装备条件触发。

全新安装已预设中文字体。已有 CET 配置会保留；若显示方框，可将 CET 的 `config.json` 中 `font.language` 改为 `ChineseFull`、`font.path` 改为 `C:/Windows/Fonts/simhei.ttf`，保存后重启游戏。

## AI API

1. 双击本包 `StartAIBridge.cmd`。已带便携 Python，不需要另外安装。
2. 本地配置页会打开，填写游戏位置、API Base URL、模型名和 Key，保存并测试连接。
3. 接口需兼容 OpenAI `/v1/chat/completions`。
   - LM Studio：一般为 `http://127.0.0.1:1234/v1`
   - Ollama 兼容接口：一般为 `http://127.0.0.1:11434/v1`
   - 在线服务：使用该服务提供的 Base URL 和模型 ID。
4. 在游戏摩羯面板中勾选“启用外部 AI API”。
5. 保持桥接器窗口运行；关闭后仍能取消 API 开关使用离线互动。

Key 保存在本包 `AIBridge/config.json`，也支持 `CAPRICORN_API_KEY` 环境变量。
API 模式会把输入对话和少量游戏状态发给所配置的服务；不自动读取其他个人文件。
API 出错/超时会回退离线提示。AI 只能选择固定游戏动作，不能执行 Lua、Python 或电脑命令。

## 来源与检查

- 基础内容来自 ModDB 的 Project Capricorn 下载包，页面对应 Nexus 36701 的介绍。
- ModDB 上传账号与 Nexus 作者名不同，因此不能认定为 Nexus 1.2 的官方同版本包。
- 基础 Lua、redscript、YAML、archive 内容保留；仅附加独立扩展。下载包内不相关的车辆 DLL/音效和 sqlite 数据库未纳入。
- 所有 redscript 与本机 2.5 原始脚本及依赖一起编译通过；LuaJIT 语法通过。
- API 请求、动作白名单、禁止动作模式、纯文本回复和错误处理共 5 项测试通过。
- 没有你的 API Key，因此没有连接真实收费 AI 服务；使用兼容的本地测试服务验证请求链路。
- 最后按用户要求简化后，未再次运行游戏验证 UI。

## 卸载

先卸下 Capricorn 接入仓和自定义快速破解，保存并退出，运行 `Uninstall.cmd`。
共享前置和修改过的用户设置保留。
