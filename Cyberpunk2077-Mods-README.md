# Cyberpunk 2077: Chimera, Capricorn & Basilisk

**By astra** · [English](#english) · [简体中文](#简体中文)

## English

For **Cyberpunk 2077 2.5 + Phantom Liberty on Windows**. Uses manually installed mods; no CDPR account, built-in mod platform, or Steam Workshop required.

Controls follow the **game's interface language**: Simplified Chinese, Traditional Chinese, or English fallback for other languages. This covers buttons, status messages, and the compact chat window. Reopen the panel after changing language; binding descriptions refresh after restarting or using **Reload all mods**. AI replies are requested in the current game language. The original Capricorn scripted dialogue and recorded voices retain their original languages.

### Features

| Package | Features |
|---|---|
| **Mod1_ChimeraCommands** | Deploys the actual Chimera NPC using native models, weapons, combat AI, and health scaling. Follow, guard, attack a designated target, cease fire, and recall. |
| **Mod2_CapricornAI** | Extends the existing Capricorn mod with offline interactions, optional AI chat, a compact chat UI, NPC/vehicle hacking commands, and Chimera coordination. |
| **Mod3_Basilisk** | Adds the native Basilisk to the vehicle call list, with deployment, driver-seat boarding, driving, and recall. Compatible with the other two packages. |

**Chimera works independently of Capricorn.** Install Mod1 with its bundled prerequisites and use its own panel or hotkeys. Capricorn adds an optional conversational control route.

The Capricorn extension includes healing, Short Circuit, Overheat, Blackwall, and vehicle braking, acceleration, takeover, and self-destruct commands. Extra hacking commands apply game effects directly without consuming RAM. Offline chat uses preset responses; free-form AI conversation requires an API connection.

This version does not replace Johnny's model or add free-flight altitude controls to the Basilisk.

### Installation

1. Close the game. Merge the folders **inside each package's `GameRoot`** into your `Cyberpunk 2077` installation directory.
2. Alternatively, run `Install.cmd`. Its default game path is `D:\steam\steamapps\common\Cyberpunk 2077`. For another location:
   ```powershell
   powershell -NoProfile -ExecutionPolicy Bypass -File .\install.ps1 -GameDir "X:\Games\Cyberpunk 2077"
   ```
3. Launch the game, assign a **Cyber Engine Tweaks (CET)** overlay key—`~` is suggested—and load a save.

Required frameworks are bundled. The installer reuses identical dependencies. Mods are installed as additional files without replacing the original game EXE, resource archives, or original script bundle.

### Usage

**Chimera and Basilisk:** open CET while standing in a large outdoor area.

- **CHIMERA | Command Platform:** use `Deploy CHIMERA`, `FOLLOW V`, `GUARD HERE`, `DESTROY CROSSHAIR TARGET`, `STOP / HOLD`, and `Recall`.
- **BASILISK | Private Hangar:** deploy, then enter normally or use `Board Basilisk` within 35 metres. Exit before recalling. Driving and weapons use the game's Basilisk controls.
- Both appear in the standard vehicle call list, opened by holding `V` with default bindings. Redeploy after loading a save.
- Configure hotkeys under **CET → Bindings → HangarTanks / HGBasilisk**. For targeted attacks, aim first and press the assigned hotkey.

**Capricorn chat:**

1. Under **CET → Bindings → CapricornRelic**, bind **Toggle chat window**. `F10` is suggested and configured on the original local installation.
2. Close the CET overlay and press the chat key during gameplay. A compact window opens on the right.
3. Type a message and click **Send**, or use **Chat / Heal / Follow / Guard / Cease fire / Recall**. Close with `Esc`, the chat key, or **Close**.

Offline command examples: `heal`, `short circuit`, `overheat`, `blackwall`, `brake`, `deploy chimera`, and `attack target`. Text can also be pasted with `Ctrl+V`.

The full skill controls and settings are in the CET **CAPRICORN | Relic** panel. Use **Get Capricorn deck**, then equip it at a ripperdoc to access the base mod's equipment-dependent dialogue and interactions.

**Optional AI API:**

1. Run Mod2's `StartAIBridge.cmd` to open the local configuration page.
2. Enter the game directory, OpenAI-compatible **Base URL**, model ID, and API key. Save and test the connection.
3. Enable **AI API** in the in-game Capricorn panel. Enable **Allow AI game actions** if you want the model to issue commands.

The bridge supports `/v1/chat/completions`, including LM Studio at `http://127.0.0.1:1234/v1` and Ollama at `http://127.0.0.1:11434/v1`. Keep the bridge running; portable Python is included.

API mode sends your conversation and brief game context to the configured service. Keys are stored in `AIBridge/config.json`; **exclude that file when uploading to GitHub**. AI output can select predefined game actions, not execute computer commands.

### References and credits

- **CD Projekt Red:** original Basilisk, Chimera, weapons, effects, and game scripting interfaces.
- **[Project Capricorn / Nexus 36701](https://www.nexusmods.com/cyberpunk2077/mods/36701)** by **ARandomSomeone22:** base cyberdeck, scripted interactions, and associated assets. The reused package came from [ModDB](https://www.moddb.com/mods/capricorn-your-ai-powered-cyberdeck/addons/project-capricorn), uploaded by **giralon657**; exact equivalence to Nexus version 1.2 has not been established.
- **[Cyber Engine Tweaks](https://github.com/maximegmd/CyberEngineTweaks)**, **[RED4ext](https://github.com/WopsS/RED4ext)**, and **[redscript](https://github.com/jac3km4/redscript):** loading and scripting support.
- **psiberx's [Codeware](https://github.com/psiberx/cp2077-codeware)**, **[TweakXL](https://github.com/psiberx/cp2077-tweak-xl)**, and **[ArchiveXL](https://github.com/psiberx/cp2077-archive-xl):** entity spawning, native UI, database, and resource extensions.
- **[Audioware](https://github.com/cyb3rpsych0s1s/audioware)**, **[Input Loader](https://github.com/jackhumbert/cyberpunk2077-input-loader)**, and **[Mod Settings](https://github.com/jackhumbert/mod_settings):** audio, input, and settings support.
- **[WolvenKit](https://github.com/WolvenKit/WolvenKit)** and **[REDmodding Wiki](https://wiki.redmodding.org/):** resource inspection tools and documentation.

astra implemented the additional command logic, independent Basilisk compatibility, localized interactions, chat UI, API bridge, and installation packaging. Third-party code and assets retain their original authorship and licenses. Flying Tank / Nexus 16138 was not downloaded or integrated.

### Validation and removal

The three mods compile together; Lua and API bridge checks passed offline. Earlier builds were tested for Basilisk driving and Chimera spawning, movement, and native AI attacks. The final chat UI, complete command lifecycle, and combat phase transitions have not received comprehensive in-game regression testing.

Large units may encounter navigation limits on narrow roads, and quest targets may retain engine-level immunity. To uninstall, recall vehicles, remove their garage entries, unequip the Capricorn deck and custom quickhacks, save, and exit. Run each package's `Uninstall.cmd`.

---

## 简体中文

**制作与整合：astra**

适用于 Windows《赛博朋克 2077》2.5 +《往日之影》。采用手动模组目录加载，无需 CDPR 账号、内置模组平台或 Steam 创意工坊。

控制界面跟随**游戏界面语言**：支持简体中文、繁体中文，其他语言使用英文回退。包括按钮、状态提示和小聊天窗口；更改语言后重新打开面板即可，绑定列表标签可在重启或 Reload all mods 后刷新。AI 回复按当前游戏语言请求，原 Capricorn 预设剧情台词和语音保留原版本。

三个安装目录为 `Mod1_ChimeraCommands`、`Mod2_CapricornAI`、`Mod3_Basilisk`；载荷目录为 `GameRoot`，入口为 `Install.cmd`、`Uninstall.cmd`、`StartAIBridge.cmd`。
**奇美拉完全支持独立使用**：只安装 Mod1 及其包内前置即可，面板和快捷键不依赖摩羯；摩羯只提供额外聊天协同。

### 功能

| 模组 | 效果 |
|---|---|
| **Mod1 · 奇美拉指令平台** | 部署真正的奇美拉 NPC，复用原版模型、武器、战斗 AI 和血量计算；支持跟随、警戒、攻击指定目标、停火、召回。 |
| **Mod2 · 摩羯 API 与互动** | 基于现成 Capricorn 模组，增加跟随语言设置的离线互动、可选 AI 对话、简洁聊天窗口、人物/车辆黑客指令及奇美拉协同。 |
| **Mod3 · 魔蜥独立兼容版** | 将原版魔蜥加入载具呼叫列表，支持部署、进入驾驶位、驾驶及召回，可与另外两模组共存。 |

摩羯扩展提供治疗、短路、过热、黑墙，以及车辆制动、加速、接管和自毁等指令。额外技能直接调用游戏效果，不消耗 RAM。离线聊天使用预设回应；自由 AI 对话需要配置接口。

当前版本没有强尼模型替换，也没有为魔蜥增加自由升降飞行。

### 安装

1. 退出游戏，将各包中 **`GameRoot` 内的文件夹**合并到 `Cyberpunk 2077` 安装目录。
2. 也可运行包内 `Install.cmd`；其默认路径为 `D:\steam\steamapps\common\Cyberpunk 2077`。其他位置可运行：
   ```powershell
   powershell -NoProfile -ExecutionPolicy Bypass -File .\install.ps1 -GameDir "X:\Games\Cyberpunk 2077"
   ```
3. 启动游戏，首次为 **Cyber Engine Tweaks（CET）**设置面板键，推荐 `~`，随后加载存档。

安装包已封装所需前置，安装脚本会复用内容相同的依赖。模组以附加文件加载，不替换游戏原版 EXE、资源归档或原始脚本包。

### 使用

#### 奇美拉与魔蜥

在室外开阔地打开 CET：

- **CHIMERA | Command Platform**：`Deploy CHIMERA` 召唤；`FOLLOW V` 跟随；`GUARD HERE` 警戒；`DESTROY CROSSHAIR TARGET` 攻击准星目标；`STOP / HOLD` 停火；`Recall` 召回。
- **魔蜥 / BASILISK · 私人仓库**：点击“部署魔蜥”，靠近后上车，或在 35 米内点击“进入驾驶位”；下车后可以召回。驾驶与武器沿用游戏键位。
- 两者会加入普通载具呼叫列表，默认长按 `V` 打开。读档后可重新部署。
- 在 **CET → Bindings → HangarTanks / HGBasilisk** 设置指令快捷键。攻击建议绑定按键，瞄准目标后直接按下。

#### 摩羯聊天

1. 在 **CET → Bindings → CapricornRelic** 绑定 **`Toggle chat window / 打开关闭聊天`**，推荐 `F10`；当前本机已配置为 F10。
2. 关闭 CET 覆盖层，正常游玩时按聊天键，右侧显示小型聊天窗口。
3. 输入消息后点“发送”，或点击“聊聊 / 治疗 / 跟随 / 警戒 / 停火 / 召回”。按 `Esc`、聊天键或“关闭”退出。

离线可输入：`治疗`、`短路`、`过热`、`黑墙`、`刹车`、`召唤奇美拉`、`摧毁目标`等。中文输入不便时可用 `Ctrl+V` 粘贴。

完整技能与设置位于 CET 的 **摩羯 / CAPRICORN · RELIC** 面板。领取 Capricorn 接入仓后，可去义体医生处装备，使用基础模组原有台词、语音及互动。

#### 可选 AI API

1. 运行 Mod2 中的 **`StartAIBridge.cmd`**，打开本地配置页。
2. 填写游戏目录、OpenAI 兼容 **Base URL**、模型 ID、API Key，保存并测试连接。
3. 游戏摩羯面板勾选“启用外部 AI API”；需要 AI 执行技能时启用“允许 AI 调用游戏指令”。

支持 `/v1/chat/completions`；例如 LM Studio 的 `http://127.0.0.1:1234/v1`、Ollama 的 `http://127.0.0.1:11434/v1`。桥接器需保持运行，已附便携 Python。

API 模式会发送对话与简要游戏状态。Key 保存在 `AIBridge/config.json`，**上传 GitHub 时排除此文件**。AI 仅能选择预定义游戏动作，不能执行电脑命令。

### 参考与致谢

- **CD Projekt Red**：游戏原版魔蜥、奇美拉、武器、效果和脚本接口。
- **[Project Capricorn / Nexus 36701](https://www.nexusmods.com/cyberpunk2077/mods/36701)**，作者 **ARandomSomeone22**：基础接入仓、预设互动及相关素材。实际复用包下载自 [ModDB](https://www.moddb.com/mods/capricorn-your-ai-powered-cyberdeck/addons/project-capricorn)，上传者 **giralon657**；未确认与 Nexus 1.2 完全一致。
- **[Cyber Engine Tweaks](https://github.com/maximegmd/CyberEngineTweaks)**、**[RED4ext](https://github.com/WopsS/RED4ext)**、**[redscript](https://github.com/jac3km4/redscript)**：加载、Lua 与脚本扩展。
- **psiberx** 的 **[Codeware](https://github.com/psiberx/cp2077-codeware)**、**[TweakXL](https://github.com/psiberx/cp2077-tweak-xl)**、**[ArchiveXL](https://github.com/psiberx/cp2077-archive-xl)**：实体生成、原生 UI、数据库和资源扩展。
- **[Audioware](https://github.com/cyb3rpsych0s1s/audioware)**、**[Input Loader](https://github.com/jackhumbert/cyberpunk2077-input-loader)**、**[Mod Settings](https://github.com/jackhumbert/mod_settings)**：音频、输入和设置支持。
- **[WolvenKit](https://github.com/WolvenKit/WolvenKit)** 与 **[REDmodding Wiki](https://wiki.redmodding.org/)**：资源检查工具及接口文档。

astra 负责新增指令逻辑、独立魔蜥兼容、多语言互动、聊天 UI、API 桥接和安装封装。第三方代码与素材保留原作者署名及许可证。Nexus 16138 的 Flying Tank 未下载或集成。

### 状态与卸载

三个模组已联合编译通过，Lua 与 API 桥接经过离线检查；早期版本实测过魔蜥驾驶、奇美拉生成、移动及原生 AI 攻击。最终聊天 UI、完整指令循环和战斗阶段尚未全面实机回归。

大型单位可能受狭窄道路寻路限制，剧情目标可能保留引擎免疫。卸载前召回载具、移除车库条目、卸下 Capricorn 接入仓及自定义快速破解，保存退出后运行各包的 `Uninstall.cmd`。
