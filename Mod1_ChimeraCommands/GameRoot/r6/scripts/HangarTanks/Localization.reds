module HangarTanks.Localization
import Codeware.Localization.*

public class Provider extends ModLocalizationProvider {
  public func GetPackage(language: CName) -> ref<ModLocalizationPackage> {
    if Equals(language,n"zh-cn") { return new Chinese(); }
    if Equals(language,n"zh-tw") { return new Traditional(); }
    return new English();
  }
  public func GetFallback() -> CName { return n"en-us"; }
}
public class Chinese extends ModLocalizationPackage {
  protected func DefineTexts() -> Void {
    this.Text("HG-Basilisk","魔蜥 · 私人装甲仓库");
    this.Text("HG-Chimera","奇美拉 · 指令战斗平台");
  }
}
public class English extends ModLocalizationPackage {
  protected func DefineTexts() -> Void {
    this.Text("HG-Basilisk","Basilisk | Private Hangar");
    this.Text("HG-Chimera","Chimera | Command Platform");
  }
}
public class Traditional extends ModLocalizationPackage {
  protected func DefineTexts() -> Void {
    this.Text("HG-Basilisk","魔蜥 · 私人裝甲倉庫");
    this.Text("HG-Chimera","奇美拉 · 指令戰鬥平台");
  }
}
