@ECHO off
setlocal enableextensions enabledelayedexpansion
title "Hat's Modpack Installer - TheLV"
echo -= Welcome to TheLV's ModPack installer! =-
echo.
echo This process is mostly automatic, however some steps may give prompts 
echo that you'll need to follow to complete the installation.
echo.
echo Note: This will install mods and files to a non-standard location to avoid conflicts
echo with other Minecraft versions. This means you will NEED to use a custom launcher profile.
echo A tutorial is included at the end of this setup process.
pause

cls
echo Progress: ---------- 1%%
echo Setting up directories...

if not exist "C:\Modded Minecraft" mkdir "C:\Modded Minecraft"
if not exist "C:\Modded Minecraft\Java" mkdir "C:\Modded Minecraft\Java"
if not exist "C:\Modded Minecraft\TheLV" mkdir "C:\Modded Minecraft\TheLV"
if not exist "C:\Modded Minecraft\TheLV\mods" mkdir "C:\Modded Minecraft\TheLV\mods"
if not exist "C:\Modded Minecraft\TheLV\configs" mkdir "C:\Modded Minecraft\TheLV\configs"

cls
echo Progress: ---------- 2%%
echo Setting up directories...

call:cleanSetup
mkdir "C:\Modded Minecraft\setup-temp"

cls
echo Progress: ---------- 3%%
echo Downloading PortableGit...

start /W /min "Downloading..." bitsadmin /transfer PortableGit /download /priority FOREGROUND "https://dl.dropboxusercontent.com/s/p41pm6911kl994l/gitsetup.exe" "C:\Modded Minecraft\setup-temp\gitsetup.exe"

cls
echo Progress: ---------- 7%%
echo Setting up PortableGit...

mkdir "C:\Modded Minecraft\setup-temp\PortableGit"
start /W /min "Installing PortableGit" "C:\Modded Minecraft\setup-temp\gitsetup.exe" -d"C:\Modded Minecraft\setup-temp\PortableGit" -s1

cls
echo Progress: =--------- 15%%
echo Cloaning Git Repo - This may take some time...
echo.

mkdir "C:\Modded Minecraft\setup-temp\gitclone"
"C:\Modded Minecraft\setup-temp\PortableGit\cmd\git.exe" clone -b TheLV --single-branch https://github.com/MrSteave/Hats-ModPack-Installer "C:\Modded Minecraft\setup-temp\gitclone"
set /p ver=<"C:\Modded Minecraft\setup-temp\gitclone\resources\version.txt"
if exist "C:\Modded Minecraft\TheLV\%ver%" call:upToDate
:return

cls
echo Progress: ===------- 36%%
echo Installing Minecraft Forge 40.1.0 - This may take some time...

if not exist "%appdata%\.minecraft\versions\1.18.2-forge-40.1.0" start /W /min "Installing Forge..." "C:\Modded Minecraft\setup-temp\gitclone\java\JDK17\bin\javaw.exe" -jar "C:\Modded Minecraft\setup-temp\gitclone\resources\ForgeCLI-1.0.1.jar" --installer "C:\Modded Minecraft\setup-temp\gitclone\resources\forge-1.18.2-40.1.0-installer.jar" --target "%appdata%\.minecraft" & set FUP=y

cls
echo Progress: ======---- 61%%
echo Copying mods...

rmdir /s /q "C:\Modded Minecraft\TheLV\mods"
start /W /min "Copying mods..." xcopy /s/e/y/i "C:\Modded Minecraft\setup-temp\gitclone\mods" "C:\Modded Minecraft\TheLV\mods"
rmdir /s /q "C:\Modded Minecraft\TheLV\configs"
start /W /min "Copying configs..." xcopy /s/e/y/i "C:\Modded Minecraft\setup-temp\gitclone\configs" "C:\Modded Minecraft\TheLV\configs"

cls
echo Progress: =======--- 79%%
echo Copying Java...

if not exist "C:\Modded Minecraft\Java\JDK17" mkdir "C:\Modded Minecraft\Java\JDK17"
start /W /min "Copying Java..." xcopy /s/e/y/i "C:\Modded Minecraft\setup-temp\gitclone\java\JDK17" "C:\Modded Minecraft\Java\JDK17"
wmic ComputerSystem get TotalPhysicalMemory >"C:\Modded Minecraft\setup-temp\output.txt"
more +1 "C:\Modded Minecraft\setup-temp\output.txt" > "C:\Modded Minecraft\setup-temp\output2.txt"
set /p RAM=<"C:\Modded Minecraft\setup-temp\output2.txt"

cls
echo Progress: ========-- 88%%
echo Finishing up...


if %RAM% GTR 8000000000 (if %RAM% GTR 12000000000 (if %RAM% GTR 16000000000 (if %RAM% GTR 24000000000 call:copy16) else call:copy12) else call:copy8) else call:copy5
:returnRAM
call:cleanSetup
echo "ModPack version %ver% - identifier">"C:\Modded Minecraft\TheLV\%ver%"

cls
echo Progress: ========== 100%%
echo Done!
echo.
pause
exit

:copy16
start /W /min "Copying Launcher Profile..." xcopy /s/e/y "C:\Modded Minecraft\setup-temp\gitclone\resources\Profiles\TheLV\16.json" "%APPDATA%\.minecraft\launcher_profiles.json"
call:returnRAM

:copy12
start /W /min "Copying Launcher Profile..." xcopy /s/e/y "C:\Modded Minecraft\setup-temp\gitclone\resources\Profiles\TheLV\12.json" "%APPDATA%\.minecraft\launcher_profiles.json"
call:returnRAM

:copy8
start /W /min "Copying Launcher Profile..." xcopy /s/e/y "C:\Modded Minecraft\setup-temp\gitclone\resources\Profiles\TheLV\8.json" "%APPDATA%\.minecraft\launcher_profiles.json"
call:returnRAM

:copy5
start /W /min "Copying Launcher Profile..." xcopy /s/e/y "C:\Modded Minecraft\setup-temp\gitclone\resources\Profiles\TheLV\5.json" "%APPDATA%\.minecraft\launcher_profiles.json"
call:returnRAM


:upToDate
echo It appears the installed version of the ModPack is up to date, would you like to continue?
set /p ANSWER=(y/n):
if %ANSWER%==n exit
call:return

:howLauncher
cls
setlocal
for /f "tokens=2* delims=:" %%a in ('systeminfo ^| findstr /I /C:"Total Physical Memory"') do set TotalRAM=%%a
set "str=%TotalRAM%"
cls
echo A document with a tutorial on making the necessary Minecraft launcher profile will now open.
echo For reference, your PC's total ram is: %TotalRAM%
start "Minecraft Launcher Profile Creation Tutorial" "C:\Windows\notepad.exe" "C:\Modded Minecraft\Tutorial\Launcher Profile Tutorial.txt"
pause
exit

:updateForge
echo It looks like the Forge version needs to be updated in the Minecraft Launcher.
echo In the Installations tab, select your TheLV profile, click Edit in the three dot menu,
echo and set the version to "release 1.18.2-forge-40.1.0".
pause
exit

:cleanSetup
rmdir /s /q "C:\Modded Minecraft\setup-temp"