# Installs the duo setup into a WoW folder. Run with the game CLOSED.
#   .\scripts\install.ps1                      # _forever_
#   .\scripts\install.ps1 -Flavor _classic_beta_
#   .\scripts\install.ps1 -Clean               # also remove junk + unwanted addons
#   .\scripts\install.ps1 -Accounts "80784825#1"   # which WTF\Account folders get the account files
param(
    [string]$Flavor = "_forever_",
    [string]$WowRoot = "C:\Program Files (x86)\World of Warcraft",
    [string[]]$Accounts = @("80784825#2", "80784825#3"),
    [switch]$Clean
)
$ErrorActionPreference = "Stop"
$Repo = Split-Path -Parent $PSScriptRoot
$Game = Join-Path $WowRoot $Flavor
$AddOns = Join-Path $Game "Interface\AddOns"
$Wtf = Join-Path $Game "WTF"

function Say($msg) { Write-Host "spinup: $msg" }

if (-not (Test-Path $Game)) { throw "WoW folder not found: $Game" }
# Only the client(s) running out of this folder matter (beta open doesn't block _forever_).
$Running = Get-Process -Name "Wow*" -ErrorAction SilentlyContinue | Where-Object {
    -not $_.Path -or $_.Path -like "$Game\*"
}
if ($Running) {
    throw "WoW ($Flavor) is running. Close every $Flavor client first (it overwrites settings on exit)."
}
New-Item -ItemType Directory -Force $AddOns, $Wtf | Out-Null

# 1. Backup WTF (small) before touching anything.
$Backups = Join-Path $Repo "backups"
New-Item -ItemType Directory -Force $Backups | Out-Null
$Stamp = Get-Date -Format "yyyyMMdd-HHmmss"
$BackupZip = Join-Path $Backups "WTF$Flavor$Stamp.zip"
if (Get-ChildItem $Wtf -ErrorAction SilentlyContinue) {
    Compress-Archive -Path (Join-Path $Wtf "*") -DestinationPath $BackupZip
    Say "backed up WTF -> $BackupZip"
}

# 2. Optional cleanup: zips, empty leftover folders, addons we dropped.
if ($Clean) {
    $Unwanted = @("SpeedrunSplits", "Details")
    Get-ChildItem $AddOns -Filter *.zip | ForEach-Object { Remove-Item $_.FullName; Say "removed $($_.Name)" }
    Get-ChildItem $AddOns -Directory | Where-Object {
        $Unwanted -contains $_.Name -or -not (Get-ChildItem $_.FullName -Recurse -File -ErrorAction SilentlyContinue)
    } | ForEach-Object { Remove-Item -Recurse -Force $_.FullName; Say "removed $($_.Name)\" }
}

# 3. Our addon (always replaced).
$Ours = Join-Path $AddOns "DuoSpinup"
if (Test-Path $Ours) { Remove-Item -Recurse -Force $Ours }
Copy-Item -Recurse (Join-Path $Repo "addon\DuoSpinup") $Ours
Say "installed DuoSpinup"

# 4. Merge safe client settings into Config.wtf (keeps portal/account lines the launcher wrote).
$ConfigPath = Join-Path $Wtf "Config.wtf"
$Lines = [System.Collections.Generic.List[string]]::new()
if (Test-Path $ConfigPath) { Get-Content $ConfigPath | ForEach-Object { $Lines.Add($_) } }
$Golden = Get-Content (Join-Path $Repo "golden\Config.wtf") | Where-Object { $_ -match '^SET (\S+) ' }
foreach ($g in $Golden) {
    $name = ($g -split ' ')[1]
    $pattern = "^SET $([regex]::Escape($name)) "
    $i = $Lines.FindIndex([Predicate[string]] { param($l) $l -match $pattern })
    if ($i -ge 0) { $Lines[$i] = $g } else { $Lines.Add($g) }
}
Set-Content -Path $ConfigPath -Value $Lines -Encoding ASCII
Say "merged $($Golden.Count) settings into Config.wtf"

# 5. Account files: binds, Edit Mode layout, macros, account settings, addon settings
#    (golden\account\SavedVariables\*) -> every listed account, same relative paths.
$AccountRoot = Join-Path $Repo "golden\account"
$AccountFiles = Get-ChildItem $AccountRoot -File -Recurse
foreach ($acct in $Accounts) {
    $dir = Join-Path $Wtf "Account\$acct"
    if (-not (Test-Path $dir)) {
        Say "WARNING: $acct has no folder yet (never logged in on this install). Creating it."
        New-Item -ItemType Directory -Force $dir | Out-Null
    }
    $names = foreach ($file in $AccountFiles) {
        $rel = $file.FullName.Substring($AccountRoot.Length + 1)
        $dest = Join-Path $dir $rel
        New-Item -ItemType Directory -Force (Split-Path -Parent $dest) | Out-Null
        Copy-Item $file.FullName $dest -Force
        $rel
    }
    Say "account $acct <- $($names -join ', ')"
}

# 6. Check required addons.
$Required = @("Questie", "QuestieDB", "RXPGuides", "RXPGuides_Custom", "Leatrix_Plus")
$Missing = $Required | Where-Object { -not (Test-Path (Join-Path $AddOns "$_\$_*.toc")) }
if ($Missing) {
    Say "MISSING addons: $($Missing -join ', ')"
    Say "  Questie/QuestieDB/RXPGuides/Leatrix_Plus: latest from CurseForge/GitHub into $AddOns"
    Say "  RXPGuides_Custom: git clone git@github.com:maccooper/RXPGuides_Custom.git into $AddOns"
} else {
    Say "required addons present: $($Required -join ', ')"
}

Say "done. Each new character sets itself up on first login (type /spinup to see what it did)."
