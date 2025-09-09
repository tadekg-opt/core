@echo off
setlocal EnableExtensions EnableDelayedExpansion

set "PRESET0=windows-debug-static"
set "PRESET1=windows-debug-static-codestyle"
set "PRESET2=windows-release-static"

:select
if "%~1"=="" (
    echo.
    echo Wybierz opcje:
    echo   0  - Debug Windows
    echo   1  - Debug Windows + CodeStyle
    echo   2  - Release Windows
    echo   3  - Debug Windows (bez clean)
    echo   4  - Debug Windows + CodeStyle (bez clean)
    echo   5  - Release Windows (bez clean)
    echo   6  - Debug Windows (skip cmakeTest)
    echo   7  - Debug Windows + CodeStyle (skip cmakeTest)
    echo   8  - Release Windows (skip cmakeTest)
    echo   9  - Debug Windows (bez clean, skip cmakeTest)
    echo   a  - Debug Windows + CodeStyle (bez clean, skip cmakeTest)
    echo   b  - Release Windows (bez clean, skip cmakeTest)
    echo   ENTER - wyjscie
    echo.
    set /p choice=Podaj opcje (0-9,a-b lub ENTER aby wyjsc):
    if "!choice!"=="" goto end
) else (
    set "choice=%~1"
)

set "skipCmakeTest=0"
set "doClean=1"
set "preset="

rem Litery: a/b zamiast 10/11 (case-insensitive)
if /i "!choice!"=="a" (
    set "idx=1"
    set "doClean=0"
    set "skipCmakeTest=1"
    goto resolve_preset
)
if /i "!choice!"=="b" (
    set "idx=2"
    set "doClean=0"
    set "skipCmakeTest=1"
    goto resolve_preset
)

rem Walidacja numeryczna
for /f "delims=0123456789" %%A in ("!choice!") do goto invalid
if "!choice!"=="" goto end
if !choice! LSS 0 goto invalid
if !choice! GTR 9 goto invalid

rem Mapowanie 0..9
if !choice! LSS 3 (
    set /a idx=!choice!
) else if !choice! LSS 6 (
    set /a idx=!choice!-3
    set "doClean=0"
) else if !choice! LSS 9 (
    set /a idx=!choice!-6
    set "skipCmakeTest=1"
) else (
    set /a idx=!choice!-9
    set "doClean=0"
    set "skipCmakeTest=1"
)

:resolve_preset
if "!idx!"=="0" set "preset=!PRESET0!"
if "!idx!"=="1" set "preset=!PRESET1!"
if "!idx!"=="2" set "preset=!PRESET2!"
if "!preset!"=="" goto invalid

:build
set "gradlew=%~dp0gradlew.bat"
if not exist "%gradlew%" set "gradlew=.\gradlew.bat"

set "extraArgs="
if "!skipCmakeTest!"=="1" set "extraArgs=-x cmakeTest"

if "!doClean!"=="1" (
    call "%gradlew%" clean build -Ppreset=!preset! !extraArgs!
) else (
    call "%gradlew%" build -Ppreset=!preset! !extraArgs!
)
goto end

:invalid
echo Bledna opcja: !choice!
if "%~1"=="" goto select

:end
endlocal

