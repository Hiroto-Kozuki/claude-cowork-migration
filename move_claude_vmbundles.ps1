# ============================================================
#  Claude vm_bundles Junction Migration Script (PowerShell)
# ============================================================
#  Moves vm_bundles from AppData\Local\Packages to C:\ClaudeData
#  and creates a junction at the original location.
# ============================================================

$ErrorActionPreference = 'Stop'

# ---- Self-elevate to admin ----
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal(
    [Security.Principal.WindowsIdentity]::GetCurrent()
)
if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Re-launching with Administrator privileges..."
    $argList = @(
        '-NoProfile',
        '-ExecutionPolicy', 'Bypass',
        '-File', "`"$PSCommandPath`""
    )
    Start-Process -FilePath 'powershell.exe' -Verb RunAs -ArgumentList $argList
    exit
}

# ---- Ensure console can display properly ----
try {
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
} catch {}

# ---- Paths ----
$SRC       = "$env:USERPROFILE\AppData\Local\Packages\Claude_pzs8sxrjxfjjc\LocalCache\Roaming\Claude\vm_bundles"
$DST       = 'C:\ClaudeData\vm_bundles'
$DSTPARENT = 'C:\ClaudeData'

Write-Host ''
Write-Host '============================================================' -ForegroundColor Cyan
Write-Host '  Claude vm_bundles Junction Migration' -ForegroundColor Cyan
Write-Host '============================================================' -ForegroundColor Cyan
Write-Host ''
Write-Host "  Source:      $SRC"
Write-Host "  Destination: $DST"
Write-Host ''

function Pause-Exit([int]$code) {
    Write-Host ''
    Read-Host 'Press Enter to close'
    exit $code
}

# ---- Check Claude.exe is not running ----
Write-Host '[CHECK] Checking if Claude.exe is running...'
$claudeProc = Get-Process -Name 'Claude' -ErrorAction SilentlyContinue
if ($claudeProc) {
    Write-Host '[ERROR] Claude.exe is running. Please exit Claude Desktop completely and retry.' -ForegroundColor Red
    Write-Host '        Right-click the Claude icon in the system tray -> Exit'
    Write-Host '        Or use Task Manager to end all Claude.exe processes'
    Pause-Exit 1
}
Write-Host '[OK] Claude.exe is not running.' -ForegroundColor Green
Write-Host ''

# ---- Check source exists ----
if (-not (Test-Path -LiteralPath $SRC)) {
    Write-Host "[ERROR] Source folder not found: $SRC" -ForegroundColor Red
    Pause-Exit 1
}

# ---- Check if already a junction/reparse point ----
$srcItem = Get-Item -LiteralPath $SRC -Force
if ($srcItem.Attributes -band [System.IO.FileAttributes]::ReparsePoint) {
    Write-Host '[INFO] vm_bundles is already a junction / reparse point. Skipping.' -ForegroundColor Yellow
    Pause-Exit 0
}

# ---- Create destination parent ----
if (-not (Test-Path -LiteralPath $DSTPARENT)) {
    New-Item -ItemType Directory -Path $DSTPARENT -Force | Out-Null
    Write-Host "[OK] Created: $DSTPARENT" -ForegroundColor Green
} else {
    Write-Host "[INFO] $DSTPARENT already exists."
}
Write-Host ''

# ---- Grant AppContainer permission (critical for MSIX apps) ----
Write-Host "[STEP 1/4] Granting AppContainer permission on $DSTPARENT ..."
& icacls $DSTPARENT /grant '*S-1-15-2-1:(OI)(CI)F' /T | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Host '[ERROR] Failed to grant permissions.' -ForegroundColor Red
    Pause-Exit 1
}
Write-Host '[OK] Permissions granted.' -ForegroundColor Green
Write-Host ''

# ---- Move with robocopy ----
Write-Host '[STEP 2/4] Moving vm_bundles... (this may take several minutes)'
& robocopy $SRC $DST /E /MOVE /COPYALL /DCOPY:DAT /R:1 /W:1 /NP /NFL /NDL
$rcode = $LASTEXITCODE
# robocopy exit codes: 0-7 = success variants, 8+ = error
if ($rcode -ge 8) {
    Write-Host "[ERROR] robocopy failed. ExitCode=$rcode" -ForegroundColor Red
    Pause-Exit 1
}
Write-Host "[OK] Move completed. (robocopy ExitCode=$rcode)" -ForegroundColor Green
Write-Host ''

# ---- Remove source dir if still present ----
if (Test-Path -LiteralPath $SRC) {
    try {
        Remove-Item -LiteralPath $SRC -Recurse -Force -ErrorAction SilentlyContinue
    } catch {}
}

# ---- Create junction ----
Write-Host '[STEP 3/4] Creating junction...'
$mkResult = & cmd /c mklink /J "`"$SRC`"" "`"$DST`"" 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host '[ERROR] Failed to create junction.' -ForegroundColor Red
    Write-Host $mkResult
    Write-Host "Manual recovery: copy contents of $DST back to $SRC"
    Pause-Exit 1
}
Write-Host "[OK] $mkResult" -ForegroundColor Green
Write-Host ''

# ---- Verify ----
Write-Host '[STEP 4/4] Verification'
$finalItem = Get-Item -LiteralPath $SRC -Force
if ($finalItem.Attributes -band [System.IO.FileAttributes]::ReparsePoint) {
    Write-Host "  Junction OK: $SRC" -ForegroundColor Green
    Write-Host "         ---> $($finalItem.Target)" -ForegroundColor Green
} else {
    Write-Host '[WARN] Could not verify junction.' -ForegroundColor Yellow
}
Write-Host ''

Write-Host '============================================================' -ForegroundColor Cyan
Write-Host '  DONE!' -ForegroundColor Green
Write-Host ''
Write-Host '  Please re-launch Claude Desktop and verify it works.'
Write-Host "  To roll back: move files from $DST back to $SRC"
Write-Host '============================================================' -ForegroundColor Cyan

Pause-Exit 0
