@echo off
chcp 65001 >nul 2>&1
REM ============================================================
REM  SETUP-OLLAMA-CORS.bat
REM  Chay de cau hinh CORS cho Ollama cho phep ket noi tu Add-in
REM ============================================================

cls
echo =====================================================
echo   CAU HINH OLLAMA CHO PHEP KET NOI TU OFFICE ADD-IN
echo =====================================================
echo.

net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [!] Kich hoat quyen Admin de thiet lap moi truong...
    powershell -Command "Start-Process cmd -ArgumentList '/c \"%~dpnx0\"' -Verb RunAs"
    exit /b
)

echo [1] Kiem tra xem Ollama co dang chay khong...
tasklist /FI "IMAGENAME eq ollama app.exe" 2>NUL | find /I /N "ollama app.exe">NUL
if "%ERRORLEVEL%"=="0" (
    echo     Ollama dang chay. Dang dong Ollama...
    taskkill /F /IM "ollama app.exe" >nul 2>&1
    taskkill /F /IM "ollama.exe" >nul 2>&1
    timeout /t 2 /nobreak >nul
) else (
    tasklist /FI "IMAGENAME eq ollama.exe" 2>NUL | find /I /N "ollama.exe">NUL
    if "%ERRORLEVEL%"=="0" (
        echo     Ollama dang chay. Dang dong Ollama...
        taskkill /F /IM "ollama.exe" >nul 2>&1
        timeout /t 2 /nobreak >nul
    )
)

echo [2] Set bien moi truong he thong OLLAMA_ORIGINS...
setx OLLAMA_ORIGINS "https://qlkt.github.io" /M >nul 2>&1

if %errorLevel% equ 0 (
    echo     OK: Da thiet lap OLLAMA_ORIGINS="https://qlkt.github.io"
) else (
    echo     [LOI] Khong the thiet lap bien moi truong!
)

echo [3] Mo lai Ollama...
start "" "%LOCALAPPDATA%\Programs\Ollama\ollama app.exe" >nul 2>&1
if %errorLevel% neq 0 (
    echo     Vui long tu mo lai Ollama bang icon tren man hinh hoac Start Menu.
)

echo.
echo =====================================================
echo   HOAN TAT!
echo   Vui long khoi dong lai Word/Excel/PowerPoint neu
echo   Add-in van chua the ket noi voi Ollama.
echo =====================================================
echo.
pause
