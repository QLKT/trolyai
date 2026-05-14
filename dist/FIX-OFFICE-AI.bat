@echo off
chcp 65001 >nul 2>&1
cls
echo =====================================================
echo    CU HNH B?O M?T OFFICE CHO TR? LY AI SISP
echo =====================================================
echo.

net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [!] Vui lng chu?t ph?i ch?n "Run as Administrator"!
    pause
    exit /b
)

echo [1] Dang mo khoa mang (Loopback) cho Office...
CheckNetIsolation.exe LoopbackExempt -a -n="microsoft.office.desktop_8wekyb3d8bbwe" >nul 2>&1
CheckNetIsolation.exe LoopbackExempt -a -p="S-1-15-2-3245784371-4245756475-3131439318-1867145453-4063240504-1797288915-321281122" >nul 2>&1

echo [2] Dang dua qlkt.github.io vao Trusted Sites...
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\github.io" /v "https" /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\github.io\qlkt" /v "https" /t REG_DWORD /d 2 /f >nul 2>&1

echo [3] Dang cau hinh WebView2 cho phep Insecure Content...
reg add "HKCU\Software\Policies\Microsoft\Edge\WebView2\AdditionalBrowserArguments" /v "*" /t REG_SZ /d "--allow-running-insecure-content --disable-web-security" /f >nul 2>&1
reg add "HKLM\Software\Policies\Microsoft\Edge\WebView2\AdditionalBrowserArguments" /v "*" /t REG_SZ /d "--allow-running-insecure-content --disable-web-security" /f >nul 2>&1

echo [4] Dang xoa Cache Office...
del /q /s /f "%LOCALAPPDATA%\Microsoft\Office\16.0\Wef\*" >nul 2>&1

echo.
echo =====================================================
echo   THANH CONG! 
echo   Hay khoi dong lai Word/Excel/PowerPoint va thu lai.
echo =====================================================
pause
