local L=require("locale")
local overlay = false
local config = {autoRegister=true}
local failure = nil
local function system() return Game.GetScriptableSystemsContainer():Get("HGBasiliskSystem") end
local function save()
  local f=io.open("settings.json","w")
  if f then f:write(json.encode(config));f:close() end
end
local function run(fn)
  local ok,value=pcall(fn)
  if not ok then
    local text=tostring(value)
    if failure~=text then print("[HGBasilisk] "..text) end
    failure=text
  else failure=nil end
  return ok,value
end
registerForEvent("onInit",function()
  L.refresh()
  local f=io.open("settings.json","r")
  if f then
    local ok,data=pcall(json.decode,f:read("*a"));f:close()
    if ok and type(data)=="table" and type(data.autoRegister)=="boolean" then config.autoRegister=data.autoRegister end
  end
  print("[HGBasilisk] 1.0.0 independent custom Basilisk loaded.")


end)
registerForEvent("onOverlayOpen",function() L.refresh();overlay=true end)
registerForEvent("onOverlayClose",function() overlay=false end)
registerForEvent("onUpdate",function(dt)
  L.tick(dt)
  if not Game.GetPlayer() then return end
  run(function() local s=system();if s then s:Tick(math.min(dt,0.2),config.autoRegister) end end)
end)
L.refresh()
registerHotkey("basilisk_deploy",L.tr("Basilisk: deploy"),function() run(function() return system():Deploy() end) end)
registerHotkey("basilisk_board",L.tr("Basilisk: board driver seat"),function() run(function() return system():Board() end) end)
registerHotkey("basilisk_recall",L.tr("Basilisk: recall"),function() run(function() return system():Recall() end) end)

registerForEvent("onDraw",function()
  if not overlay then return end
  ImGui.SetNextWindowSize(500,280,ImGuiCond.FirstUseEver)
  if ImGui.Begin(L.ui("魔蜥 / BASILISK · 私人仓库","BasiliskHangar")) then
    ImGui.TextWrapped(L.tr("在室外开阔地部署。魔蜥会加入普通呼叫载具列表。"))
    if ImGui.Button(L.tr("部署魔蜥 / Deploy"),220,36) then run(function() system():Deploy() end) end
    ImGui.SameLine()
    if ImGui.Button(L.tr("进入驾驶位 / Board"),220,36) then run(function() system():Board() end) end
    if ImGui.Button(L.tr("召回 / Recall"),220,30) then run(function() system():Recall() end) end
    ImGui.TextWrapped(L.tr("驾驶、瞄准及武器沿用游戏魔蜥键位。靠近后可正常进入，也可点“进入驾驶位”。召回前先下车。"))
    if ImGui.Button(L.tr("加入车库"),140,28) then config.autoRegister=true;save();run(function() system():RegisterGarage() end) end
    ImGui.SameLine()
    if ImGui.Button(L.tr("移除车库条目"),140,28) then
      local ok,removed=run(function() return system():RemoveGarage() end)
      if ok and removed then config.autoRegister=false;save() end
    end
    local ok,message=pcall(function() local s=system();return s and L.tr(s:Message()) or L.tr("先加载存档。") end)
    ImGui.TextWrapped(ok and message or L.tr("脚本未就绪，请查看 redscript 日志。"))
    if failure then ImGui.TextWrapped(failure) end
  end
  ImGui.End()
end)
return {deploy=function() return run(function() return system():Deploy() end) end}
