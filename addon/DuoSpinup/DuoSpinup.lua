-- DuoSpinup: one command per character to apply the duo setup.
--   /spinup leader | follower   apply binds, settings, macros, bars, RXP profile
--   /spinup partner First Last  change partner (auto-set and locked on first 2-person group)
--   /spinup capture             record this character's action bars (for building layouts)
--   /spinup status | off | on
-- Uses only standard addon API, never in combat.
local ADDON, ns = ...
local D = ns.data

local function say(msg, ...)
    print("|cff33ff99Spinup|r: " .. string.format(msg, ...))
end

-- ---------------------------------------------------------------- API compat

local function SpellInfo(x)
    if C_Spell and C_Spell.GetSpellInfo then
        local i = C_Spell.GetSpellInfo(x)
        if i then return i.name, i.spellID end
    elseif GetSpellInfo then
        local name, _, _, _, _, _, id = GetSpellInfo(x)
        return name, id
    end
end

local function Known(id)
    if not id then return false end
    if IsPlayerSpell and IsPlayerSpell(id) then return true end
    return IsSpellKnown and IsSpellKnown(id) or false
end

local function PickupSpellID(id)
    if C_Spell and C_Spell.PickupSpell then C_Spell.PickupSpell(id) else PickupSpell(id) end
end

local function ItemName(id)
    if C_Item and C_Item.GetItemNameByID then return C_Item.GetItemNameByID(id) end
    return GetItemInfo and (GetItemInfo(id))
end

local function ItemCount(id)
    if C_Item and C_Item.GetItemCount then return C_Item.GetItemCount(id) end
    return GetItemCount and GetItemCount(id) or 0
end

-- ---------------------------------------------------------------- steps

local function ApplyCVars()
    local n = 0
    for k, v in pairs(D.cvars) do
        if pcall(SetCVar, k, v) then n = n + 1 end
    end
    if SetActionBarToggles then
        local b = D.actionBars
        SetActionBarToggles(b[1], b[2], b[3], b[4], true)
        if MultiActionBar_Update then MultiActionBar_Update() end
    end
    return n
end

local function ApplyBinds()
    local n = 0
    for _, kv in ipairs(D.binds) do
        local key, action = kv[1], kv[2]
        if action == "NONE" then action = nil end
        if SetBinding(key, action) then n = n + 1 end
    end
    SaveBindings(ACCOUNT_BINDINGS or 1)
    return n
end

local function MacroBody(body)
    local partner = DuoSpinupCharDB.partner
    if body:find("{{PARTNER}}", 1, true) then
        if not partner then
            -- Keep it valid until we know the name.
            return (body:gsub(" ?{{PARTNER}}", ""))
        end
        return (body:gsub("{{PARTNER}}", partner))
    end
    return body
end

local function ApplyMacros()
    local n = 0
    for _, m in ipairs(D.macros) do
        local body = MacroBody(m.body)
        local idx = GetMacroIndexByName(m.name)
        if idx and idx > 0 then
            EditMacro(idx, m.name, m.icon, body)
        else
            CreateMacro(m.name, m.icon, body, nil)
        end
        n = n + 1
    end
    return n
end

local function PutOnSlot(slot)
    if GetCursorInfo() then
        PlaceAction(slot)
    end
    ClearCursor()
end

-- Places layout actions into empty slots; upgrades spell ranks it put there.
-- Returns placed, waiting (not learned / not in bags yet).
local function ApplyLayout()
    local _, class = UnitClass("player")
    local layout = D.layouts[class]
    if not layout then return 0, 0 end
    local placed, waiting = 0, 0
    ClearCursor()
    for slot, e in pairs(layout) do
        local t, id = GetActionInfo(slot)
        if e.spell then
            local name, best = SpellInfo(e.spell)
            if best and Known(best) then
                local upgrade = t == "spell" and id ~= best and SpellInfo(id) == name
                if not t or upgrade then
                    PickupSpellID(best)
                    PutOnSlot(slot)
                    placed = placed + 1
                end
            elseif not t then
                waiting = waiting + 1
            end
        elseif e.macro and not t then
            local idx = GetMacroIndexByName(e.macro)
            if idx and idx > 0 then
                PickupMacro(idx)
                PutOnSlot(slot)
                placed = placed + 1
            end
        elseif e.item and not t then
            if ItemCount(e.item) > 0 then
                PickupItem(e.item)
                PutOnSlot(slot)
                placed = placed + 1
            else
                waiting = waiting + 1
            end
        end
    end
    return placed, waiting
end

-- Point RXP at a "Duo" profile through AceDB's own API.
local function ApplyRXP()
    local sv = _G.RXPSettings
    local AceDB = LibStub and LibStub("AceDB-3.0", true)
    if not sv or not AceDB or not AceDB.db_registry then return false end
    local db
    for obj in pairs(AceDB.db_registry) do
        if obj.sv == sv then db = obj break end
    end
    if not db then return false end
    local function copy(t)
        local out = {}
        for k, v in pairs(t) do out[k] = type(v) == "table" and copy(v) or v end
        return out
    end
    sv.profiles = sv.profiles or {}
    sv.profiles[D.rxpProfileName] = copy(D.rxpProfile)
    db:SetProfile(D.rxpProfileName)
    return true
end

-- ---------------------------------------------------------------- flow

local pending = {} -- work queued until combat ends

local function Run(fn)
    if InCombatLockdown() then
        table.insert(pending, fn)
        say("in combat, will finish when combat ends")
        return
    end
    fn()
end

local function Step(label, fn)
    local ok, a, b = pcall(fn)
    if not ok then
        say("|cffff5555%s failed:|r %s", label, tostring(a))
    end
    return ok, a, b
end

StaticPopupDialogs["DUOSPINUP_RELOAD"] = {
    text = "DuoSpinup: reload UI to load the RXP Duo profile?",
    button1 = "Reload",
    button2 = "Later",
    OnAccept = function() ReloadUI() end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
}

local function Spinup(role)
    DuoSpinupCharDB.role = role
    DuoSpinupCharDB.disabled = nil
    local _, nC = Step("settings", ApplyCVars)
    local _, nB = Step("binds", ApplyBinds)
    local _, nM = Step("macros", ApplyMacros)
    local _, placed, waiting = Step("bars", ApplyLayout)
    local _, rxp = Step("RXP", ApplyRXP)
    say("%s: %d settings, %d binds, %d macros, %d bar slots (%d waiting to learn)",
        role, nC or 0, nB or 0, nM or 0, placed or 0, waiting or 0)
    if not DuoSpinupCharDB.partner then
        say("partner locks to the first person you group with (or /spinup partner First Last)")
    end
    if rxp then
        StaticPopup_Show("DUOSPINUP_RELOAD")
    else
        say("RXP not found, skipped its profile")
    end
end

-- Partner is locked once set; only /spinup partner changes it.
local function SetPartner(name)
    if not name or name == "" or name == DuoSpinupCharDB.partner then return end
    DuoSpinupCharDB.partner = name
    Run(function()
        if Step("macros", ApplyMacros) then
            say("partner locked: %s (change with /spinup partner First Last)", name)
        end
    end)
end

local function Capture()
    local _, class = UnitClass("player")
    local out = {}
    local n = 0
    for slot = 1, 120 do
        local t, id = GetActionInfo(slot)
        if t == "spell" then
            out[slot] = { spell = SpellInfo(id), id = id }
        elseif t == "macro" then
            local name, _, body = GetMacroInfo(id)
            out[slot] = { macro = name, body = body }
        elseif t == "item" then
            out[slot] = { item = id, name = ItemName(id) }
        elseif t then
            out[slot] = { other = t, id = id }
        end
        if t then n = n + 1 end
    end
    DuoSpinupDB.captures = DuoSpinupDB.captures or {}
    DuoSpinupDB.captures[UnitName("player") .. " " .. class] = out
    say("captured %d slots for %s. Log out (or /reload) so it saves to disk.", n, class)
end

-- ---------------------------------------------------------------- events

local f = CreateFrame("Frame")
local layoutQueued = false

local function QueueLayout()
    if layoutQueued or not DuoSpinupCharDB.role or DuoSpinupCharDB.disabled then return end
    layoutQueued = true
    C_Timer.After(1, function()
        layoutQueued = false
        if DuoSpinupCharDB.disabled then return end
        Run(function()
            local ok, placed = Step("bars", ApplyLayout)
            if ok and placed > 0 then say("placed %d new action(s)", placed) end
        end)
    end)
end

-- First 2-person group sets the partner; after that grouping never changes it.
local function GroupChanged()
    if DuoSpinupCharDB.partner or DuoSpinupCharDB.disabled then return end
    if IsInGroup() and GetNumGroupMembers() == 2 then
        SetPartner(UnitName("party1"))
    end
end

f:SetScript("OnEvent", function(_, event, arg1)
    if event == "ADDON_LOADED" and arg1 == ADDON then
        DuoSpinupDB = DuoSpinupDB or {}
        DuoSpinupCharDB = DuoSpinupCharDB or {}
    elseif event == "PLAYER_LOGIN" then
        if not DuoSpinupCharDB.role then
            say("new character: type /spinup leader or /spinup follower")
        end
        QueueLayout()
        GroupChanged()
    elseif event == "PLAYER_REGEN_ENABLED" then
        local queued = pending
        pending = {}
        for _, fn in ipairs(queued) do fn() end
    elseif event == "GROUP_ROSTER_UPDATE" then
        GroupChanged()
    else
        QueueLayout() -- learned a spell / bags changed
    end
end)

for _, e in ipairs({ "ADDON_LOADED", "PLAYER_LOGIN", "PLAYER_REGEN_ENABLED", "GROUP_ROSTER_UPDATE",
    "SPELLS_CHANGED", "LEARNED_SPELL_IN_TAB", "LEARNED_SPELL_IN_SKILL_LINE", "BAG_UPDATE_DELAYED" }) do
    pcall(f.RegisterEvent, f, e) -- some events don't exist on every client
end

-- ---------------------------------------------------------------- slash

SLASH_DUOSPINUP1 = "/spinup"
SlashCmdList.DUOSPINUP = function(msg)
    local cmd, rest = (msg or ""):match("^%s*(%S*)%s*(.-)%s*$")
    cmd = cmd:lower()
    if cmd == "leader" or cmd == "follower" then
        Run(function() Spinup(cmd) end)
    elseif cmd == "partner" then
        if rest == "" then
            DuoSpinupCharDB.partner = nil
            say("partner cleared: next 2-person group sets it")
            GroupChanged()
        else
            SetPartner(rest)
        end
    elseif cmd == "capture" then
        Capture()
    elseif cmd == "off" then
        DuoSpinupCharDB.disabled = true
        say("off: no more automatic bar placement or macro updates on this character")
    elseif cmd == "on" then
        DuoSpinupCharDB.disabled = nil
        say("on")
        QueueLayout()
    elseif cmd == "status" then
        local _, class = UnitClass("player")
        local layout = D.layouts[class]
        local count = 0
        for _ in pairs(layout or {}) do count = count + 1 end
        say("role=%s partner=%s class=%s layout slots=%d%s", tostring(DuoSpinupCharDB.role),
            tostring(DuoSpinupCharDB.partner), class, count, DuoSpinupCharDB.disabled and " (off)" or "")
    else
        say("/spinup leader | follower | partner First Last | capture | status | off | on")
    end
end
