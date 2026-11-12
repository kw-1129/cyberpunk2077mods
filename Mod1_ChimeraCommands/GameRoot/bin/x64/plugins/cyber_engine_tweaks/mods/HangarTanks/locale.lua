-- Each mod owns a copy: installing Capricorn is never required by the tanks.
local L={code="en-us",strings={}}
local f=io.open("locale.json","r")
if f then
  local ok,data=pcall(json.decode,f:read("*a"));f:close()
  if ok and type(data)=="table" then L.strings=data end
end
function L.refresh()
  local ok,value=pcall(function()
    local s=Game.GetScriptableSystemsContainer():Get("Codeware.Localization.LocalizationSystem")
    if s then return NameToString(s:GetInterfaceLanguage()) end
  end)
  if ok and type(value)=="string" and value~="" and value~="None" then L.code=value:lower():gsub("_","-") end
end
local elapsed=0
function L.tick(dt)
  elapsed=elapsed+dt
  if elapsed>=0.5 then elapsed=0;L.refresh() end
end
function L.tr(text)
  local entry=L.strings[text]
  if not entry then return text end
  return entry[L.code] or entry["en-us"] or text
end
function L.ui(text,id)
  return L.tr(text).."###"..id
end
return L
