@echo off
chcp 65001 >nul 2>&1
REM ============================================================
REM  INSTALL.bat - Cai dat Tro ly AI SISP (GitHub Pages)
REM  Chay 1 lan tren moi may. Yeu cau quyen Admin.
REM  Add-in se duoc tai tu: https://qlkt.github.io/trolyai/dist/
REM ============================================================

cls
echo =====================================================
echo   CAI DAT TRO LY AI SISP - OFFICE ADD-IN
echo   Nguon: https://qlkt.github.io/trolyai/
echo =====================================================
echo.

REM --- KIEM TRA QUYEN ADMIN ---
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [!] Can quyen Administrator de cai dat.
    echo     Dang khoi dong lai voi quyen Admin...
    powershell -Command "Start-Process cmd -ArgumentList '/c \"%~dpnx0\"' -Verb RunAs"
    exit /b
)

cd /d "%~dp0"

REM --- BUOC 1: TAO THU MUC CATALOG ---
echo [1] Tao thu muc Catalog...
set CATALOG_DIR=C:\OfficeAddinCatalog
if not exist "%CATALOG_DIR%" (
    mkdir "%CATALOG_DIR%"
    echo     OK: Da tao %CATALOG_DIR%
) else (
    echo     OK: Thu muc da ton tai: %CATALOG_DIR%
)

REM --- BUOC 2: COPY MANIFEST ---
echo [2] Copy manifest vao Catalog...
copy /Y "%~dp0manifest.xml" "%CATALOG_DIR%\manifest.xml" >nul
if exist "%CATALOG_DIR%\manifest.xml" (
    echo     OK: manifest.xml da duoc copy
) else (
    echo     [LOI] Khong the copy manifest.xml!
    echo           Kiem tra lai file manifest.xml ben canh INSTALL.bat
    pause
    exit /b 1
)

REM --- BUOC 3: TAO NETWORK SHARE ---
echo [3] Tao Network Share...
set SHARE_NAME=OfficeAddinCat

REM Xoa share cu neu co
net share %SHARE_NAME% /delete >nul 2>&1

REM Tao share moi
net share %SHARE_NAME%="%CATALOG_DIR%" /grant:Everyone,READ >nul 2>&1
if %errorLevel% equ 0 (
    echo     OK: Shared tai \\localhost\%SHARE_NAME%
) else (
    echo     [LOI] Khong the tao Network Share!
    echo           Thu tat Windows Firewall tam thoi va chay lai
    pause
    exit /b 1
)

REM --- BUOC 4: GHI REGISTRY TRUST CENTER ---
echo [4] Dang ky vao Office Trust Center...
set CATALOG_GUID={a1b2c3d4-e5f6-7890-abcd-ef1234567890}
set NETWORK_PATH=\\localhost\%SHARE_NAME%
set REG_PATH=HKCU\Software\Microsoft\Office\16.0\WEF\TrustedCatalogs\%CATALOG_GUID%

reg add "%REG_PATH%" /v "Id"    /t REG_SZ    /d "%CATALOG_GUID%"   /f >nul
reg add "%REG_PATH%" /v "Url"   /t REG_SZ    /d "%NETWORK_PATH%"   /f >nul
reg add "%REG_PATH%" /v "Flags" /t REG_DWORD /d 1                  /f >nul

if %errorLevel% equ 0 (
    echo     OK: Da ghi registry thanh cong
) else (
    echo     [LOI] Khong the ghi registry!
    pause
    exit /b 1
)

REM --- BUOC 5: XOA OFFICE CACHE ---
echo [5] Xoa Office cache cu...
set WEF_CACHE=%LOCALAPPDATA%\Microsoft\Office\16.0\WEF
if exist "%WEF_CACHE%\LocalCache\" (
    rmdir /S /Q "%WEF_CACHE%\LocalCache\" >nul 2>&1
    echo     OK: Da xoa LocalCache
)
if exist "%WEF_CACHE%\manifests\" (
    rmdir /S /Q "%WEF_CACHE%\manifests\" >nul 2>&1
    echo     OK: Da xoa WEF manifests
)
if exist "%LOCALAPPDATA%\Packages\Microsoft.Win32WebViewHost_cw5n1h2txyewy\LocalState\" (
    del /F /Q "%LOCALAPPDATA%\Packages\Microsoft.Win32WebViewHost_cw5n1h2txyewy\LocalState\*" >nul 2>&1
)

REM --- BUOC 6: KIEM TRA KET NOI GITHUB PAGES ---
echo [6] Kiem tra ket noi GitHub Pages...
powershell -Command "try { $r = Invoke-WebRequest 'https://qlkt.github.io/trolyai/dist/taskpane.html' -UseBasicParsing -TimeoutSec 10 -ErrorAction Stop; Write-Host '    OK: GitHub Pages truy cap duoc (HTTP ' $r.StatusCode ')' } catch { Write-Host '    [CANH BAO] Khong ket noi duoc GitHub Pages!' Write-Host '              May tinh nay can co Internet khi dung Add-in' }"

echo.
echo =====================================================
echo   CAI DAT HOAN THANH!
echo =====================================================
echo.
echo BUOC TIEP THEO:
echo   1. DONG HOAN TOAN Word/Excel/PowerPoint
echo      (tat ca cua so, kiem tra System Tray)
echo.
echo   2. MO LAI Word/Excel/PowerPoint
echo.
echo   3. VAO: Insert ^> My Add-ins ^> SHARED FOLDER
echo      Chon "Tro ly AI SISP" roi bam Add
echo.
echo   4. Add-in se tai tu:
echo      https://qlkt.github.io/trolyai/dist/
echo      (Can co Internet de su dung)
echo.
echo GHI CHU:
echo   - Neu SHARED FOLDER trong: chay lai INSTALL.bat
echo   - Neu muon go cai dat: chay UNINSTALL.bat
echo =====================================================
echo.
pause
