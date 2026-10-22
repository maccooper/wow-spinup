-- Runs DuoSpinup against a fake WoW API. From the repo root:
--   cd tests && go run . addon_test.lua
local ADDON_DIR = "../addon/DuoSpinup/"

-- ------------------------------------------------------------ fake WoW state
local W = {
    cvars = {}, binds = {}, saved = 0, actions = {}, macros = {}, cursor = nil,
    combat = false, group = {}, timers = {}, popups = {}, reloads = 0, bars = nil,
    log = {},
    known = { -- name -> highest known spell id
        ["Sinister Strike"] = 1757, ["Eviscerate"] = 6760, ["Stealth"] = 1784,
    },
    names = { [1752] = "Sinister Strike", [1757] = "Sinister Strike", [2098] = "Eviscerate",
        [6760] = "Eviscerate", [1784] = "Stealth", [53] = "Backstab", [921] = "Pick Pocket" },
}
local ids = { ["Sinister Strike"] = 1757, Eviscerate = 6760, Stealth = 1784, Backstab = 53, ["Pick Pocket"] = 921 }

function print(...) local t = {} for i = 1, select("#", ...) do t[#t + 1] = tostring(select(i, ...)) end
    W.log[#W.log + 1] = table.concat(t, " ") end
local realprint = _G.io and function(s) io.write(s, "\n") end

ACCOUNT_BINDINGS = 1
SlashCmdList = {}
StaticPopupDialogs = {}
function StaticPopup_Show(n) W.popups[#W.popups + 1] = n end
function ReloadUI() W.reloads = W.reloads + 1 end
function SetCVar(k, v) W.cvars[k] = v end
function SetBinding(k, a) W.binds[k] = a or "UNBOUND"; return true end
function SaveBindings(set) W.saved = set end
function SetActionBarToggles(a, b, c, d) W.bars = { a, b, c, d } end
function MultiActionBar_Update() end
function InCombatLockdown() return W.combat end
function UnitClass() return "Rogue", "ROGUE" end
function UnitName(u) if u == "player" then return "Kaniken" end return W.group[u] end
function IsInGroup() return W.group.party1 ~= nil end
function GetNumGroupMembers() return W.group.party1 and 2 or 0 end
C_Timer = { After = function(_, fn) W.timers[#W.timers + 1] = fn end }
C_Spell = {
    GetSpellInfo = function(x)
        local id = type(x) == "number" and x or (W.known[x] or ids[x])
        if not id or not W.names[id] then return nil end
        return { name = W.names[id], spellID = id }
    end,
    PickupSpell = function(id) W.cursor = { "spell", id } end,
}
function IsPlayerSpell(id) for _, k in pairs(W.known) do if k == id then return true end end return false end
C_Item = { GetItemCount = function() return 0 end, GetItemNameByID = function() return "Item" end }
function GetCursorInfo() return W.cursor and W.cursor[1] end
function ClearCursor() W.cursor = nil end
function PlaceAction(slot) local old = W.actions[slot]; W.actions[slot] = W.cursor; W.cursor = old end
function GetActionInfo(slot) local a = W.actions[slot] if a then return a[1], a[2] end end
function GetMacroIndexByName(n) for i, m in ipairs(W.macros) do if m.name == n then return i end end return 0 end
function CreateMacro(n, icon, body) W.macros[#W.macros + 1] = { name = n, icon = icon, body = body } return #W.macros end
function EditMacro(i, n, icon, body) W.macros[i] = { name = n, icon = icon, body = body } end
function GetMacroInfo(i) local m = W.macros[i] return m.name, m.icon, m.body end
function PickupMacro(i) W.cursor = { "macro", i } end
function PickupItem(id) W.cursor = { "item", id } end

local knownEvents = { ADDON_LOADED = 1, PLAYER_LOGIN = 1, PLAYER_REGEN_ENABLED = 1, GROUP_ROSTER_UPDATE = 1,
    SPELLS_CHANGED = 1, LEARNED_SPELL_IN_TAB = 1, BAG_UPDATE_DELAYED = 1 } -- no LEARNED_SPELL_IN_SKILL_LINE
local frames = {}
function CreateFrame()
    local f = { events = {} }
    function f:RegisterEvent(e) if not knownEvents[e] then error("unknown event " .. e) end self.events[e] = true end
    function f:SetScript(_, fn) self.handler = fn end
    frames[#frames + 1] = f
    return f
end
local function Fire(e, ...) for _, f in ipairs(frames) do if f.events[e] then f.handler(f, e, ...) end end end
local function Flush() local t = W.timers W.timers = {} for _, fn in ipairs(t) do fn() end end

-- fake RXP + AceDB
RXPSettings = { profileKeys = { ["Kaniken Justatest"] = "Kaniken Justatest" }, profiles = {} }
local rxpdb = { sv = RXPSettings }
function rxpdb:SetProfile(n) self.current = n end
local AceDB = { db_registry = { [rxpdb] = true } }
function LibStub(name) if name == "AceDB-3.0" then return AceDB end end

-- ------------------------------------------------------------ load addon
local ns = {}
assert(loadfile(ADDON_DIR .. "Data.lua"))("DuoSpinup", ns)
assert(loadfile(ADDON_DIR .. "DuoSpinup.lua"))("DuoSpinup", ns)
ns.data.layouts.ROGUE = {
    [1] = { spell = "Sinister Strike" }, [2] = { spell = "Eviscerate" }, [3] = { spell = "Backstab" },
    [10] = { macro = "DS Target" }, [11] = { macro = "DS Follow" }, [12] = { item = 6948 },
    [73] = { spell = "Pick Pocket" },
}

local failures = 0
local function check(cond, msg)
    if not cond then failures = failures + 1; realprint("  FAIL " .. msg) else realprint("  ok   " .. msg) end
end
local function slash(s) SlashCmdList.DUOSPINUP(s) end

-- ------------------------------------------------------------ tests
realprint("login")
Fire("ADDON_LOADED", "DuoSpinup")
Fire("PLAYER_LOGIN")
check(DuoSpinupCharDB and DuoSpinupDB, "saved vars created")
check(W.log[#W.log]:find("/spinup leader"), "new character hint printed")

realprint("/spinup leader (no partner yet)")
W.actions[1] = { "spell", 1752 } -- rank 1 Sinister Strike already on bar
W.actions[2] = { "spell", 9999 } -- something else the player put there
slash("leader")
check(DuoSpinupCharDB.role == "leader", "role saved")
check(W.cvars.showSwingTimer == "1" and W.cvars.questPOI == "0", "cvars set")
check(W.binds.E == "ACTIONBUTTON11" and W.binds["7"] == "UNBOUND", "binds set / unbound")
check(W.binds["ALT--"] == "CLICK RXPInventory_DeleteJunk:LeftButton", "click bind")
check(W.saved == 1, "binds saved account-wide")
check(W.bars and W.bars[1] and W.bars[3] and not W.bars[4], "bars toggled")
local t = W.macros[GetMacroIndexByName("DS Target")]
check(t and t.body == "/target", "target macro valid without partner: " .. tostring(t and t.body))
check(W.actions[1][2] == 1757, "spell rank upgraded on bar")
check(W.actions[2][2] == 9999, "player's own action left alone")
check(W.actions[3] == nil, "unlearned Backstab skipped")
check(W.actions[10] and W.actions[10][1] == "macro", "macro placed")
check(W.actions[12] == nil, "item not in bags skipped")
check(rxpdb.current == "Duo" and RXPSettings.profiles.Duo.autoSellJunk, "RXP Duo profile selected")
check(RXPSettings.profiles.Duo.framePositions ~= ns.data.rxpProfile.framePositions, "RXP profile deep-copied")
check(W.popups[1] == "DUOSPINUP_RELOAD", "reload prompt shown")

realprint("group with partner")
W.group.party1 = "Summer Bass"
Fire("GROUP_ROSTER_UPDATE")
check(DuoSpinupCharDB.partner == "Summer Bass", "partner from party")
check(W.macros[GetMacroIndexByName("DS Target")].body == "/target Summer Bass", "target macro filled")
check(W.macros[GetMacroIndexByName("DS Follow")].body == "/follow Summer Bass", "follow macro filled")
check(#W.macros == 4, "no duplicate macros (" .. #W.macros .. ")")

realprint("learn Backstab in combat")
W.combat = true
W.known.Backstab = 53
Fire("SPELLS_CHANGED")
Fire("LEARNED_SPELL_IN_TAB")
check(#W.timers == 1, "learn events throttled to one timer")
Flush()
check(W.actions[3] == nil, "not placed during combat")
W.combat = false
Fire("PLAYER_REGEN_ENABLED")
check(W.actions[3] and W.actions[3][2] == 53, "placed after combat")

realprint("manual partner + off")
slash("partner Winter Squid")
check(W.macros[GetMacroIndexByName("DS Target")].body == "/target Winter Squid", "manual partner")
W.group.party1 = "Someone Else"
Fire("GROUP_ROSTER_UPDATE")
check(DuoSpinupCharDB.partner == "Winter Squid", "manual partner not overwritten by party")
slash("off")
W.known["Pick Pocket"] = 921
Fire("SPELLS_CHANGED")
Flush()
check(W.actions[73] == nil, "off: nothing placed")
slash("on")
Flush()
check(W.actions[73] and W.actions[73][2] == 921, "on: placed")

realprint("capture + status")
slash("capture")
local cap = DuoSpinupDB.captures["Kaniken ROGUE"]
check(cap and cap[1].spell == "Sinister Strike" and cap[10].macro == "DS Target", "capture recorded")
check(cap[10].body == "/target Winter Squid", "capture includes macro body")
slash("status")
check(W.log[#W.log]:find("role=leader"), "status prints")
slash("")
check(W.log[#W.log]:find("/spinup leader | follower"), "help prints")

realprint("idempotent re-run")
local before = #W.macros
slash("leader")
check(#W.macros == before, "re-run makes no new macros")

for _, l in ipairs(W.log) do if l:find("failed") then failures = failures + 1; realprint("  FAIL addon error: " .. l) end end
realprint(failures == 0 and "ALL PASS" or (failures .. " FAILURE(S)"))
if failures > 0 then error("tests failed") end
