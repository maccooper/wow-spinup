-- Everything /spinup applies. Edit this file, not DuoSpinup.lua.
-- Source: beta character Kaniken-Justatest.
local _, ns = ...
local D = {}
ns.data = D

-- Same binds, same place, for both leader and follower.
-- Only keys that differ from WoW defaults. "NONE" = unbind.
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

-- Game settings (account + character). Graphics/sound live in golden/Config.wtf.
D.cvars = {
    cameraDistanceMaxZoomFactor = "2",
    cameraSmoothStyle = "0",
    ShakeStrengthCamera = "0",
    ShakeStrengthUI = "0",
    nameplateShowEnemies = "1",
    nameplateMaxDistance = "41",
    UnitNameInteractiveNPC = "0",
    UnitNameFriendlySpecialNPCName = "0",
    UnitNameHostleNPC = "0",
    enableLootToasts = "0",
    enableCollectionToasts = "0",
    enableLearnedRecipeToasts = "0",
    combinedBags = "1",
    showSwingTimer = "1",
    countdownForCooldowns = "1",
    AllowDangerousScripts = "1",
    showTutorials = "0",
    questPOI = "0",
    raidFramesDisplayClassColor = "1",
    raidFramesDisplayPowerBars = "1",
}

-- Bottom-left, bottom-right, right bars shown (was enableMultiActionBars "7").
D.actionBars = { true, true, true, false }

-- Account macros. {{PARTNER}} = the other character's full "First Last" name,
-- filled in automatically when you group (or /spinup partner First Last).
D.macros = {
    { name = "DS Target", icon = 134400, body = "/target {{PARTNER}}" },
    { name = "DS Follow", icon = 136138, body = "/follow {{PARTNER}}" },
    { name = "DS Sit",    icon = 134331, body = "/sit" },
    { name = "Dual",      icon = 132319, body = "/castsequence Find Herbs, Find Minerals" },
}

-- RXP settings that differ from RXP defaults (Kaniken's profile).
-- Written into an RXP profile called "Duo" and selected for this character.
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

-- Action bar layouts per class: [slot] = { spell = "Name" } | { macro = "Name" } | { item = id }
-- Slots 1-12 main bar, 13-24 page 2, 25-36 right, 37-48 right 2,
-- 49-60 bottom right, 61-72 bottom left, 73-84 rogue stealth / druid cat,
-- 97-108 druid bear.
-- Spells you haven't learned yet are skipped and placed the moment you learn them.
D.layouts = {
    ROGUE = {
        -- TODO: fill from /spinup capture on Kaniken-Justatest (beta)
    },
    DRUID = {
        -- TODO: build together
    },
}
