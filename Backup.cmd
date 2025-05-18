@echo off
Title Backup
Color 0b

:: Step 1: Elevate
>nul 2>&1 fsutil dirty query %systemdrive% || echo CreateObject^("Shell.Application"^).ShellExecute "%~0", "ELEVATED", "", "runas", 1 > "%temp%\uac.vbs" && "%temp%\uac.vbs" && exit /b
DEL /F /Q "%temp%\uac.vbs"

:: Step 2: Prep environment
setlocal EnableExtensions EnableDelayedExpansion
if not exist "F:\" (
    echo F: drive not found. Please connect it or check the drive letter.
    pause
    exit /b
)
if not exist "F:\media" (
    mkdir "F:\media"
    if errorlevel 1 (
        echo Failed to create F:\media
        pause
        exit /b
    )
)
set "LOGFILE=F:\media\copied_files.txt"
set "ERRORLOG=F:\media\error_log.txt"
if not exist "%LOGFILE%" type nul > "%LOGFILE%"
if not exist "%ERRORLOG%" type nul > "%ERRORLOG%"

:: Step 3: Main loop
:loop
echo Starting scan at %date% %time%>>"%ERRORLOG%"
echo Starting scan...
cd /d "C:\Users\Admin\Pictures"
for %%F in (jpg mp4 3gp mov gif) do (
    echo Scanning for *.%%F files...>>"%ERRORLOG%"
    echo Scanning for *.%%F files...
    for /f "tokens=*" %%A in ('dir /b /o:n *.%%F') do (
        :: Skip if file is in log
        findstr /x /c:"%USERPROFILE%\Pictures\%%A" "%LOGFILE%" >nul
        if errorlevel 1 (
            echo Processing: %%A>>"%ERRORLOG%"
            echo Processing: %%A
            copy /y "%%A" "F:\media\" >>"%ERRORLOG%" 2>&1
            if !errorlevel! equ 0 (
                echo %USERPROFILE%\Pictures\%%A>>"%LOGFILE%"
                echo Copied: %%A>>"%ERRORLOG%"
                echo Copied: %%A
            ) else (
                echo Failed to copy: %%A>>"%ERRORLOG%"
                echo Failed: %%A
            )
        )
    )
)

:: Check if F: drive is still available
if not exist "F:\" (
    echo F: drive disconnected. Stopping script.
    pause
    exit /b
)

:: Wait before scanning again
timeout /t 10 >nul
goto loop