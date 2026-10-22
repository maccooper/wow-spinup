-- DuoSpinup: applies your per-character setup automatically on a character's
-- first login. No commands, no reload. After that it leaves the character alone.
--   /spinup        show what it did on this character
--   /spinup redo   apply again on this character
-- Uses only standard addon API, never in combat.
local ADDON, ns = ...
local D = ns.data

local function say(msg, ...)
    print("|cff33ff99Spinup|r: " .. string.format(msg, ...))
end

local function copy(t)
    local out = {}
    for k, v in pairs(t) do out[k] = type(v) == "table" and copy(v) or v end
    return out
end

local firstRun = false

-- ---------------------------------------------------------------- RXP

local function AceDB()
    return LibStub and LibStub("AceDB-3.0", true)
end

-- Runs when RXP's saved settings are loaded but before RXP sets up its database:
-- adds the Duo profile and has AceDB start new characters on it.
local function PrepareRXP()
    local lib = AceDB()
    if not lib then return end
    _G.RXPSettings = _G.RXPSettings or {}
    local sv = _G.RXPSettings
    sv.profiles = sv.profiles or {}
    sv.profiles[D.rxpProfileName] = sv.profiles[D.rxpProfileName] or copy(D.rxpProfile)
    local orig = lib.New
    lib.New = function(self, tbl, defaults, defaultProfile)
        if tbl == "RXPSettings" or tbl == sv then
            lib.New = orig
            defaultProfile = D.rxpProfileName
        end
        return orig(self, tbl, defaults, defaultProfile)
    end
    ns.restoreAceDB = function() lib.New = orig end
end

local function RXPdb()
    local lib = AceDB()
    if not lib or not lib.db_registry or not _G.RXPSettings then return end
    for db in pairs(lib.db_registry) do
        if db.sv == _G.RXPSettings then return db end
    end
end

-- Returns a short result string.
local function ApplyRXP()
    if ns.restoreAceDB then ns.restoreAceDB() ns.restoreAceDB = nil end
    local db = RXPdb()
    if not db then return "RXP not loaded" end
    if db.keys.profile == D.rxpProfileName then return "RXP on Duo" end
    local sv = _G.RXPSettings
    sv.profiles[D.rxpProfileName] = sv.profiles[D.rxpProfileName] or copy(D.rxpProfile)
    db:SetProfile(D.rxpProfileName) -- fallback if we were too late to set it at load
    return "RXP switched to Duo"
end

-- ---------------------------------------------------------------- the rest

local function ApplyCVars()
    for k, v in pairs(D.cvars) do pcall(SetCVar, k, v) end
end

local function ApplyBars()
    local b = D.actionBars
    if SetActionBarToggles then
        SetActionBarToggles(b[1], b[2], b[3], b[4], true)
    else
        local bits = 0
        for i = 1, 4 do if b[i] then bits = bits + 2 ^ (i - 1) end end
        SetCVar("enableMultiActionBars", tostring(bits))
    end
    if MultiActionBar_Update then MultiActionBar_Update() end
end

local function ApplyEditMode()
    if not (C_EditMode and C_EditMode.GetLayouts and C_EditMode.SetActiveLayout) then
        return "no Edit Mode"
    end
    local info = C_EditMode.GetLayouts()
    local presets = Enum and Enum.EditModePresetLayoutsMeta and Enum.EditModePresetLayoutsMeta.NumValues or 2
    for i, layout in ipairs(info and info.layouts or {}) do
        if layout.layoutName == D.editModeLayout then
            local index = i + presets
            if info.activeLayout ~= index then C_EditMode.SetActiveLayout(index) end
            return "layout " .. D.editModeLayout
        end
    end
    return "|cffff5555layout '" .. D.editModeLayout .. "' not found|r (Edit Mode file not copied?)"
end

-- Only re-applies if the copied bindings file didn't survive.
local function ApplyBinds()
    local wrong = 0
    for _, kv in ipairs(D.binds) do
        local want = kv[2] == "NONE" and "" or kv[2]
        if (GetBindingAction(kv[1]) or "") ~= want then wrong = wrong + 1 end
    end
    if wrong == 0 then return "binds ok" end
    for _, kv in ipairs(D.binds) do
        SetBinding(kv[1], kv[2] ~= "NONE" and kv[2] or nil)
    end
    SaveBindings(ACCOUNT_BINDINGS or 1)
    return "binds restored (" .. wrong .. " were off)"
end

-- Only creates macros that are missing; never edits yours.
local function ApplyMacros()
    local made = 0
    for _, m in ipairs(D.macros) do
        local idx = GetMacroIndexByName(m.name)
        if not idx or idx == 0 then
            CreateMacro(m.name, m.icon, m.body, nil)
            made = made + 1
        end
    end
    return made == 0 and "macros ok" or ("made " .. made .. " missing macros")
end

local pending = {} -- work queued until combat ends

local function Run(fn)
    if InCombatLockdown() then
        table.insert(pending, fn)
        return
    end
    fn()
end

local function Step(fn)
    local ok, res = pcall(fn)
    if not ok then return "|cffff5555failed: " .. tostring(res) .. "|r" end
    return res
end

local function Apply()
    local results = {
        Step(function() ApplyCVars() ApplyBars() return "bars on" end),
        Step(ApplyEditMode),
        Step(ApplyBinds),
        Step(ApplyMacros),
        Step(ApplyRXP),
    }
    DuoSpinupCharDB.done = true
    DuoSpinupCharDB.results = results
    say("set up this character: %s", table.concat(results, ", "))
end

-- ---------------------------------------------------------------- events

local f = CreateFrame("Frame")
f:SetScript("OnEvent", function(_, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1 == ADDON then
            DuoSpinupCharDB = DuoSpinupCharDB or {}
            firstRun = not DuoSpinupCharDB.done
        elseif arg1 == "RXPGuides" and firstRun then
            pcall(PrepareRXP)
        end
    elseif event == "PLAYER_ENTERING_WORLD" then
        f:UnregisterEvent("PLAYER_ENTERING_WORLD")
        -- Edit Mode layouts finish loading just after entering the world.
        if firstRun then C_Timer.After(2, function() Run(Apply) end) end
    elseif event == "PLAYER_REGEN_ENABLED" then
        local queued = pending
        pending = {}
        for _, fn in ipairs(queued) do fn() end
    end
end)
f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("PLAYER_REGEN_ENABLED")

-- ---------------------------------------------------------------- slash

SLASH_DUOSPINUP1 = "/spinup"
SlashCmdList.DUOSPINUP = function(msg)
    if (msg or ""):lower():match("^%s*redo") then
        Run(Apply)
    elseif DuoSpinupCharDB.done then
        say("done on this character: %s", table.concat(DuoSpinupCharDB.results or {}, ", "))
    else
        say("not run yet on this character (/spinup redo to run now)")
    end
end
