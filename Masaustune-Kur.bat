@echo off
chcp 65001 >nul
setlocal
set "HTML=%~dp0IK-Personel.html"
if not exist "%HTML%" (
  echo IK-Personel.html bu klasorde yok.
  pause
  exit /b 1
)

set "EDGE86=%ProgramFiles(x86)%\Microsoft\Edge\Application\msedge.exe"
set "EDGE64=%ProgramFiles%\Microsoft\Edge\Application\msedge.exe"
set "CHROME=%ProgramFiles%\Google\Chrome\Application\chrome.exe"
set "CHROME86=%ProgramFiles(x86)%\Google\Chrome\Application\chrome.exe"
set "PROFILE=%LOCALAPPDATA%\IK-Personel-Profil"

if exist "%EDGE64%" (
  start "" "%EDGE64%" --app="%HTML%" --user-data-dir="%PROFILE%"
  exit /b 0
)
if exist "%EDGE86%" (
  start "" "%EDGE86%" --app="%HTML%" --user-data-dir="%PROFILE%"
  exit /b 0
)
if exist "%CHROME%" (
  start "" "%CHROME%" --app="%HTML%" --user-data-dir="%PROFILE%"
  exit /b 0
)
if exist "%CHROME86%" (
  start "" "%CHROME86%" --app="%HTML%" --user-data-dir="%PROFILE%"
  exit /b 0
)

echo Edge veya Chrome bulunamadi, varsayilan tarayici ile aciliyor.
start "" "%HTML%"
