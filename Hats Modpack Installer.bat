@ECHO off
setlocal enableextensions enabledelayedexpansion
title "Hat's Modpack Installer"
echo -= Welcome to Hat's ModPack installer! =-
echo.
echo This process is fully automatic, once complete just open the Minecraft launcher and play the ModPack you want.
echo.
echo Note: This will install mods and files to a non-standard location to avoid conflicts
echo with other Minecraft versions. This means you will NEED to use a custom launcher profile
echo provided by this program.
echo.
pause

:: Asks user for Modpack choice, sets error level accordingly
cls
echo Which modpack(s) do you want to install?
echo 1. TheLV - A 1.18.2 modpack focused on modern features and mods.
echo.
choice /C 1 /M "Modpack choice: "
if "%errorlevel%"=="1" (set mpc=1)

:: Sets up initial directories for modpacks and dependancies if they don't exist
cls
echo Progress: ---------- 1%%
echo Setting up directories...
if not exist "C:\Modded Minecraft" mkdir "C:\Modded Minecraft"
if not exist "C:\Modded Minecraft\Java" mkdir "C:\Modded Minecraft\Java"
if %mpc%==1 (if not exist "C:\Modded Minecraft\TheLV" mkdir "C:\Modded Minecraft\TheLV")
if %mpc%==1 (if not exist "C:\Modded Minecraft\TheLV\mods" mkdir "C:\Modded Minecraft\TheLV\mods")
if %mpc%==1 (if not exist "C:\Modded Minecraft\TheLV\configs" mkdir "C:\Modded Minecraft\TheLV\configs")


:: Cleans any left over files from previous failed runs, makes temporary directory for setup files
cls
echo Progress: ---------- 2%%
echo Setting up directories...
call:cleanSetup
mkdir "C:\Modded Minecraft\setup-temp"

:: Downloads a portable command line Git utility
cls
echo Progress: ---------- 3%%
echo Downloading PortableGit...
start /W /min "Downloading..." bitsadmin /transfer PortableGit /download /priority FOREGROUND "https://dl.dropboxusercontent.com/s/m6fvnrmbv8hoy5g/PortableGit.exe" "C:\Modded Minecraft\setup-temp\portablegit.exe"

:: Sets up portable Git utility in temporary setup folder
cls
echo Progress: ---------- 7%%
echo Setting up PortableGit...
mkdir "C:\Modded Minecraft\setup-temp\PortableGit"
start /W /min "Installing PortableGit" "C:\Modded Minecraft\setup-temp\portablegit.exe" -d"C:\Modded Minecraft\setup-temp\PortableGit" -s1

:: Cloans the master GitHub respository
cls
echo Progress: =--------- 15%%
echo Cloaning Git Repo - This may take some time...
echo.
mkdir "C:\Modded Minecraft\setup-temp\gitclone"
"C:\Modded Minecraft\setup-temp\PortableGit\cmd\git.exe" clone -b Modpack-Installer --single-branch https://github.com/MrSteave/Hats-ModPack-Installer "C:\Modded Minecraft\setup-temp\gitclone"
if %mpc%==1 (set /p ver=<"C:\Modded Minecraft\setup-temp\gitclone\resources\version.txt")
if %mpc%==1 (if exist "C:\Modded Minecraft\TheLV\%ver%" call:upToDate)
:return

:: Installs/Updates MC modloader if needed
cls
echo Progress: ===------- 36%%
echo Installing Minecraft Mod Loader - This may take some time...
if %mpc%==1 (if not exist "%appdata%\.minecraft\versions\1.18.2-forge-40.2.0" start /W /min "Installing Forge..." "C:\Modded Minecraft\setup-temp\gitclone\java\JDK17\bin\javaw.exe" -jar "C:\Modded Minecraft\setup-temp\gitclone\resources\ForgeCLI-1.0.1.jar" --installer "C:\Modded Minecraft\setup-temp\gitclone\resources\forge-1.18.2-40.2.0-installer.jar" --target "%appdata%\.minecraft" & set FUP=y)

:: Copies mods for chosen modpack(s)
cls
echo Progress: ======---- 61%%
echo Copying mods...
if %mpc%==1 (rmdir /s /q "C:\Modded Minecraft\TheLV\mods")
if %mpc%==1 (mkdir "C:\Modded Minecraft\TheLV\mods")
if %mpc%==1 (start /W /min "Copying mods..." xcopy /s/e/y/i "C:\Modded Minecraft\setup-temp\gitclone\mods\TheLV" "C:\Modded Minecraft\TheLV\mods")
if %mpc%==1 (rmdir /s /q "C:\Modded Minecraft\TheLV\configs")
if %mpc%==1 (mkdir "C:\Modded Minecraft\TheLV\configs")
if %mpc%==1 (start /W /min "Copying configs..." xcopy /s/e/y/i "C:\Modded Minecraft\setup-temp\gitclone\configs\TheLV" "C:\Modded Minecraft\TheLV\configs")

:: Copies Java version(s) if needed and gets system RAM amount
cls
echo Progress: =======--- 79%%
echo Copying Java...
if %mpc%==1 (if not exist "C:\Modded Minecraft\Java\JDK17" mkdir "C:\Modded Minecraft\Java\JDK17")
if %mpc%==1 (start /W /min "Copying Java..." xcopy /s/e/y/i "C:\Modded Minecraft\setup-temp\gitclone\java\JDK17" "C:\Modded Minecraft\Java\JDK17")
wmic ComputerSystem get TotalPhysicalMemory >"C:\Modded Minecraft\setup-temp\output.txt"
more +1 "C:\Modded Minecraft\setup-temp\output.txt" > "C:\Modded Minecraft\setup-temp\output2.txt"
set /p RAM=<"C:\Modded Minecraft\setup-temp\output2.txt"

:: Copies proper launcher profile json and server list based on chosen modpack(s) and system RAM amount, cleans up temp files and sets modpack versions in storage
cls
echo Progress: ========-- 88%%
echo Finishing up...
set RAM=%RAM:~0,-19%
if %RAM% GTR 8 (set RC=8)
if %RAM% GTR 8 (if %RAM% GTR 12 (set RC=8))
if %RAM% GTR 8 (if %RAM% GTR 12 (if %RAM% GTR 16 (set RC=12)))
if %RAM% GTR 8 (if %RAM% GTR 12 (if %RAM% GTR 16 (if %RAM% GTR 24 (set RC=16))))
if %RC% == 5 call:copy5
if %RC% == 8 call:copy8
if %RC% == 12 call:copy12
if %RC% == 16 call:copy16
:returnRAM
if %mpc%==1 (echo F|start /W /min "Copying server list..." xcopy /s/e/y/f "C:\Modded Minecraft\setup-temp\gitclone\resources\Profiles\TheLV\servers.dat" "C:\Modded Minecraft\TheLV\servers.dat")
call:cleanSetup
if %mpc%==1 (echo "ModPack version %ver% - identifier">"C:\Modded Minecraft\TheLV\%ver%")

:: Confirms process complete for user
cls
echo Progress: ========== 100%%
echo Done!
echo.
pause
exit 0

:: Following calls for listed system RAM amounts
:copy16
if %mpc%==1 (start /W /min "Copying Launcher Profile..." xcopy /s/e/y "C:\Modded Minecraft\setup-temp\gitclone\resources\Profiles\TheLV\16.json" "%APPDATA%\.minecraft\launcher_profiles.json")
call:returnRAM

:copy12
if %mpc%==1 (start /W /min "Copying Launcher Profile..." xcopy /s/e/y "C:\Modded Minecraft\setup-temp\gitclone\resources\Profiles\TheLV\12.json" "%APPDATA%\.minecraft\launcher_profiles.json")
call:returnRAM

:copy8
if %mpc%==1 (start /W /min "Copying Launcher Profile..." xcopy /s/e/y "C:\Modded Minecraft\setup-temp\gitclone\resources\Profiles\TheLV\8.json" "%APPDATA%\.minecraft\launcher_profiles.json")
call:returnRAM

:copy5
if %mpc%==1 (start /W /min "Copying Launcher Profile..." xcopy /s/e/y "C:\Modded Minecraft\setup-temp\gitclone\resources\Profiles\TheLV\5.json" "%APPDATA%\.minecraft\launcher_profiles.json")
call:returnRAM

:: Call for the chosen Modpack already being detected as up to date
:upToDate
cls
echo It appears the installed version of the ModPack is up to date...
choice /C yn /M "Continue anyway? (Useful for repairing damaged files):"
if %errorlevel%==2 exit
call:return

:: Call to clean up any existing temporary setup files and directories
:cleanSetup
rmdir /s /q "C:\Modded Minecraft\setup-temp"