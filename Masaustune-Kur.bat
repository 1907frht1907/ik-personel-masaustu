@echo off
cd /d "%~dp0"
if not exist "%~dp0IK-Personel.html" (
  echo IK-Personel.html bu klasorde yok. Zip klasorunu birlikte tutun.
  pause
  exit /b 1
)
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0Ac.ps1"
if errorlevel 1 (
  echo Pencere acilamadi.
  pause
)
exit /b 0
