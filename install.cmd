@echo off
rem Double-click to install into _forever_. Pass -Flavor _classic_beta_ or -Clean as needed.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\install.ps1" %*
pause
