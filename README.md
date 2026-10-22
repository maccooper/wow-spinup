# wow-spinup

Turn a clean WoW Forever install into a ready-to-quest duo (rogue leader + druid follower) in a couple of minutes.

## Launch-day flow

```
1. git pull
2. Close WoW. Double-click install.cmd           (or: install.cmd -Clean to also wipe junk/old addons)
3. Make sure Questie, QuestieDB, RXPGuides (latest) and RXPGuides_Custom are in AddOns. install tells you what's missing.
4. Launch both clients, create both characters, enter world
5. Rogue:  /spinup leader     Druid:  /spinup follower      -> click Reload when asked
6. Invite -> group. Partner name fills into the macros automatically. Go.
```

Beta/testing: `install.cmd -Flavor _classic_beta_`

## In-game commands

| Command | Does |
|---|---|
| `/spinup leader` / `/spinup follower` | Binds, game settings, macros, action bars, RXP "Duo" profile |
| `/spinup partner First Last` | Set partner by hand (normally automatic from your party) |
| `/spinup partner` | Back to automatic |
| `/spinup capture` | Record this character's bars (to build a layout). /reload after so it saves. |
| `/spinup status` / `off` / `on` | Check state / stop or resume auto bar placement |

After spinup, new spells go into their planned slot as you learn them. Higher ranks replace lower ones in our slots.
The addon never overwrites a slot you filled yourself.

## Files

| Path | What |
|---|---|
| `addon/DuoSpinup/Data.lua` | **The setup**: binds, game settings, macros, RXP settings, bar layouts per class. Edit this. |
| `addon/DuoSpinup/DuoSpinup.lua` | The addon logic |
| `golden/Config.wtf` | Safe graphics/sound settings, merged into the live Config.wtf (never portal/account lines) |
| `scripts/install.ps1` | Backup WTF -> install DuoSpinup -> merge Config.wtf -> check addons |
| `tests/` | Runs the addon against a fake WoW API: `cd tests && go run . addon_test.lua` |

## Addons

Kept: Questie, QuestieDB, RXPGuides, RXPGuides_Custom (github.com/maccooper/RXPGuides_Custom).
Dropped: Leatrix Plus, SpeedrunSplits, Details. RXP's quest automation and junk selling cover the parts of Leatrix you used.

## Ban safety

install only copies files while the game is closed. DuoSpinup only calls the standard addon API
(`SetBinding`, `CreateMacro`, `PlaceAction`, `SetCVar`), never in combat, and only when you type a command or learn a spell.
It doesn't send keypresses and doesn't automate gameplay.

## Status

- [x] Binds, settings, macros, RXP profile from Kaniken-Justatest
- [x] install script + addon, tested against fakes
- [ ] Rogue bar layout: `/spinup capture` on Kaniken (beta)
- [ ] Druid bar layout: build together
- [ ] Real test on beta: fresh characters, check server sync doesn't undo binds/macros
