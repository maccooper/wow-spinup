# wow-spinup

Every new character on the duo accounts comes up with your setup on its first login.
No clicking through settings, no relog, no /reload.

## Launch day

```
Before servers open (game closed, can be done days early):
  1. git pull
  2. double-click install.cmd          (install.cmd -Clean also removes zips/old addons)
  3. update Questie / QuestieDB / RXPGuides to latest; install says if any are missing

Servers up:
  4. log in, create characters, enter world. That's it.
     Chat shows one "Spinup: set up this character: ..." line per character.
```

Beta/testing: `install.cmd -Flavor _classic_beta_ -Accounts 80784825#1`

## What goes where

| Setting | How it gets there |
|---|---|
| Keybinds, Edit Mode layout "main", macros, account settings | `install` copies `golden/account/*` into accounts #2 and #3 |
| Graphics / sound | `install` merges `golden/Config.wtf` (never portal/account lines) |
| Bars on, layout "main" active, nameplate range, quest markers | DuoSpinup, on the character's first login |
| RXP settings (automation, junk, frame positions) | DuoSpinup starts new characters on RXP profile "Duo" |
| Binds/macros wiped by server sync | DuoSpinup notices on first login and restores them |

Macros use `party1`, so they work whatever your partner's name is: `Target`, `Follow`, `Sit`, `Dual`.

After the first login DuoSpinup never touches that character again. `/spinup` shows what it did, `/spinup redo` re-runs it.

## Files

| Path | What |
|---|---|
| `golden/account/` | Copied as-is into each account folder (byte-exact, see `.gitattributes`) |
| `golden/Config.wtf` | Safe client settings |
| `golden/editmode-main.txt` | Backup export of the "main" layout. If it's ever lost: Edit Mode → layout dropdown → Import, paste this |
| `addon/DuoSpinup/Data.lua` | Per-character settings, RXP profile, insurance copies of binds/macros |
| `scripts/install.ps1` | Backup WTF, copy everything, check addons |
| `tests/` | Addon run against a fake WoW API: `cd tests && go run . addon_test.lua` |

## Addons

Kept: Questie, QuestieDB, RXPGuides, RXPGuides_Custom (github.com/maccooper/RXPGuides_Custom).
Dropped: Leatrix Plus, SpeedrunSplits, Details.

## Ban safety

install only copies files while the game is closed. DuoSpinup only uses the standard addon API
(`SetCVar`, `SetActionBarToggles`, `C_EditMode.SetActiveLayout`, `SetBinding`, `CreateMacro`),
once per character, never in combat. It doesn't send keypresses or automate gameplay.

## To verify on beta

- [ ] `install.cmd -Flavor _classic_beta_ -Accounts 80784825#1`, make a fresh character
- [ ] Summary line has no red: bars on, layout main, RXP on Duo
- [ ] Binds + layout survive (summary says "binds ok", not "restored")
- [ ] RXP frames are where Kaniken had them without a reload
- [x] Export the "main" layout string from Edit Mode into `golden/editmode-main.txt` (backup)
