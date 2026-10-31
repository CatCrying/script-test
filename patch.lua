-- GG Patch: get_IsIAP
local LIB    = "libil2cpp.so"
local OFFSET = 0x3D23794
local FIX    = 4233527296
local NAME   = "get_IsIAP"

local PATCH = {
    {0, 4, "h000080D2"},  -- movz x0, #0 ; ret 
    {4, 4, "hC0035FD6"},
}
local ORIG = {
    {0, 4, "h081040B9"},
    {4, 4, "h1F290071"},
}

-- lowest range of LIB == ELF base
local function getBase()
  local base
  for _, r in ipairs(gg.getRangesList()) do
    if r.name and r.name:find(LIB, 1, true) and (not base or r.start < base) then
      base = r.start
    end
  end
  return base
end

local base = getBase()
if not base then
  gg.alert(LIB .. " not found.\nSelect the game process in GG first.")
  os.exit()
end
local addr = base + OFFSET + FIX

local function build(list)
  local t = {}
  for i, p in ipairs(list) do
    t[i] = {address = addr + p[1], flags = p[2], value = p[3]}
  end
  return t
end

local function restoreList() return build(ORIG) end

local on = false
gg.setVisible(false)
while true do
  if gg.isVisible() then
    gg.setVisible(false)
    local c = gg.choice({on and "Disable patch" or "Enable patch", "Exit"}, nil, NAME)
    if c == 1 then
      if on then gg.setValues(restoreList()) gg.toast("Patch OFF")
      else gg.setValues(build(PATCH)) gg.toast("Patch ON") end
      on = not on
    elseif c == 2 then break end
  end
  gg.sleep(100)
end
