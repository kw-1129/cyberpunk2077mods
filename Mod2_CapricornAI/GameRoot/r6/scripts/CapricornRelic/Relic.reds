import Codeware.UI.*

public class CRRelicSystem extends ScriptableSystem {
  private let canvas: ref<inkCanvas>;
  private let portrait: ref<inkImage>;
  private let caption: ref<inkText>;
  private let subtitleSerial: Uint64;
  private let lastLine: String;
  private let panelTime: Float;
  private let elapsed: Float;
  private let chat: ref<CRChatPopup>;
  private let chatMessage: String;
  private let chatUser: String;
  private let chatBusy: Bool;
  private let chatStatus: String;

  public static func Get() -> ref<CRRelicSystem> {
    return GameInstance.GetScriptableSystemsContainer(GetGameInstance()).Get(n"CRRelicSystem") as CRRelicSystem;
  }
  public static func Enabled() -> Bool { return TweakDBInterface.GetBool(t"CapricornRelic.Enabled",true); }
  public func OnAttach() -> Void {
    GameInstance.GetCallbackSystem().RegisterCallback(n"Session/BeforeEnd",this,n"BeforeEnd");
  }
  private cb func BeforeEnd(evt: ref<GameSessionEvent>) -> Void { this.CloseChat(); this.chatMessage = ""; this.chatBusy = false; this.RemovePanel(); }
  public func OnDetach() -> Void { this.canvas = null; this.portrait = null; this.caption = null; }
  private func RemovePanel() -> Void {
    if IsDefined(this.canvas) {
      let parent = this.canvas.GetParentWidget() as inkCompoundWidget;
      if IsDefined(parent) { parent.RemoveChild(this.canvas); }
    }
    this.canvas = null; this.portrait = null; this.caption = null;
  }
  public func Gameplay() -> Bool {
    let p = GetPlayer(this.GetGameInstance());
    return IsDefined(p) && !p.IsDead() && !GameInstance.GetSystemRequestsHandler().IsPreGame()
      && !GameInstance.GetBlackboardSystem(p.GetGame()).Get(GetAllBlackboardDefs().UI_System).GetBool(GetAllBlackboardDefs().UI_System.IsInMenu);
  }
  private func MakePanel() -> Void {
    if IsDefined(this.canvas) { return; }
    let layer = GameInstance.GetInkSystem().GetLayer(n"inkHUDLayer");
    if !IsDefined(layer) || !IsDefined(layer.GetVirtualWindow()) { return; }
    let canvas = new inkCanvas();
    canvas.SetName(n"CapricornRelicPanel");
    canvas.SetSize(360.0,210.0);
    canvas.SetAnchor(inkEAnchor.TopLeft);
    canvas.SetMargin(28.0,170.0,0.0,0.0);
    canvas.SetInteractive(false);
    let image = new inkImage();
    image.SetName(n"CapricornPortrait");
    image.SetAtlasResource(r"capricorn\\icons\\capri.inkatlas");
    image.SetTexturePart(n"CapriScanner");
    image.SetSize(150.0,170.0);
    image.SetFitToContent(false);
    image.SetTintColor(HDRColor(1.0,1.0,1.0,1.0));
    image.Reparent(canvas);
    let text = new inkText();
    text.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
    text.SetFontStyle(n"Medium");
    text.SetFontSize(22);
    text.SetText(CRText.Text("CAPRICORN\nRELIC // ONLINE"));
    text.SetMargin(165.0,38.0,0.0,0.0);
    text.SetTintColor(HDRColor(0.2,1.0,0.75,1.0));
    text.Reparent(canvas);
    canvas.Reparent(layer.GetVirtualWindow());
    this.canvas = canvas; this.portrait = image; this.caption = text;
  }
  public func Tick(dt: Float) -> Void {
    this.elapsed += dt;
    this.panelTime = MaxF(0.0,this.panelTime-dt);
    if this.elapsed < 0.25 { return; }
    this.elapsed = 0.0;
    if IsDefined(this.chat) && this.chat.IsInitialized() { this.chat.Refresh(); }
    if CRRelicSystem.Enabled() && this.Gameplay() && TweakDBInterface.GetBool(t"CapricornRelic.ShowPortrait",true) {
      this.MakePanel();
      if IsDefined(this.canvas) { this.canvas.SetVisible(this.panelTime > 0.0); }
    } else if IsDefined(this.canvas) { this.canvas.SetVisible(false); }
  }
  public func Say(text: String) -> Void {
    let p = GetPlayer(this.GetGameInstance());
    if !IsDefined(p) || !CRRelicSystem.Enabled() { return; }
    this.lastLine = text;
    if IsDefined(this.chat) { this.chat.Refresh(); }
    this.panelTime = 10.0;
    this.subtitleSerial += 1ul;
    p.CapricornShowSubtitle(770900000000000ul+this.subtitleSerial,text,10.0);
  }
  public func LastLine() -> String { return this.lastLine; }

  public func ToggleChat() -> Bool {
    if IsDefined(this.chat) { this.CloseChat(); return true; }
    if !CRRelicSystem.Enabled() || !this.Gameplay() || PlayerPuppet.GetSceneTier(GetPlayer(this.GetGameInstance())) > 2 { return false; }
    let manager = CustomPopupManager.GetInstance();
    if !manager.IsInitialized() { return false; }
    this.chat = new CRChatPopup();
    this.chat.owner = this;
    manager.ShowPopup(this.chat);
    return true;
  }
  public func CloseChat() -> Void {
    if IsDefined(this.chat) && this.chat.IsInitialized() { this.chat.Close(); }
  }
  public func ChatClosed(popup: ref<CRChatPopup>) -> Void { if this.chat == popup { this.chat = null; } }
  public func ChatText() -> String {
    if StrLen(this.chatUser) == 0 { return CRText.Text("摩羯：我在，V。今天想聊什么？\n\n") + UTF8StrLeft(this.lastLine,260); }
    return CRText.Text("V：") + UTF8StrLeft(this.chatUser,90) + CRText.Text("\n\n摩羯：") + UTF8StrLeft(this.lastLine,280);
  }
  public func ChatBusy() -> Bool { return this.chatBusy; }
  public func ChatStatus() -> String { return CRText.Text(this.chatStatus); }
  public func SetChatBusy(busy: Bool,status: String) -> Void {
    this.chatBusy = busy; this.chatStatus = status;
    if IsDefined(this.chat) { this.chat.Refresh(); }
  }
  public func SubmitChat(text: String) -> Bool {
    if this.chatBusy || StrLen(text) == 0 { return false; }
    this.chatUser = text; this.chatMessage = text; this.lastLine = "…";
    this.SetChatBusy(true,"正在回复…");
    return true;
  }
  public func TakeChatMessage() -> String {
    let text = this.chatMessage; this.chatMessage = ""; return text;
  }

  public func GiveDeck() -> Void {
    let p = GetPlayer(this.GetGameInstance());
    let item = ItemID.FromTDBID(t"Items.Capricorn");
    let ts = GameInstance.GetTransactionSystem(p.GetGame());
    if ts.GetItemQuantity(p,item) == 0 { ts.GiveItem(p,item,1); }
    this.Say(CRText.Text("摩羯接入仓库了。去义体医生那里安装我，或者直接用 Relic 指令——我已经在这儿了。"));
  }
  public func Heal() -> Void {
    let p = GetPlayer(this.GetGameInstance());
    if !IsDefined(p) { return; }
    GameInstance.GetStatPoolsSystem(p.GetGame()).RequestSettingStatPoolValue(Cast<StatsObjectID>(p.GetEntityID()),gamedataStatPoolType.Health,100.0,p,true);
    ProjectCapricornRecovery.Cleanse(p);
  }
  public func Target() -> ref<GameObject> {
    let p = GetPlayer(this.GetGameInstance());
    if !IsDefined(p) { return null; }
    return GameInstance.GetTargetingSystem(p.GetGame()).GetLookAtObject(p,true,true);
  }
  public func HackTarget(action: String) -> String { return this.Hack(this.Target(),action); }
  public func Hack(target: ref<GameObject>,action: String) -> String {
    let p = GetPlayer(this.GetGameInstance());
    if !this.Gameplay() || !CRRelicSystem.Enabled() || !IsDefined(target) || target == p { return CRText.Text("没有可用目标。准星对准人或车辆后重试。"); }
    let npc = target as NPCPuppet;
    let vehicle = target as VehicleObject;
    if IsDefined(vehicle) {
      switch action {
        case "vehicle_brake": vehicle.ActivateNetrunnerQuickhack(VehicleNetrunnerQuickhackType.ForceBrakes); return CRText.Text("车辆：紧急制动。");
        case "vehicle_accelerate": vehicle.ActivateNetrunnerQuickhack(VehicleNetrunnerQuickhackType.Accelerate); return CRText.Text("车辆：强制加速。");
        case "vehicle_control": vehicle.SetVehicleRemoteControlled(true,false,true); return CRText.Text("车辆：远程连接已接管。按游戏提示退出。");
        case "vehicle_explode":
        case "blackwall": vehicle.ActivateNetrunnerQuickhack(VehicleNetrunnerQuickhackType.Explode); return CRText.Text("车辆：自毁指令已下达。");
        default: return CRText.Text("该指令适用于人物。对车辆使用制动、加速、接管或自毁。");
      }
    }
    if !IsDefined(npc) || npc.IsDead() { return CRText.Text("目标不是存活人物/机械单位。"); }
    let effect: TweakDBID;
    switch action {
      case "short_circuit": effect = t"BaseStatusEffect.Overload"; break;
      case "overheat": effect = t"BaseStatusEffect.Overheat"; break;
      case "blind": effect = t"BaseStatusEffect.QuickHackBlind"; break;
      case "cripple": effect = t"BaseStatusEffect.LocomotionMalfunction"; break;
      case "weapon_glitch": effect = t"BaseStatusEffect.WeaponMalfunction"; break;
      case "memory_wipe": effect = t"BaseStatusEffect.MemoryWipe"; break;
      case "cyberpsychosis": effect = t"BaseStatusEffect.Madness"; break;
      case "blackwall":
        if npc.IsBoss() { CapricornProjectQuickhack.ApplyFresh(npc,p,t"BaseStatusEffect.BossBlackWallHack"); }
        else { CapricornProjectQuickhack.ApplyFresh(npc,p,t"BaseStatusEffect.BaseBlackWallHackEffect"); }
        return CRText.Text("黑墙已接入。");
      default: return CRText.Text("未知人物指令。");
    }
    if !IsDefined(TweakDBInterface.GetStatusEffectRecord(effect)) { return CRText.Text("当前游戏缺少该效果记录。"); }
    StatusEffectHelper.RemoveStatusEffect(npc,effect);
    StatusEffectHelper.ApplyStatusEffect(npc,effect,p.GetEntityID());
    return CRText.Text("已直接上传：无 RAM 消耗、无上传等待、无天赋门槛。");
  }
  public func AreaBlackwall() -> Int32 {
    let p = GetPlayer(this.GetGameInstance());
    let count = 0;
    if !this.Gameplay() { return 0; }
    for npc in p.GetNPCsAroundObject(50.0) {
      if !npc.IsDead() && Equals(GameObject.GetAttitudeTowards(npc,p),EAIAttitude.AIA_Hostile) {
        this.Hack(npc,"blackwall"); count += 1;
        if count >= 12 { break; }
      }
    }
    return count;
  }
}
