$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$Html = Join-Path $Root "IK-Personel.html"
if (-not (Test-Path -LiteralPath $Html)) {
  Write-Host "IK-Personel.html bulunamadi. Zip klasorunu bolmeyin."
  Start-Sleep 5
  exit 1
}

$edge = @(
  "$env:ProgramFiles\Microsoft\Edge\Application\msedge.exe",
  "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe",
  "$env:ProgramFiles\Google\Chrome\Application\chrome.exe",
  "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe"
) | Where-Object { $_ -and (Test-Path -LiteralPath $_) } | Select-Object -First 1

$uri = ([Uri]::new((Get-Item -LiteralPath $Html).FullName)).AbsoluteUri
$ico = Join-Path $Root "ik.ico"
$bat = Join-Path $Root "Masaustune-Kur.bat"
$desktop = [Environment]::GetFolderPath("Desktop")
$lnkPath = Join-Path $desktop "IK Personel.lnk"
$shell = New-Object -ComObject WScript.Shell
$lnk = $shell.CreateShortcut($lnkPath)
$lnk.TargetPath = $bat
$lnk.WorkingDirectory = $Root
$lnk.WindowStyle = 1
$lnk.Description = "IK Personel Yonetim"
if (Test-Path -LiteralPath $ico) { $lnk.IconLocation = "$ico,0" }
$lnk.Save()

if ($edge) {
  Start-Process -FilePath $edge -ArgumentList @("--app=$uri", "--window-size=1440,900", "--no-first-run")
} else {
  Start-Process -FilePath $Html
}
exit 0
