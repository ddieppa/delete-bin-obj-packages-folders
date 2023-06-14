@echo off
Powershell.exe -executionpolicy remotesigned -File  %~dp0\delete_folders.ps1
pause
