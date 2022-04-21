@ECHO off
title "Hat's Modpack Installer - TheLV"
echo -= Welcome to TheLV's ModPack installer! =-
echo.
echo This process is mostly automatic, however some steps may give prompts 
echo that you'll need to follow to complete the installation.
echo.
pause



cls
echo Progress: ---------- 1%
echo Setting up directories...

if not exist "C:\Modded Minecraft" mkdir "C:\Modded Minecraft"
if not exist "C:\Modded Minecraft\TheLV" mkdir "C:\Modded Minecraft\TheLV"
if not exist "C:\Modded Minecraft\TheLV\mods" mkdir "C:\Modded Minecraft\TheLV\mods"
if exist "C:\Modded Minecraft\TheLV\1.0a" call:upToDate
:return

cls
echo Progress: ---------- 2%
echo Setting up directories...

call:cleanSetup
mkdir "C:\Modded Minecraft\setup-temp"

cls
echo Progress: ---------- 3%
echo Downloading PortableGit...

start /W /min "Downloading..." bitsadmin /transfer PortableGit /download /priority FOREGROUND "https://dl.dropboxusercontent.com/s/p41pm6911kl994l/gitsetup.exe" "C:\Modded Minecraft\setup-temp\gitsetup.exe"

cls
echo Progress: ---------- 7%
echo Setting up PortableGit...

mkdir "C:\Modded Minecraft\setup-temp\PortableGit"
start /W /min "Installing PortableGit" "C:\Modded Minecraft\setup-temp\gitsetup.exe" -d"C:\Modded Minecraft\setup-temp\PortableGit" -s1

cls
echo Progress: =--------- 10%
echo Cloaning Git Repo - This may take some time...
echo.

mkdir "C:\Modded Minecraft\setup-temp\gitclone"
"C:\Modded Minecraft\setup-temp\PortableGit\cmd\git.exe" clone -b TheLV --single-branch https://github.com/MrSteave/Hats-ModPack-Installer "C:\Modded Minecraft\setup-temp\gitclone"

cls
echo Progress: ==-------- 25%
echo Installing Minecraft Forge 40.1.0...

start /W /min "C:\Modded Minecraft\setup-temp\gitclone\java\JDK17\bin\javaw.exe" -jar "C:\Modded Minecraft\setup-temp\resources\ForgeCLI-1.0.1.jar" --installer "C:\Modded Minecraft\setup-temp\resources\forge-1.18.2-40.1.0-installer.jar" --target "C:\Modded Minecraft\TheLV"

cls
echo Progress: ===------- 40%
echo Copying mods...

xcopy /s/e "C:\Modded Minecraft\setup-temp\gitclone\mods" "C:\Modded Minecraft\TheLV\mods"

cls
echo Progress: ===------- 75%
echo Finishing up...

call:cleanSetup
"">"C:\Modded Minecraft\TheLV\1.0a"

pause
exit /b

:upToDate
echo It appears the installed version of the ModPack is up to date, would you like to continue?
set /p ANSWER=(y/n):
if %ANSWER%==n exit else call:return

:cleanSetup
rmdir /S/Q "C:\Modded Minecraft\setup-temp"