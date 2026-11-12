import Codeware.Localization.*

public abstract class HGText {
  public static func Language() -> CName {
    let system = LocalizationSystem.GetInstance(GetGameInstance());
    return IsDefined(system) ? system.GetInterfaceLanguage() : n"en-us";
  }
  public static func Text(value: String) -> String {
    let language = HGText.Language();
    let traditional = Equals(language,n"zh-tw");
    let chinese = traditional || Equals(language,n"zh-cn");
    switch value {
      case "Recall": return chinese ? (traditional ? "召回" : "召回") : "Recall";
      case "Register garage": return chinese ? (traditional ? "加入車庫" : "加入车库") : "Register garage";
      case "Remove entries": return chinese ? (traditional ? "移除車庫條目" : "移除车库条目") : "Remove entries";
      case "Load a save first.": return chinese ? (traditional ? "先加載存檔。" : "先加载存档。") : "Load a save first.";
      case "Unavailable": return chinese ? (traditional ? "暫不可用" : "暂不可用") : "Unavailable";
      case "Scripts unavailable: check r6/logs/redscript_rCURRENT.log": return chinese ? (traditional ? "腳本未就緒，請查看 r6/logs/redscript_rCURRENT.log。" : "脚本未就绪，请查看 r6/logs/redscript_rCURRENT.log。") : "Scripts unavailable: check r6/logs/redscript_rCURRENT.log";
      case "Error: ": return chinese ? (traditional ? "錯誤：" : "错误：") : "Error: ";
      case "CHIMERA | Command Platform": return chinese ? (traditional ? "奇美拉 · 指令平臺" : "奇美拉 · 指令平台") : "CHIMERA | Command Platform";
      case "Chimera appears in V's normal vehicle call list. Deploy on open outdoor ground. Uses native boss AI, weapons and health scaling.": return chinese ? (traditional ? "奇美拉會加入普通載具呼叫列表。請在室外開闊地部署，使用原版戰斗 AI、武器和血量計算。" : "奇美拉会加入普通载具呼叫列表。请在室外开阔地部署，使用原版战斗 AI、武器和血量计算。") : "Chimera appears in V's normal vehicle call list. Deploy on open outdoor ground. Uses native boss AI, weapons and health scaling.";
      case "Deploy CHIMERA": return chinese ? (traditional ? "部署奇美拉" : "部署奇美拉") : "Deploy CHIMERA";
      case "Recall Chimera": return chinese ? (traditional ? "召回奇美拉" : "召回奇美拉") : "Recall Chimera";
      case "FOLLOW V": return chinese ? (traditional ? "跟隨 V" : "跟随 V") : "FOLLOW V";
      case "GUARD HERE": return chinese ? (traditional ? "原地警戒" : "原地警戒") : "GUARD HERE";
      case "STOP / HOLD": return chinese ? (traditional ? "停火待命" : "停火待命") : "STOP / HOLD";
      case "DESTROY CROSSHAIR TARGET": return chinese ? (traditional ? "摧毀準星目標" : "摧毁准星目标") : "DESTROY CROSSHAIR TARGET";
      case "For Attack, bind a hotkey in CET > Bindings. Aim at an NPC or vehicle, then press it. Guard defends a 60 m area; Follow keeps about 12 m behind V.": return chinese ? (traditional ? "攻擊建議在 CET → Bindings 中綁定快捷鍵，瞄準人物或車輛后按下。警戒范圍約 60 米，跟隨距離約 12 米。" : "攻击建议在 CET → Bindings 中绑定快捷键，瞄准人物或车辆后按下。警戒范围约 60 米，跟随距离约 12 米。") : "For Attack, bind a hotkey in CET > Bindings. Aim at an NPC or vehicle, then press it. Guard defends a 60 m area; Follow keeps about 12 m behind V.";
      case "Auto-register Chimera in garage": return chinese ? (traditional ? "自動將奇美拉加入車庫" : "自动将奇美拉加入车库") : "Auto-register Chimera in garage";
      case "\nChimera health: %.0f (%.1f%%)": return chinese ? (traditional ? "\n奇美拉生命值：%.0f（%.1f%%）" : "\n奇美拉生命值：%.0f（%.1f%%）") : "\nChimera health: %.0f (%.1f%%)";
      case "Hangar: deploy Chimera": return chinese ? (traditional ? "奇美拉：部署" : "奇美拉：部署") : "Hangar: deploy Chimera";
      case "Chimera: follow V": return chinese ? (traditional ? "奇美拉：跟隨 V" : "奇美拉：跟随 V") : "Chimera: follow V";
      case "Chimera: guard position": return chinese ? (traditional ? "奇美拉：原地警戒" : "奇美拉：原地警戒") : "Chimera: guard position";
      case "Chimera: destroy crosshair target": return chinese ? (traditional ? "奇美拉：攻擊準星目標" : "奇美拉：攻击准星目标") : "Chimera: destroy crosshair target";
      case "Chimera: cease fire / hold": return chinese ? (traditional ? "奇美拉：停火待命" : "奇美拉：停火待命") : "Chimera: cease fire / hold";
      case "Chimera: recall": return chinese ? (traditional ? "奇美拉：召回" : "奇美拉：召回") : "Chimera: recall";
      case "Garage entries removed. Disable automatic registration in the hangar settings to keep them removed.": return chinese ? (traditional ? "已移除車庫條目。關閉自動加入車庫可保持移除狀態。" : "已移除车库条目。关闭自动加入车库可保持移除状态。") : "Garage entries removed. Disable automatic registration in the hangar settings to keep them removed.";
      case "Basilisk is provided separately by Flying Tank (Nexus 16138).": return chinese ? (traditional ? "魔蜥由獨立的 Mod3_Basilisk 提供。" : "魔蜥由独立的 Mod3_Basilisk 提供。") : "Basilisk is provided separately by Flying Tank (Nexus 16138).";
      case "Load a save and return to gameplay first.": return chinese ? (traditional ? "請先加載存檔并回到游戲。" : "请先加载存档并回到游戏。") : "Load a save and return to gameplay first.";
      case "Wait for the current deployment to finish.": return chinese ? (traditional ? "請等待當前部署完成。" : "请等待当前部署完成。") : "Wait for the current deployment to finish.";
      case "Exit the vehicle first.": return chinese ? (traditional ? "請先下車。" : "请先下车。") : "Exit the vehicle first.";
      case "Finish the current scene first.": return chinese ? (traditional ? "請先完成當前劇情。" : "请先完成当前剧情。") : "Finish the current scene first.";
      case "Deploy outdoors in a large open area.": return chinese ? (traditional ? "請在室外開闊地部署。" : "请在室外开阔地部署。") : "Deploy outdoors in a large open area.";
      case "No ground found ahead. Face a clear level surface.": return chinese ? (traditional ? "前方沒有可用地面，請面向開闊平地。" : "前方没有可用地面，请面向开阔平地。") : "No ground found ahead. Face a clear level surface.";
      case "Deployment requested...": return chinese ? (traditional ? "已請求部署…" : "已请求部署…") : "Deployment requested...";
      case "Recalled.": return chinese ? (traditional ? "已召回。" : "已召回。") : "Recalled.";
      case "Deploy a live Chimera first.": return chinese ? (traditional ? "請先部署存活的奇美拉。" : "请先部署存活的奇美拉。") : "Deploy a live Chimera first.";
      case "CHIMERA: cease fire / hold position.": return chinese ? (traditional ? "奇美拉：停火，原地待命。" : "奇美拉：停火，原地待命。") : "CHIMERA: cease fire / hold position.";
      case "CHIMERA: follow V, defend against nearby hostiles.": return chinese ? (traditional ? "奇美拉：跟隨 V，迎擊附近敵人。" : "奇美拉：跟随 V，迎击附近敌人。") : "CHIMERA: follow V, defend against nearby hostiles.";
      case "CHIMERA: guard this position (60 m).": return chinese ? (traditional ? "奇美拉：警戒當前位置（60 米）。" : "奇美拉：警戒当前位置（60 米）。") : "CHIMERA: guard this position (60 m).";
      case "Aim at a living NPC or vehicle, then issue Attack.": return chinese ? (traditional ? "請瞄準存活人物或車輛，再發出攻擊指令。" : "请瞄准存活人物或车辆，再发出攻击指令。") : "Aim at a living NPC or vehicle, then issue Attack.";
      case "Target beyond 180 m command range.": return chinese ? (traditional ? "目標超出 180 米指令范圍。" : "目标超出 180 米指令范围。") : "Target beyond 180 m command range.";
      case "CHIMERA: destroy designated target.": return chinese ? (traditional ? "奇美拉：摧毀指定目標。" : "奇美拉：摧毁指定目标。") : "CHIMERA: destroy designated target.";
      case "Chimera deployed. Awaiting orders.": return chinese ? (traditional ? "奇美拉部署完成，等待指令。" : "奇美拉部署完成，等待指令。") : "Chimera deployed. Awaiting orders.";
      case "Spawn timed out. Move to open ground, retry.": return chinese ? (traditional ? "生成超時，請移至開闊地重試。" : "生成超时，请移至开阔地重试。") : "Spawn timed out. Move to open ground, retry.";
      case "CHIMERA: disabled.": return chinese ? (traditional ? "奇美拉：已失去作戰能力。" : "奇美拉：已失去作战能力。") : "CHIMERA: disabled.";
      case "CHIMERA: target unloaded; holding position.": return chinese ? (traditional ? "奇美拉：目標已離開加載范圍，原地待命。" : "奇美拉：目标已离开加载范围，原地待命。") : "CHIMERA: target unloaded; holding position.";
      case "CHIMERA: target neutralized or disengaged.": return chinese ? (traditional ? "奇美拉：目標已消滅或脫離接戰。" : "奇美拉：目标已消灭或脱离接战。") : "CHIMERA: target neutralized or disengaged.";
      default: return value;
    }
  }
}
