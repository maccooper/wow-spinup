-- What DuoSpinup applies on a character's first login. Edit this, not DuoSpinup.lua.
-- Source: beta character Kaniken-Justatest.
-- Account-wide stuff (binds, Edit Mode layout, macros, account settings) is copied as
-- files by install.ps1; the binds/macros here are only re-applied if the server sync
-- overwrote those files.
local _, ns = ...
local D = {}
ns.data = D

-- Per-character settings (each new character starts at defaults for these).
D.cvars = {
    nameplateMaxDistance = "41",
    questPOI = "0",
    raidFramesDisplayClassColor = "1",
    raidFramesDisplayPowerBars = "1",
    minimapZoom = "5",
}

-- Action Bars 2-8 shown (Kaniken: enableMultiActionBars "7" = bars 2, 3, 4).
--                bar2  bar3  bar4  bar5   bar6   bar7   bar8
D.actionBars = { true, true, true, false, false, false, false }

-- Always auto-accept quests shared by a party member (hold Shift to skip).
-- NPC quests: RXP auto-accepts only the ones on your current guide step.
D.autoAcceptShared = true

-- Edit Mode layout to switch to (lives in edit-mode-cache-account.txt).
D.editModeLayout = "main"

-- RXP settings that differ from RXP defaults (Kaniken's profile).
-- New characters start on an RXP profile with this name.
D.rxpProfileName = "Duo"
D.rxpProfile = {
    enableTrainerAutomation = true,
    enableQuestRewardAutomation = true,
    shareQuests = true,
    autoSellJunk = true,
    autoDiscardItems = true,
    rightClickJunk = true,
    showJunkIcon = true,
    season = 0,
    dungeons = { DM = true, STOCKS = true },
    frameHeight = 180.8333129882813,
    frameSizes = {
        arrowFrame = { 32, 32 },
        RXPFrame = { 271, 180.8333129882813 },
        activeItemFrame = { 79.1665267944336, 43 },
        activeTargetFrame = { 84, 43 },
    },
    framePositions = {
        arrowFrame = { { "BOTTOM", nil, "BOTTOM", -34, 229 } },
        RXPFrame = { { "LEFT", nil, "LEFT", 56, -93 } },
        activeItemFrame = { { "RIGHT", nil, "RIGHT", -200, 12 } },
        activeTargetFrame = { { "RIGHT", nil, "RIGHT", -417, -217 } },
    },
}

-- Insurance copies of golden/account/macros-cache.txt and bindings-cache.wtf.
-- Only used if those files got overwritten by the server. Keep them in sync.
D.macros = {
    { name = "Target", icon = 134400, body = "/target party1" },
    { name = "Follow", icon = 136138, body = "/follow party1" },
    { name = "Sit",    icon = 134331, body = "/sit" },
    { name = "Dual",   icon = 132319, body = "/castsequence Find Herbs, Find Minerals" },
}

-- "NONE" = unbound. Only keys that differ from WoW defaults.
D.binds = {
    { "DOWN", "NONE" },
    { "E", "ACTIONBUTTON11" },
    { "X", "ACTIONBUTTON8" },
    { "Z", "ACTIONBUTTON7" },
    { "NUMLOCK", "NONE" },
    { "7", "NONE" },
    { "8", "NONE" },
    { "9", "NONE" },
    { "0", "NONE" },
    { "-", "NONE" },
    { "=", "TOGGLEAUTORUN" },
    { "CTRL-F1", "NONE" },
    { "SHIFT-1", "MULTIACTIONBAR1BUTTON1" },
    { "SHIFT-2", "MULTIACTIONBAR1BUTTON2" },
    { "SHIFT-3", "MULTIACTIONBAR1BUTTON3" },
    { "SHIFT-4", "MULTIACTIONBAR1BUTTON4" },
    { "SHIFT-5", "MULTIACTIONBAR1BUTTON5" },
    { "SHIFT-6", "MULTIACTIONBAR1BUTTON6" },
    { "SHIFT-UP", "NONE" },
    { "SHIFT-MOUSEWHEELUP", "NONE" },
    { "SHIFT-DOWN", "NONE" },
    { "SHIFT-MOUSEWHEELDOWN", "NONE" },
    { "F1", "MULTIACTIONBAR3BUTTON1" },
    { "F2", "MULTIACTIONBAR3BUTTON2" },
    { "F3", "MULTIACTIONBAR3BUTTON3" },
    { "F4", "MULTIACTIONBAR3BUTTON4" },
    { "F5", "MULTIACTIONBAR3BUTTON5" },
    { "G", "MULTIACTIONBAR3BUTTON7" },
    { "V", "ACTIONBUTTON10" },
    { "SHIFT-V", "MULTIACTIONBAR1BUTTON10" },
    { "CTRL-V", "NONE" },
    { "T", "ACTIONBUTTON12" },
    { "SHIFT-T", "MULTIACTIONBAR1BUTTON12" },
    { "C", "ACTIONBUTTON9" },
    { "B", "OPENALLBAGS" },
    { "SHIFT-B", "NONE" },
    { "SHIFT-C", "MULTIACTIONBAR1BUTTON9" },
    { "SHIFT-Z", "MULTIACTIONBAR1BUTTON7" },
    { "SHIFT-X", "MULTIACTIONBAR1BUTTON8" },
    { "ALT-E", "MULTIACTIONBAR2BUTTON1" },
    { "SHIFT-G", "MULTIACTIONBAR3BUTTON6" },
    { "SHIFT-=", "NAMEPLATES" },
    { "CTRL-Z", "MULTIACTIONBAR2BUTTON9" },
    { "SHIFT-E", "MULTIACTIONBAR1BUTTON11" },
    { "SHIFT-F", "MULTIACTIONBAR3BUTTON8" },
    { ";", "QUESTIE_TOGGLE_JOURNEY" },
    { "`", "MULTIACTIONBAR2BUTTON2" },
    { "ALT-1", "MULTIACTIONBAR2BUTTON3" },
    { "ALT--", "CLICK RXPInventory_DeleteJunk:LeftButton" },
}
