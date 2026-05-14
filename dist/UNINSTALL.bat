@echo off
chcp 65001 >nul 2>&1
REM ============================================================
REM  UNINSTALL.bat - Go cai dat Tro ly AI SISP
REM ============================================================

cls
echo =====================================================
echo   GO CAI DAT TRO LY AI SISP
echo =====================================================
echo.

net session >nul 2>&1
if %errorLevel% neq 0 (
    powershell -Command "Start-Process cmd -ArgumentList '/c \"%~dpnx0\"' -Verb RunAs"
    exit /b
)

echo [1] Xoa Network Share...
net share OfficeAddinCat /delete >nul 2>&1
echo     OK

echo [2] Xoa Registry...
set CATALOG_GUID={a1b2c3d4-e5f6-7890-abcd-ef1234567890}
reg delete "HKCU\Software\Microsoft\Office\16.0\WEF\TrustedCatalogs\%CATALOG_GUID%" /f >nul 2>&1
echo     OK

echo [3] Xoa thu muc Catalog...
if exist "C:\OfficeAddinCatalog\" (
    rmdir /S /Q "C:\OfficeAddinCatalog\" >nul 2>&1
    echo     OK
) else (
    echo     Thu muc khong ton tai, bo qua
)

echo [4] Xoa Office Cache...
set WEF=%LOCALAPPDATA%\Microsoft\Office\16.0\WEF
if exist "%WEF%\LocalCache\" rmdir /S /Q "%WEF%\LocalCache\" >nul 2>&1
if exist "%WEF%\manifests\"  rmdir /S /Q "%WEF%\manifests\"  >nul 2>&1
echo     OK

echo.
echo Go cai dat hoan tat. Vui long khoi dong lai Office.
echo.
pause
