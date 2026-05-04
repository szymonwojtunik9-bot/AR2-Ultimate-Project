@echo off
title Ultimate Roblox & AR2 Optimizer
echo ====================================================
echo   AR2 Ultimate Optimizer - Windows & Network Tweaks
echo ====================================================
echo.

:: 1. Plan Zasilania: Wysoka Wydajnosc
echo [+] Ustawianie planu zasilania: Wysoka wydajnosc...
powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c >nul 2>&1
if %errorlevel% neq 0 (
    powercfg /setactive SCHEME_MIN >nul 2>&1
)

:: 2. Optymalizacja Sieci (TCP No Delay / Nagle's Algorithm)
echo [+] Optymalizacja pingu (TCP No Delay)...
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces" /v "TcpAckFrequency" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces" /v "TCPNoDelay" /t REG_DWORD /d 1 /f >nul 2>&1

:: 3. Wylaczenie Game Bar i Telemetrii (Mniej procesow w tle)
echo [+] Wylaczanie zbednej telemetrii Windows...
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\GameDVR" /v "AppCaptureEnabled" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\System\GameConfigStore" /v "GameDVR_Enabled" /t REG_DWORD /d 0 /f >nul 2>&1

:: 4. Czyszczenie plikow tymczasowych
echo [+] Czyszczenie cache Roblox i Windows...
del /s /f /q %localappdata%\Roblox\logs\* >nul 2>&1
del /s /f /q %temp%\* >nul 2>&1

echo.
echo ====================================================
echo   GOTOWE! Zrestartuj komputer, aby zmiany zadzialaly.
echo ====================================================
pause
