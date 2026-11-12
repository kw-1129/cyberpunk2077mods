local L=require("locale")
local overlay = false
local failure = nil
local config = {autoRegister=true}
local function system() return Game.GetScriptableSystemsContainer():Get("HGTankSystem") end
local function save()
  local f=io.open("settings.json","w")
  if f then f:write(json.encode(config));f:close() end
end
local function run(fn)
  local ok, result = pcall(fn)
  if not ok then
    local message=tostring(result)
    if failure~=message then print("[HangarTanks] "..message) end
    failure=message
    return false,message
  end
  failure=nil
  return true,result
end
local function command(order) return run(function() return system():Command(order) end) end
registerForEvent("onInit",function()
  L.refresh()
  local f=io.open("settings.json","r")
  if f then
    local ok,data=pcall(json.decode,f:read("*a"));f:close()
    if ok and type(data)=="table" and type(data.autoRegister)=="boolean" then config.autoRegister=data.autoRegister end
  end
  print("[HangarTanks] 0.3.0 Chimera Commands. Open CET overlay for commands.")


end)
registerForEvent("onOverlayOpen",function() L.refresh();overlay=true end)
registerForEvent("onOverlayClose",function() overlay=false end)
registerForEvent("onUpdate",function(dt)
  L.tick(dt)
  if not Game.GetPlayer() then return end
  run(function() local s=system();if s then s:Tick(math.min(dt,0.2),config.autoRegister) end end)
end)
registerForEvent("onShutdown",function() pcall(function() local s=system();if s then s:ClearOrders() end end) end)
L.refresh()
registerHotkey("hg_chimera",L.tr("Hangar: deploy Chimera"),function() run(function() system():Deploy(2) end) end)
registerHotkey("hg_follow",L.tr("Chimera: follow V"),function() command(1) end)
registerHotkey("hg_guard",L.tr("Chimera: guard position"),function() command(2) end)
registerHotkey("hg_attack",L.tr("Chimera: destroy crosshair target"),function() command(3) end)
registerHotkey("hg_stop",L.tr("Chimera: cease fire / hold"),function() command(0) end)
registerHotkey("hg_recall",L.tr("Chimera: recall"),function() run(function() system():Recall(2) end) end)

registerForEvent("onDraw",function()
  if not overlay then return end
  ImGui.SetNextWindowSize(580,480,ImGuiCond.FirstUseEver)
  if ImGui.Begin(L.ui("CHIMERA | Command Platform","ChimeraCommands")) then
    ImGui.TextWrapped(L.tr("Chimera appears in V's normal vehicle call list. Deploy on open outdoor ground. Uses native boss AI, weapons and health scaling."))
    ImGui.Separator()
    if ImGui.Button(L.tr("Deploy CHIMERA"),260,36) then run(function() system():Deploy(2) end) end
    ImGui.SameLine()
    if ImGui.Button(L.tr("Recall Chimera"),260,36) then command(4) end
    if ImGui.Button(L.tr("FOLLOW V"),170,36) then command(1) end
    ImGui.SameLine()
    if ImGui.Button(L.tr("GUARD HERE"),170,36) then command(2) end
    ImGui.SameLine()
    if ImGui.Button(L.tr("STOP / HOLD"),170,36) then command(0) end
    if ImGui.Button(L.tr("DESTROY CROSSHAIR TARGET"),530,36) then command(3) end
    ImGui.TextWrapped(L.tr("For Attack, bind a hotkey in CET > Bindings. Aim at an NPC or vehicle, then press it. Guard defends a 60 m area; Follow keeps about 12 m behind V."))
    ImGui.Separator()
    if ImGui.Button(L.tr("Recall"),170,28) then run(function() system():Recall(2) end) end
    ImGui.SameLine()
    if ImGui.Button(L.tr("Register garage"),170,28) then config.autoRegister=true;save();run(function() system():RegisterGarage() end) end
    ImGui.SameLine()
    if ImGui.Button(L.tr("Remove entries"),170,28) then config.autoRegister=false;save();run(function() system():RemoveGarage() end) end
    local changed
    config.autoRegister,changed=ImGui.Checkbox(L.tr("Auto-register Chimera in garage"),config.autoRegister)
    if changed then save() end
    local ok,message=pcall(function()
      local s=system()
      return s and (L.tr(s:Message())..string.format(L.tr("\nChimera health: %.0f (%.1f%%)"),s:Health(false),s:Health(true))) or L.tr("Load a save first.")
    end)
    ImGui.TextWrapped(ok and message or L.tr("Scripts unavailable: check r6/logs/redscript_rCURRENT.log"))
    if failure then ImGui.TextWrapped(L.tr("Error: ")..failure) end
  end
  ImGui.End()
end)
return {
  command=command,
  deploy=function(kind) return run(function() return system():Deploy(kind) end) end,
  status=function() local s=system();return s and L.tr(s:Message()) or L.tr("Unavailable") end
}
