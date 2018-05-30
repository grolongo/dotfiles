@if (@Author)==(@AveYo) @end /* LnkAllToStart v1.0
@echo off &setlocal &set usage=Create lnks in Start Menu to all .exe files in dropped folder target or the current dir  
::
:: change start menu folder name (no spaces) below:
set startmenufolder=Utilities
::
SET QUIT=echo You can close me now, or wait a few seconds and I will close myself ^&PING -n 10 0 ^>NUL 2^>^&1 ^&COLOR 70 ^&EXIT/B &COLOR 70 &TITLE LnkAllToStart by AveYo
:: gives time to cancel before any changes (all scripts should provide this...)
FOR /L %%I IN (10,-1,1) DO CLS &echo %usage% &echo  Starting in %%Is. Press [Ctrl+C] or X corner to cancel... &PING -n 2 0 >NUL 2>&1
if exist "%~1" (set "exefolder=%~1") else set "exefolder=%~dp0"  
if not exist "%exefolder%\*.exe" (echo No .exe found in %exefolder% &%QUIT%) else pushd "%exefolder%"  
for %%E in (*.exe) do cscript //nologo /E:JScript "%~f0" "%%~dpnE" &echo  ..creating lnk to %%~nE in %startmenufolder%
md "%APPDATA%\Microsoft\Windows\Start Menu\Programs\%startmenufolder%\" >NUL 2>&1
for %%L in (*.lnk) do move /y "%%L" "%APPDATA%\Microsoft\Windows\Start Menu\Programs\%startmenufolder%\" >NUL 2>&1  
%QUIT%
*/
var lnk=WScript.CreateObject("WScript.Shell").CreateShortcut(WScript.Arguments(0)+".lnk");
lnk.TargetPath=WScript.Arguments(0)+".exe";
lnk.IconLocation=WScript.Arguments(0)+".exe,0";
lnk.Save();
//
