-- Runs DuoSpinup against a fake WoW API. From the repo root:
--   cd tests && go run . addon_test.lua
local ADDON_DIR = "../addon/DuoSpinup/"
local realprint = function(s) io.write(s, "\n") end

-- ------------------------------------------------------------ fake WoW
local W

local function reset()
    W = {
        cvars = {}, bindings = {}, saved = nil, macros = {}, combat = false, timers = {},
        bars = nil, log = {}, activeLayout = 1, setLayout = nil,
        layouts = { { layoutName = "main" } },
    }
end

function print(...)
    local t = {}
    for i = 1, select("#", ...) do t[#t + 1] = tostring(select(i, ...)) end
    W.log[#W.log + 1] = table.concat(t, " ")
end

ACCOUNT_BINDINGS = 1
SlashCmdList = {}
Enum = { EditModePresetLayoutsMeta = { NumValues = 2 } }
function SetCVar(k, v) W.cvars[k] = v end
function GetBindingAction(k) return W.bindings[k] or "" end
function SetBinding(k, a) W.bindings[k] = a; return true end
function SaveBindings(set) W.saved = set end
function SetActionBarToggles(a, b, c, d) W.bars = { a, b, c, d } end
function MultiActionBar_Update() end
function InCombatLockdown() return W.combat end
function GetMacroIndexByName(n) for i, m in ipairs(W.macros) do if m.name == n then return i end end return 0 end
function CreateMacro(n, icon, body) W.macros[#W.macros + 1] = { name = n, icon = icon, body = body } return #W.macros end
C_Timer = { After = function(_, fn) W.timers[#W.timers + 1] = fn end }
C_EditMode = {
    GetLayouts = function() return { activeLayout = W.activeLayout, layouts = W.layouts } end,
    SetActiveLayout = function(i) W.activeLayout = i; W.setLayout = i end,
}

-- Fake AceDB: New() picks the char's saved profile, else defaultProfile, else char key.
local AceDB = { db_registry = {} }
function AceDB:New(tbl, defaults, defaultProfile)
    local sv = type(tbl) == "string" and (_G[tbl] or {}) or tbl
    if type(tbl) == "string" then _G[tbl] = sv end
    sv.profileKeys = sv.profileKeys or {}
    sv.profiles = sv.profiles or {}
    local key = "New Char - PvE"
    local profile = sv.profileKeys[key] or (type(defaultProfile) == "string" and defaultProfile) or key
    sv.profileKeys[key] = profile
    local db = { sv = sv, keys = { profile = profile } }
    function db:SetProfile(n) self.keys.profile = n; self.sv.profileKeys[key] = n end
    self.db_registry[db] = true
    return db
end
function LibStub(name) if name == "AceDB-3.0" then return AceDB end end

-- "Loads" the addon + RXP the way the client does: our files, then RXP's
-- ADDON_LOADED (RXP calls AceDB:New after our handler), then entering world.
local frames
function CreateFrame()
    local f = { events = {} }
    function f:RegisterEvent(e) self.events[e] = true end
    function f:UnregisterEvent(e) self.events[e] = nil end
    function f:SetScript(_, fn) self.handler = fn end
    frames[#frames + 1] = f
    return f
end
local function Fire(e, ...) for _, f in ipairs(frames) do if f.events[e] then f.handler(f, e, ...) end end end
local function Flush() local t = W.timers W.timers = {} for _, fn in ipairs(t) do fn() end end

local rxpDB
local function Login(opts)
    opts = opts or {}
    frames = {}
    AceDB.db_registry = {}
    DuoSpinupCharDB = opts.charDB
    local ns = {}
    assert(loadfile(ADDON_DIR .. "Data.lua"))("DuoSpinup", ns)
    assert(loadfile(ADDON_DIR .. "DuoSpinup.lua"))("DuoSpinup", ns)
    Fire("ADDON_LOADED", "DuoSpinup")
    if opts.rxpFirst then rxpDB = AceDB:New("RXPSettings", {}) end -- RXP inits before our handler
    Fire("ADDON_LOADED", "RXPGuides")
    if not opts.rxpFirst then rxpDB = AceDB:New("RXPSettings", {}) end
    Fire("PLAYER_ENTERING_WORLD")
    Flush()
    return ns
end

local failures = 0
local function check(cond, msg)
    if not cond then failures = failures + 1; realprint("  FAIL " .. msg) else realprint("  ok   " .. msg) end
end
local function lastLog() return W.log[#W.log] or "" end

-- ------------------------------------------------------------ tests
realprint("fresh install, first login, files copied fine")
reset()
local D = {}
assert(loadfile(ADDON_DIR .. "Data.lua"))("DuoSpinup", D)
D = D.data
-- What the client loads from the copied bindings/macros files:
for _, kv in ipairs(D.binds) do W.bindings[kv[1]] = kv[2] ~= "NONE" and kv[2] or nil end
for _, m in ipairs(D.macros) do CreateMacro(m.name, m.icon, m.body) end
RXPSettings = nil
Login()
check(rxpDB.keys.profile == "Duo", "RXP starts on Duo at load (no reload)")
check(RXPSettings.profiles.Duo.autoSellJunk and RXPSettings.profiles.Duo.framePositions.RXPFrame, "Duo profile has Kaniken settings")
check(AceDB:New("Other", {}).keys.profile ~= "Duo", "AceDB hook removed, other addons unaffected")
check(W.bars and W.bars[1] and W.bars[2] and W.bars[3] and not W.bars[4], "bars on")
check(W.cvars.nameplateMaxDistance == "41" and W.cvars.questPOI == "0", "per-character settings")
check(W.setLayout == 3, "Edit Mode switched to 'main' (index 3)")
check(W.saved == nil, "binds left alone when file survived")
check(#W.macros == 4, "no duplicate macros")
check(DuoSpinupCharDB.done, "marked done")
check(lastLog():find("set up this character") and not lastLog():find("failed"), "one summary line, no errors: " .. lastLog())

realprint("server sync wiped binds + macros")
reset()
W.bindings = { E = "MOVEFORWARD" }
RXPSettings = nil
Login()
check(W.bindings.Z == "ACTIONBUTTON7" and W.bindings["7"] == nil and W.bindings.E == "ACTIONBUTTON11", "binds restored")
check(W.bindings["ALT--"] == "CLICK RXPInventory_DeleteJunk:LeftButton", "click bind restored")
check(W.saved == 1, "saved account-wide")
check(#W.macros == 4 and W.macros[GetMacroIndexByName("Target")].body == "/target party1", "macros recreated")
check(lastLog():find("binds restored"), "summary says binds restored")

realprint("RXP set up its database before us (load order)")
reset()
RXPSettings = nil
Login({ rxpFirst = true })
check(rxpDB.keys.profile == "Duo", "fallback switches RXP to Duo live")
check(AceDB:New("Other", {}).keys.profile ~= "Duo", "hook cleaned up")

realprint("existing character keeps its own RXP profile at load")
reset()
RXPSettings = { profileKeys = { ["New Char - PvE"] = "Mine" }, profiles = { Mine = {} } }
Login({ charDB = { done = true } })
check(rxpDB.keys.profile == "Mine", "done character untouched")
check(W.bars == nil and W.setLayout == nil, "no settings applied to done character")

realprint("user's tweaked Duo profile isn't overwritten")
reset()
RXPSettings = { profiles = { Duo = { autoSellJunk = false } } }
Login()
check(RXPSettings.profiles.Duo.autoSellJunk == false, "existing Duo kept")

realprint("missing Edit Mode layout")
reset()
W.layouts = {}
RXPSettings = nil
Login()
check(lastLog():find("not found"), "says layout not found")
check(W.bars ~= nil, "everything else still applied")

realprint("first login in combat")
reset()
W.combat = true
RXPSettings = nil
Login()
check(W.bars == nil, "nothing applied in combat")
W.combat = false
Fire("PLAYER_REGEN_ENABLED")
check(W.bars ~= nil and DuoSpinupCharDB.done, "applied after combat")

realprint("slash")
SlashCmdList.DUOSPINUP("")
check(lastLog():find("done on this character"), "status")
W.bars = nil
SlashCmdList.DUOSPINUP("redo")
check(W.bars ~= nil, "redo re-applies")

realprint(failures == 0 and "ALL PASS" or (failures .. " FAILURE(S)"))
if failures > 0 then error("tests failed") end
