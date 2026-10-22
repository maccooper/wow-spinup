# wow-spinup

Snapshot of my WoW Forever beta settings, applied by a small addon on each character's first login. The point is a fresh-server setup on both duo accounts without logging out and re-queueing.

- `golden/`: files install copies into WTF (binds, Edit Mode layout "main", macros, account + graphics settings)
- `addon/DuoSpinup/`: runs once per character: bars 2–4, layout "main", per-character settings, RXP "Duo" profile, and restores binds/macros if the server wiped them
- `install.cmd`: game closed, backs up WTF, copies everything into accounts #2/#3

Launch: update Questie/QuestieDB/RXP → `install.cmd` → log in. Make sure "Load out of date AddOns" is ticked. Chat line `Spinup: set up this character: ...`: red means that step didn't apply. `/spinup redo` reruns it.

Quests: RXP shares guide quests and the follower auto-accepts them. Off route, turn on Questie → Auto Accept on the follower.

Notes:
- Lost layout: Edit Mode → Import `golden/editmode-main.txt`, name it **main**
- Undo install: unzip latest `backups/WTF_*.zip` over WTF
- Beta: `install.cmd -Flavor _classic_beta_ -Accounts 80784825#1`
- Tests: `cd tests && go run . addon_test.lua`
- Never call Blizzard UI code from the addon (it tainted `/camp`)
