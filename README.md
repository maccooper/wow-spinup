# wow-spinup

New characters on the duo accounts (#2, #3) get your full setup on first login: no clicking, no relog, no reload.

## Launch day

1. Game closed: update Questie, QuestieDB, RXPGuides (CurseForge app, Forever install).
2. Double-click `install.cmd`. It backs up `WTF` and tells you if an addon is missing.
3. Log in, create characters, play. Chat prints `Spinup: set up this character: ...`. Anything red didn't apply.

At character select, make sure **Load out of date AddOns** is ticked.

## What you get

- **Files** (copied by install from `golden/`): keybinds, Edit Mode layout "main", macros (`Target`/`Follow` use `party1`, so no names needed), account settings, graphics/sound.
- **DuoSpinup** (once per character, then never again): bars 2–4 on, layout "main", per-character settings, RXP profile "Duo". It also restores binds/macros if the server wiped them.
- **Quests** (RXP, already configured): the leader's guide quests get shared, and the follower accepts them. Off route nothing is automatic. To take everything, tick Questie → Auto → Auto Accept Quests on the follower.

`/spinup` shows what it did; `/spinup redo` runs it again.

## If something's off

- Layout lost: Edit Mode → Import → paste `golden/editmode-main.txt`, save as **main**.
- Undo an install: unzip the latest `backups/WTF_*.zip` over `WTF` (game closed).
- Beta: `install.cmd -Flavor _classic_beta_ -Accounts 80784825#1`

## Editing

- Settings applied in game: `addon/DuoSpinup/Data.lua`. Copied files: `golden/`.
- Tests (fake WoW API): `cd tests && go run . addon_test.lua`
- DuoSpinup only calls the game's own API, never Blizzard UI code (that tainted `/camp` once), and never in combat.
