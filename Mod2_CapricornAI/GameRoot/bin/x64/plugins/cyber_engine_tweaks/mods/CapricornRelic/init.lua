local L=require("locale")
local presets=require("presets")
local settings={enabled=true,showPortrait=true,apiEnabled=false,allowActions=true,reactive=true}
local overlay=false
local input=""
local history={}
local pending=nil
local elapsed=0
local now=0
local sequence=0
local lastError=nil
local wasCombat=nil
local reactionAt=0
local lastPlayer=nil
local openChatAfterOverlay=false
local publishedLanguage=nil
local function core() return Game.GetScriptableSystemsContainer():Get("CRRelicSystem") end
local function save()
  local f=io.open("settings.json","w");if f then f:write(json.encode(settings));f:close() end
end
local function apply()
  for k,v in pairs({Enabled=settings.enabled,ShowPortrait=settings.showPortrait}) do
    TweakDB:SetFlat("CapricornRelic."..k,v)
  end
end
local function guard(fn)
  local ok,value=pcall(fn)
  if not ok then
    local message=tostring(value)
    if lastError~=message then print("[CapricornRelic] "..message) end
    lastError=message
  else lastError=nil end
  return ok,value
end
local function entry(role,text)
  history[#history+1]={role=role,content=text}
  while #history>24 do table.remove(history,1) end
end
local function say(text)
  entry("assistant",text)
  guard(function() core():Say(text) end)
end
local function preset(group)
  local selected=L.code=="zh-cn" and presets or L.code=="zh-tw" and require("presets_tw") or require("presets_en")
  local pool=selected[group] or selected.chat
  return pool[math.random(#pool)]
end
local function tank(order)
  local mod=GetMod("HangarTanks")
  if not mod then return false,L.tr("请先安装 Mod1：魔蜥与奇美拉仓库。") end
  local ok,result=mod.command(order)
  return ok and result~=false,mod.status()
end
local tankActions={chimera_follow=1,chimera_guard=2,chimera_attack=3,chimera_stop=0,chimera_recall=4}
local hackActions={short_circuit=true,overheat=true,blind=true,cripple=true,weapon_glitch=true,memory_wipe=true,cyberpsychosis=true,blackwall=true,vehicle_brake=true,vehicle_accelerate=true,vehicle_control=true,vehicle_explode=true}
local function execute(action)
  if not settings.enabled then return L.tr("Relic 互动已关闭。") end
  if tankActions[action]~=nil then local ok,status=tank(tankActions[action]);return ok and L.tr("奇美拉指令已执行。") or status end
  if action=="chimera_deploy" then
    local mod=GetMod("HangarTanks")
    if not mod then return L.tr("需要先安装 Mod1。") end
    local ok,result=mod.deploy(2)
    return ok and result and L.tr("部署请求已发送。") or mod.status()
  end
  if hackActions[action] then return core():HackTarget(action) end
  if action=="heal" then core():Heal();return preset("heal") end
  if action=="area_blackwall" then return L.tr("黑墙已上传到 ")..core():AreaBlackwall()..L.tr(" 个附近敌对目标。") end
  if action=="give_deck" then core():GiveDeck();return L.tr("已放入摩羯接入仓。") end
  return ""
end
local function doAction(action)
  local ok,result=guard(function() return execute(action) end)
  say(ok and result or L.tr("指令暂时未完成，请查看面板诊断。"))
end
local function context()
  local p=Game.GetPlayer()
  local c={game="Cyberpunk 2077",language=L.code,in_combat=p:IsInCombat()}
  c.health=Game.GetStatPoolsSystem():GetStatPoolValue(p:GetEntityID(),gamedataStatPoolType.Health,true)
  local t=core():Target()
  c.target=t and (t:IsVehicle() and "vehicle" or (t:IsNPC() and "npc" or "other")) or "none"
  local mod=GetMod("HangarTanks");c.chimera=mod and mod.status() or "mod1 not installed"
  return c
end
local function localIntent(text)
  local t=text:lower()
  local aliases={ ["deploy chimera"]="chimera_deploy",["summon chimera"]="chimera_deploy",["attack target"]="chimera_attack",["destroy target"]="chimera_attack",["cease fire"]="chimera_stop",["heal"]="heal",["short circuit"]="short_circuit",["overheat"]="overheat",["area blackwall"]="area_blackwall",["brake"]="vehicle_brake",["self-destruct"]="vehicle_explode",["control vehicle"]="vehicle_control" }
  if aliases[t] then return aliases[t] end
  if t:find("跟隨",1,true) then return "chimera_follow" end
  if t:find("警戒",1,true) then return "chimera_guard" end
  if t:find("停火",1,true) then return "chimera_stop" end
  if t:find("停止",1,true) then return "chimera_stop" end
  if t:find("召回",1,true) then return "chimera_recall" end
  if t:find("摧毀目標",1,true) then return "chimera_attack" end
  if t:find("攻擊目標",1,true) then return "chimera_attack" end
  if t:find("召喚奇美拉",1,true) then return "chimera_deploy" end
  if t:find("治療",1,true) then return "heal" end
  if t:find("修復我",1,true) then return "heal" end
  if t:find("群體黑牆",1,true) then return "area_blackwall" end
  if t:find("黑牆",1,true) then return "blackwall" end
  if t:find("群體黑墻",1,true) then return "area_blackwall" end
  if t:find("黑墻",1,true) then return "blackwall" end
  if t:find("短路",1,true) then return "short_circuit" end
  if t:find("過熱",1,true) then return "overheat" end
  if t:find("制動",1,true) then return "vehicle_brake" end
  if t:find("剎車",1,true) then return "vehicle_brake" end
  if t:find("自毀",1,true) then return "vehicle_explode" end
  if t:find("接管車輛",1,true) then return "vehicle_control" end
  if t:find("跟随",1,true) or t:find("follow",1,true) then return "chimera_follow" end
  if t:find("警戒",1,true) or t:find("guard",1,true) then return "chimera_guard" end
  if t:find("停火",1,true) or t:find("停止",1,true) or t=="stop" then return "chimera_stop" end
  if t:find("召回",1,true) or t:find("recall",1,true) then return "chimera_recall" end
  if t:find("摧毁目标",1,true) or t:find("攻击目标",1,true) then return "chimera_attack" end
  if t:find("召唤奇美拉",1,true) then return "chimera_deploy" end
  if t:find("治疗",1,true) or t:find("修复我",1,true) or t=="heal" then return "heal" end
  if t:find("群体黑墙",1,true) then return "area_blackwall" end
  if t:find("黑墙",1,true) or t=="blackwall" then return "blackwall" end
  if t:find("短路",1,true) then return "short_circuit" end
  if t:find("过热",1,true) then return "overheat" end
  if t:find("制动",1,true) or t:find("刹车",1,true) then return "vehicle_brake" end
  if t:find("自毁",1,true) then return "vehicle_explode" end
  if t:find("接管车辆",1,true) then return "vehicle_control" end
end
local function send(text)
  if text=="" or pending then return end
  if not Game.GetPlayer() then return end
  entry("user",text)
  if not settings.apiEnabled then
    local action=localIntent(text)
    if action then doAction(action) else say(preset("chat")) end
    core():SetChatBusy(false,"离线模式")
    return
  end
  sequence=sequence+1
  local id=tostring(os.time()).."-"..sequence
  local request={id=id,text=text,history=history,context=context(),allow_actions=settings.allowActions}
  local f,err=io.open("bridge/request.json","w")
  if not f then say(preset("offline"));lastError=tostring(err);core():SetChatBusy(false,"桥接器不可用");return end
  f:write(json.encode(request));f:close()
  pending={id=id,at=now}
  core():SetChatBusy(true,"等待 AI 回复…")
end
local function poll()
  if not pending then return end
  local f=io.open("bridge/response.json","r")
  if f then
    local ok,response=pcall(json.decode,f:read("*a"));f:close()
    if ok and type(response)=="table" and response.id==pending.id then
      pending=nil
      core():SetChatBusy(false,response.error and "连接失败" or "AI 已回复")
      if response.error then lastError=tostring(response.error);say(preset("offline"));return end
      say(type(response.reply)=="string" and response.reply or preset("chat"))
      if settings.allowActions and type(response.actions)=="table" then
        for i=1,math.min(3,#response.actions) do
          local action=response.actions[i]
          if type(action)=="string" then
            local success,result=guard(function() return execute(action) end)
            if success and result~="" then entry("system",result) end
          end
        end
      end
      return
    end
  end
  if now-pending.at>50 then pending=nil;lastError="API bridge timeout";core():SetChatBusy(false,"API 超时，可重试");say(preset("offline")) end
end
registerForEvent("onInit",function()
  L.refresh()
  local f=io.open("settings.json","r")
  if f then local ok,data=pcall(json.decode,f:read("*a"));f:close();if ok and type(data)=="table" then for k in pairs(settings) do if type(data[k])=="boolean" then settings[k]=data[k] end end end end
  apply()
  print("[CapricornRelic] 0.2 loaded: offline by default; optional API bridge.")


end)
registerForEvent("onOverlayOpen",function() L.refresh();overlay=true;guard(function() local c=core();if c then c:CloseChat() end end) end)
registerForEvent("onOverlayClose",function() overlay=false end)
registerForEvent("onUpdate",function(dt)
  L.tick(dt)
  if publishedLanguage~=L.code then
    local f=io.open("bridge/language.json","w")
    if f then f:write(json.encode({language=L.code}));f:close();publishedLanguage=L.code end
  end
  now=now+dt;elapsed=elapsed+dt
  if elapsed<0.25 then return end
  local step=elapsed;elapsed=0
  guard(function()
    local p=Game.GetPlayer()
    if not p or Game.GetSystemRequestsHandler():IsPreGame() then lastPlayer=nil;pending=nil;return end
    if lastPlayer~=p then lastPlayer=p;wasCombat=nil;pending=nil;history={};reactionAt=now+15 end
    if openChatAfterOverlay and not overlay then openChatAfterOverlay=false;core():ToggleChat() end
    local queued=core():TakeChatMessage()
    if queued~="" then
      local ok=guard(function() send(queued) end)
      if not ok then core():SetChatBusy(false,"发送失败，请重试") end
    end
    core():Tick(step);poll()
    if not settings.enabled or not settings.reactive or not core():Gameplay() then return end
    local combat=p:IsInCombat()
    if wasCombat~=nil and combat~=wasCombat and now>reactionAt then say(preset(combat and "combat" or "peace"));reactionAt=now+25 end
    wasCombat=combat
    if now>reactionAt and Game.GetStatPoolsSystem():GetStatPoolValue(p:GetEntityID(),gamedataStatPoolType.Health,true)<25 then say(preset("hurt"));reactionAt=now+50 end
  end)
end)
local buttons={
  {"短路","short_circuit"},{"过热","overheat"},{"义眼重启","blind"},{"义体失灵","cripple"},
  {"武器故障","weapon_glitch"},{"记忆清除","memory_wipe"},{"赛博精神病","cyberpsychosis"},{"黑墙","blackwall"},
  {"车辆制动","vehicle_brake"},{"车辆加速","vehicle_accelerate"},{"接管车辆","vehicle_control"},{"车辆自毁","vehicle_explode"},
  {"治疗 V","heal"},{"附近敌人·黑墙","area_blackwall"},{"领取摩羯接入仓","give_deck"}
}
L.refresh()
registerHotkey("cr_chat",L.tr("Capricorn: offline greeting"),function() say(preset("hello")) end)
registerHotkey("cr_chat_window",L.tr("Capricorn: Toggle chat window / 打开关闭聊天"),function()
  if not overlay then guard(function() core():ToggleChat() end) end
end)
registerForEvent("onShutdown",function() pcall(function() core():CloseChat() end) end)
registerHotkey("cr_blackwall",L.tr("Capricorn: Blackwall on crosshair target"),function() doAction("blackwall") end)
registerHotkey("cr_brake",L.tr("Capricorn: brake crosshair vehicle"),function() doAction("vehicle_brake") end)
registerHotkey("cr_heal",L.tr("Capricorn: heal V"),function() doAction("heal") end)

registerForEvent("onDraw",function()
  if not overlay then return end
  ImGui.SetNextWindowSize(700,720,ImGuiCond.FirstUseEver)
  if ImGui.Begin(L.ui("摩羯 / CAPRICORN · RELIC","CapricornRelic")) then
    ImGui.TextWrapped(L.tr("离线陪伴、自由黑客指令，以及可选 AI API。准星先对准目标，再点指令或按快捷键。"))
    if ImGui.Button(L.tr("打开简洁聊天窗口"),220,30) then openChatAfterOverlay=true end
    if openChatAfterOverlay then ImGui.TextWrapped(L.tr("按 CET 面板键关闭覆盖层后，聊天窗口会打开。")) end
    local changed
    for _,option in ipairs({{"enabled","启用额外互动"},{"showPortrait","显示摩羯 HUD 立绘"},{"reactive","离线情境互动"},{"apiEnabled","启用外部 AI API（需启动独立桥接器）"},{"allowActions","允许 AI 调用游戏指令"}}) do
      settings[option[1]],changed=ImGui.Checkbox(L.tr(option[2]),settings[option[1]])
      if changed then apply();save() end
    end
    ImGui.Separator()
    ImGui.BeginChild("conversation",0,160,true)
    for _,line in ipairs(history) do ImGui.TextWrapped((line.role=="user" and L.tr("V: ") or line.role=="system" and L.tr("[执行] ") or L.tr("摩羯: "))..line.content) end
    ImGui.EndChild()
    input=ImGui.InputText(L.tr("消息"),input,2048)
    if ImGui.Button(pending and L.tr("等待 AI...") or L.tr("发送"),140,30) and not pending then local text=input;input="";guard(function() send(text) end) end
    ImGui.SameLine();if ImGui.Button(L.tr("离线聊聊"),140,30) then say(preset("chat")) end
    ImGui.Separator()
    for i,button in ipairs(buttons) do
      if ImGui.Button(L.tr(button[1]),155,28) then doAction(button[2]) end
      if i%4~=0 then ImGui.SameLine() end
    end
    ImGui.NewLine();ImGui.Text(L.tr("奇美拉协同（Mod1）"))
    for i,button in ipairs({{"部署奇美拉","chimera_deploy"},{"跟随","chimera_follow"},{"警戒","chimera_guard"},{"摧毁目标","chimera_attack"},{"停火","chimera_stop"},{"召回","chimera_recall"}}) do
      if ImGui.Button(L.tr(button[1]),100,28) then doAction(button[2]) end
      if i<6 then ImGui.SameLine() end
    end
    if lastError then ImGui.TextWrapped(L.tr("诊断：")..lastError) end
    ImGui.TextWrapped(L.tr("API 设置：桌面模组包里的“启动AI桥接.cmd”。聊天与简单指令默认离线可用。原版 Capricorn 的接入仓、台词、语音和任务仍由原模组提供。"))
  end
  ImGui.End()
end)
return {send=send,action=doAction,say=say}
