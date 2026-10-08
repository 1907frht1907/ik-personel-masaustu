$ErrorActionPreference = "Continue"
$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$Html = Join-Path $Root "IK-Personel.html"
if (-not (Test-Path -LiteralPath $Html)) {
  Write-Host "IK-Personel.html bulunamadi. Zip klasorunu bolmeyin."
  Start-Sleep 6
  exit 1
}

$Port = 17865
$AppUrl = "http://127.0.0.1:$Port/IK-Personel.html"

function Get-Browser {
  $cands = @(
    "$env:ProgramFiles\Microsoft\Edge\Application\msedge.exe",
    "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe",
    "$env:ProgramFiles\Google\Chrome\Application\chrome.exe",
    "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe"
  )
  foreach ($p in $cands) { if ($p -and (Test-Path -LiteralPath $p)) { return $p } }
  return $null
}

$ico = Join-Path $Root "ik.ico"
$bat = Join-Path $Root "Masaustune-Kur.bat"
$desktop = [Environment]::GetFolderPath("Desktop")
$lnkPath = Join-Path $desktop "IK Personel.lnk"
$shell = New-Object -ComObject WScript.Shell
$lnk = $shell.CreateShortcut($lnkPath)
$lnk.TargetPath = $bat
$lnk.WorkingDirectory = $Root
$lnk.WindowStyle = 7
$lnk.Description = "IK Personel Yonetim"
if (Test-Path -LiteralPath $ico) { $lnk.IconLocation = "$ico,0" }
$lnk.Save()

function Test-Up {
  try {
    $r = [Net.WebRequest]::Create($AppUrl)
    $r.Timeout = 700
    $r.GetResponse().Close()
    return $true
  } catch { return $false }
}

$started = $false
if (-not (Test-Up)) {
  $server = @'
param($port, $root)
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add(("http://127.0.0.1:{0}/" -f $port))
$listener.Start()
while ($listener.IsListening) {
  try {
    $ctx = $listener.GetContext()
    $rel = [Uri]::UnescapeDataString($ctx.Request.Url.AbsolutePath.TrimStart("/"))
    if ([string]::IsNullOrWhiteSpace($rel)) { $rel = "IK-Personel.html" }
    $full = [IO.Path]::GetFullPath((Join-Path $root $rel))
    $okRoot = [IO.Path]::GetFullPath($root)
    if (-not $full.StartsWith($okRoot, [StringComparison]::OrdinalIgnoreCase) -or -not (Test-Path -LiteralPath $full)) {
      $ctx.Response.StatusCode = 404
      $ctx.Response.Close()
      continue
    }
    $bytes = [IO.File]::ReadAllBytes($full)
    $ext = [IO.Path]::GetExtension($full).ToLowerInvariant()
    $ctx.Response.ContentType = switch ($ext) {
      ".html" { "text/html; charset=utf-8" }
      ".js" { "text/javascript; charset=utf-8" }
      ".css" { "text/css; charset=utf-8" }
      ".svg" { "image/svg+xml" }
      ".png" { "image/png" }
      ".ico" { "image/x-icon" }
      default { "application/octet-stream" }
    }
    $ctx.Response.Headers["Cache-Control"] = "no-cache"
    $ctx.Response.OutputStream.Write($bytes, 0, $bytes.Length)
    $ctx.Response.Close()
  } catch {}
}
'@
  $rs = [runspacefactory]::CreateRunspace()
  $rs.Open()
  $ps = [powershell]::Create()
  $ps.Runspace = $rs
  [void]$ps.AddScript($server).AddArgument($Port).AddArgument($Root)
  $handle = $ps.BeginInvoke()
  $started = $true
  1..40 | ForEach-Object {
    if (Test-Up) { break }
    Start-Sleep -Milliseconds 100
  }
}

if (-not (Test-Up)) {
  $AppUrl = ([Uri](Get-Item -LiteralPath $Html).FullName).AbsoluteUri
  $started = $false
}

$browser = Get-Browser
if ($browser) {
  Start-Process -FilePath $browser -ArgumentList @("--app=$AppUrl", "--window-size=1440,900", "--no-first-run")
} else {
  Start-Process -FilePath $Html
}

if ($started -and $handle) {
  while (-not $handle.IsCompleted) { Start-Sleep -Seconds 30 }
}
