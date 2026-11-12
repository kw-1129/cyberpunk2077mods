import Codeware.Localization.*

public abstract class HGBText {
  public static func Language() -> CName {
    let system = LocalizationSystem.GetInstance(GetGameInstance());
    return IsDefined(system) ? system.GetInterfaceLanguage() : n"en-us";
  }
  public static func Text(value: String) -> String {
    let language = HGBText.Language();
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
      case "魔蜥 / BASILISK · 私人仓库": return chinese ? (traditional ? "魔蜥 / BASILISK · 私人倉庫" : "魔蜥 / BASILISK · 私人仓库") : "BASILISK | Private Hangar";
      case "在室外开阔地部署。魔蜥会加入普通呼叫载具列表。": return chinese ? (traditional ? "在室外開闊地部署。魔蜥會加入普通呼叫載具列表。" : "在室外开阔地部署。魔蜥会加入普通呼叫载具列表。") : "Deploy on open outdoor ground. Basilisk appears in the normal vehicle call list.";
      case "部署魔蜥 / Deploy": return chinese ? (traditional ? "部署魔蜥 / Deploy" : "部署魔蜥 / Deploy") : "Deploy Basilisk";
      case "进入驾驶位 / Board": return chinese ? (traditional ? "進入駕駛位 / Board" : "进入驾驶位 / Board") : "Board Basilisk";
      case "召回 / Recall": return chinese ? (traditional ? "召回 / Recall" : "召回 / Recall") : "Recall";
      case "驾驶、瞄准及武器沿用游戏魔蜥键位。靠近后可正常进入，也可点“进入驾驶位”。召回前先下车。": return chinese ? (traditional ? "駕駛、瞄準及武器沿用游戲魔蜥鍵位。靠近后可正常進入，也可點“進入駕駛位”。召回前先下車。" : "驾驶、瞄准及武器沿用游戏魔蜥键位。靠近后可正常进入，也可点“进入驾驶位”。召回前先下车。") : "Use the standard Basilisk driving, aiming and weapon controls. Enter normally or use Board. Exit before recall.";
      case "加入车库": return chinese ? (traditional ? "加入車庫" : "加入车库") : "Register garage";
      case "移除车库条目": return chinese ? (traditional ? "移除車庫條目" : "移除车库条目") : "Remove garage entry";
      case "先加载存档。": return chinese ? (traditional ? "先加載存檔。" : "先加载存档。") : "Load a save first.";
      case "脚本未就绪，请查看 redscript 日志。": return chinese ? (traditional ? "腳本未就緒，請查看 redscript 日志。" : "脚本未就绪，请查看 redscript 日志。") : "Scripts unavailable: check the redscript log.";
      case "Basilisk: deploy": return chinese ? (traditional ? "魔蜥：部署" : "魔蜥：部署") : "Basilisk: deploy";
      case "Basilisk: board driver seat": return chinese ? (traditional ? "魔蜥：進入駕駛位" : "魔蜥：进入驾驶位") : "Basilisk: board driver seat";
      case "Basilisk: recall": return chinese ? (traditional ? "魔蜥：召回" : "魔蜥：召回") : "Basilisk: recall";
      case "Basilisk registered in the vehicle call list.": return chinese ? (traditional ? "魔蜥已加入載具呼叫列表。" : "魔蜥已加入载具呼叫列表。") : "Basilisk registered in the vehicle call list.";
      case "Garage entry removed.": return chinese ? (traditional ? "已移除車庫條目。" : "已移除车库条目。") : "Garage entry removed.";
      case "Exit the Basilisk before recall.": return chinese ? (traditional ? "召回前請先下車。" : "召回前请先下车。") : "Exit the Basilisk before recall.";
      case "Basilisk recalled.": return chinese ? (traditional ? "魔蜥已召回。" : "魔蜥已召回。") : "Basilisk recalled.";
      case "Load a save and return to gameplay first.": return chinese ? (traditional ? "請先加載存檔并回到游戲。" : "请先加载存档并回到游戏。") : "Load a save and return to gameplay first.";
      case "Deployment in progress.": return chinese ? (traditional ? "正在部署。" : "正在部署。") : "Deployment in progress.";
      case "Exit the current vehicle first.": return chinese ? (traditional ? "請先離開當前載具。" : "请先离开当前载具。") : "Exit the current vehicle first.";
      case "Finish the current scene first.": return chinese ? (traditional ? "請先完成當前劇情。" : "请先完成当前剧情。") : "Finish the current scene first.";
      case "Deploy on open outdoor ground.": return chinese ? (traditional ? "請在室外開闊地部署。" : "请在室外开阔地部署。") : "Deploy on open outdoor ground.";
      case "No ground ahead. Face a clear level surface.": return chinese ? (traditional ? "前方沒有可用地面，請面向開闊平地。" : "前方没有可用地面，请面向开阔平地。") : "No ground ahead. Face a clear level surface.";
      case "Deploying Basilisk...": return chinese ? (traditional ? "正在部署魔蜥…" : "正在部署魔蜥…") : "Deploying Basilisk...";
      case "Spawn request failed.": return chinese ? (traditional ? "生成請求失敗。" : "生成请求失败。") : "Spawn request failed.";
      case "Deploy a working Basilisk first.": return chinese ? (traditional ? "請先部署可駕駛的魔蜥。" : "请先部署可驾驶的魔蜥。") : "Deploy a working Basilisk first.";
      case "Move within 35 m of the Basilisk.": return chinese ? (traditional ? "請靠近至魔蜥 35 米以內。" : "请靠近至魔蜥 35 米以内。") : "Move within 35 m of the Basilisk.";
      case "Boarding the driver seat.": return chinese ? (traditional ? "正在進入駕駛位。" : "正在进入驾驶位。") : "Boarding the driver seat.";
      case "Basilisk ready. Enter normally or use Board Basilisk.": return chinese ? (traditional ? "魔蜥已就緒，可正常上車或點擊進入駕駛位。" : "魔蜥已就绪，可正常上车或点击进入驾驶位。") : "Basilisk ready. Enter normally or use Board Basilisk.";
      case "Spawn timed out. Try another open area.": return chinese ? (traditional ? "生成超時，請換一處開闊地重試。" : "生成超时，请换一处开阔地重试。") : "Spawn timed out. Try another open area.";
      default: return value;
    }
  }
}
