# wow-spinup

Turn a clean WoW Forever install into a ready-to-quest duo (leader + follower) in a couple of minutes.

## Launch-day flow

```
1. git pull                          # grab latest
2. ./scripts/install.sh              # game CLOSED: copies addons + settings into _forever_
3. Launch both clients, create both characters, enter world
4. Leader client:    /spinup leader
   Follower client:  /spinup follower
5. Invite → group. Partner names fill into macros automatically. Go quest.
```

Step 4 runs in-game on purpose. While WoW is running it owns its own files and
overwrites them on logout or `/reload`. A script run from outside can't change a
logged-in character, but an addon can.

## Layout

| Path | What | Runs |
|---|---|---|
| `golden/AddOns/` | Exact addon set (RXP, Questie, Leatrix, Details, custom guide) | copied by install |
| `golden/WTF/` | `Config.wtf` + account-wide addon settings (SavedVariables) | copied by install |
| `addon/DuoSpinup/` | Our addon: `/spinup leader\|follower` sets bars, macros, binds; fills partner names from party; places new spells as you learn them | in-game |
| `scripts/install.sh` | Backup, then copy `golden/` + `addon/` into the WoW folder | game closed |

## What lives where (why this split)

- **Files (install script):** addons, addon options, graphics/sound/camera settings.
- **In-game (DuoSpinup):** action bars (stored on Blizzard's servers, not in any file),
  macros and keybinds (synced with the server, so files may get overwritten),
  anything that depends on character names.

## Ban safety

The install script only copies files while the game is closed. DuoSpinup uses
only the standard addon API (`CreateMacro`, `SetBinding`, `PlaceAction`,
`SetCVar`), out of combat. It never sends keypresses and never reads game memory.

## Status

- [ ] Capture current setup into `golden/`
- [ ] `install.sh`
- [ ] DuoSpinup addon
- [ ] Test on a wiped copy of `_forever_` / on beta
