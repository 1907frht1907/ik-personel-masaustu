@echo off
cd /d "%~dp0"
if not exist "%~dp0IK-Personel.html" (
  echo IK-Personel.html bu klasorde yok. Zip'ten cikan klasoru birlikte tutun.
  pause
  exit /b 1
)
powershell -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File "%~dp0Baslat.ps1"
if errorlevel 1 (
  echo Acilis hatasi. Edge veya Chrome kurulu olmali.
  pause
)
