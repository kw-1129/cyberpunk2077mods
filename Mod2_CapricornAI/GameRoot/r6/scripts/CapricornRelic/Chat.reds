import Codeware.UI.*

// Compact native popup: works with CET closed, without a fullscreen backdrop.
public class CRChatPopup extends InGamePopup {
  public let owner: wref<CRRelicSystem>;
  private let input: ref<HubTextInput>;
  private let conversation: ref<inkText>;
  private let status: ref<inkText>;
  private let sendButton: ref<SimpleButton>;
  private let title: ref<inkText>;
  private let hint: ref<inkText>;
  private let buttons: array<ref<SimpleButton>>;
  private let buttonLabels: array<String>;
  private let language: CName;

  public func UseCursor() -> Bool { return true; }
  protected func CreateVignette() -> Void {}
  protected func SetBackgroundBlur() -> Void {}
  protected func ResetBackgroundBlur() -> Void {}
  protected func SetTimeDilation() -> Void {}
  protected func ResetTimeDilation() -> Void {}

  protected func CreateContainer() -> Void {
    let panel = new inkCanvas();
    panel.SetName(n"CapricornChat");
    panel.SetAnchor(inkEAnchor.CenterRight);
    panel.SetAnchorPoint(Vector2(1.0,0.5));
    panel.SetMargin(0.0,0.0,40.0,0.0);
    panel.SetSize(660.0,560.0);
    panel.SetInteractive(true);
    panel.Reparent(this.GetRootCompoundWidget());
    this.m_container = panel;
    this.SetContainerWidget(panel);
    let background = new inkRectangle();
    background.SetSize(660.0,560.0);
    background.SetTintColor(HDRColor(0.015,0.035,0.05,1.0));
    background.SetOpacity(0.92);
    background.Reparent(panel);
    this.title = this.Label(CRText.Text("摩羯 / CAPRICORN"),24.0,16.0,32);
    this.hint = this.Label(CRText.Text("输入消息或点快捷互动；Esc 关闭"),24.0,55.0,20);
    this.conversation = this.Label(this.owner.ChatText(),24.0,96.0,24);
    this.conversation.SetSize(610.0,240.0);
    this.conversation.SetWrapping(true,600.0);
    this.status = this.Label("",24.0,340.0,20);
    this.input = HubTextInput.Create();
    this.input.SetWidth(610.0);
    this.input.SetMaxLength(500);
    this.input.SetDefaultText(CRText.Text("和摩羯说点什么…"));
    this.input.GetRootWidget().SetMargin(24.0,370.0,0.0,0.0);
    this.input.Reparent(panel);
    ArrayClear(this.buttons); ArrayClear(this.buttonLabels);
    this.sendButton = this.Button("发送",24.0,445.0,n"Send");
    this.Button("聊聊",180.0,445.0,n"Chat");
    this.Button("治疗",336.0,445.0,n"Heal");
    this.Button("关闭",492.0,445.0,n"Dismiss");
    this.Button("跟随",24.0,500.0,n"Follow");
    this.Button("警戒",180.0,500.0,n"Guard");
    this.Button("停火",336.0,500.0,n"Stop");
    this.Button("召回",492.0,500.0,n"Recall");
    this.language = n"None";
    this.Refresh();
  }
  private func Label(text: String,x: Float,y: Float,size: Int32) -> ref<inkText> {
    let label = new inkText();
    label.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
    label.SetFontStyle(n"Medium");
    label.SetFontSize(size);
    label.SetTintColor(HDRColor(0.35,1.0,0.85,1.0));
    label.SetMargin(x,y,0.0,0.0);
    label.SetText(text);
    label.Reparent(this.m_container);
    return label;
  }
  private func Button(text: String,x: Float,y: Float,callback: CName) -> ref<SimpleButton> {
    let button = SimpleButton.Create();
    button.SetText(CRText.Text(text));
    ArrayPush(this.buttons,button); ArrayPush(this.buttonLabels,text);
    button.GetRootWidget().SetAnchorPoint(Vector2(0.0,0.0));
    button.GetRootWidget().SetSize(140.0,44.0);
    button.SetPosition(x,y);
    let label = (button.GetRootWidget() as inkCompoundWidget).GetWidgetByPathName(n"label") as inkText;
    if IsDefined(label) { label.SetFontSize(24); }
    button.RegisterToCallback(n"OnBtnClick",this,callback);
    button.Reparent(this.m_container);
    return button;
  }
  protected cb func OnShown() -> Void {
    this.GetGameController().RequestSetFocus(this.input.GetRootWidget());
  }
  protected cb func OnHide() -> Void {
    super.OnHide();
    if IsDefined(this.owner) { this.owner.ChatClosed(this); }
  }
  public func Refresh() -> Void {
    if !IsDefined(this.conversation) { return; }
    let language = CRText.Language();
    if NotEquals(language,this.language) {
      this.language = language;
      this.title.SetText(CRText.Text("摩羯 / CAPRICORN"));
      this.hint.SetText(CRText.Text("输入消息或点快捷互动；Esc 关闭"));
      this.input.SetDefaultText(CRText.Text("和摩羯说点什么…"));
      let i = 0;
      while i < ArraySize(this.buttons) { this.buttons[i].SetText(CRText.Text(this.buttonLabels[i])); i += 1; }
    }
    this.conversation.SetText(this.owner.ChatText());
    this.status.SetText(this.owner.ChatStatus());
    this.sendButton.SetDisabled(this.owner.ChatBusy());
  }
  protected cb func Send(widget: wref<inkWidget>) -> Void {
    if this.owner.SubmitChat(this.input.GetText()) { this.input.SetText(""); }
    this.GetGameController().RequestSetFocus(this.input.GetRootWidget());
  }
  protected cb func Chat(widget: wref<inkWidget>) -> Void { this.owner.SubmitChat(CRText.Text("陪我聊聊吧。")); }
  protected cb func Heal(widget: wref<inkWidget>) -> Void { this.owner.SubmitChat(CRText.Text("治疗")); }
  protected cb func Follow(widget: wref<inkWidget>) -> Void { this.owner.SubmitChat(CRText.Text("跟随")); }
  protected cb func Guard(widget: wref<inkWidget>) -> Void { this.owner.SubmitChat(CRText.Text("警戒")); }
  protected cb func Stop(widget: wref<inkWidget>) -> Void { this.owner.SubmitChat(CRText.Text("停火")); }
  protected cb func Recall(widget: wref<inkWidget>) -> Void { this.owner.SubmitChat(CRText.Text("召回")); }
  protected cb func Dismiss(widget: wref<inkWidget>) -> Void { this.Close(); }
}
