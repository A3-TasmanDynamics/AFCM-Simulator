<#
    AFCM-Simulator build script.

    Thin wrapper around `hemtt release` (https://hemtt.dev) that also drops an unzipped,
    ready-to-use @AFCM-Simulator mod folder next to this project for local/Eden testing --
    `hemtt release` on its own only produces zip archives under releases\.

    HEMTT already does everything a hand-rolled AddonBuilder script would otherwise need to:
    PBO packing/binarization, rapifying configs, signing, and bundling mod.cpp/meta.cpp into the
    release. There's no virtual-root/junction dance here (unlike older AddonBuilder-based
    projects) because this repo has exactly one addon prefix (afcm_sim) and no external Workshop
    dependencies that need de-rapping into the build.

    Usage:
        .\build.ps1                # unsigned build, refreshes @AFCM-Simulator next to the project
        .\build.ps1 -Sign          # signed release (required before any real distribution)
        .\build.ps1 -NoArchive     # skip the zip archives in releases\, folder only
#>
param(
    [switch]$Sign,
    [switch]$NoArchive
)

$ErrorActionPreference = "Stop"

if (Get-Process arma3_x64 -ErrorAction SilentlyContinue) {
    Write-Error "Arma 3 is running. Close it before rebuilding, then restart to pick up the new PBOs."
    exit 1
}

if (-not (Get-Command hemtt -ErrorAction SilentlyContinue)) {
    Write-Error "hemtt not found on PATH. Install it: https://hemtt.dev/hemtt/installing/"
    exit 1
}

$root = $PSScriptRoot
$modFolder = Join-Path $root "@AFCM-Simulator"

$hemttArgs = @("release")
if (-not $Sign) { $hemttArgs += "--no-sign" }
if ($NoArchive) { $hemttArgs += "--no-archive" }

if ($Sign -and -not (Test-Path (Join-Path $root ".hemtt\*.pem")) -and -not (Get-ChildItem -Path $root -Filter "*.biprivatekey" -ErrorAction SilentlyContinue)) {
    Write-Output "No signing key found. Generate one with: hemtt keys generate <KeyName>"
}

Push-Location $root
try {
    & hemtt @hemttArgs
    if ($LASTEXITCODE -ne 0) {
        Write-Error "hemtt release failed (exit $LASTEXITCODE)"
        exit 1
    }
} finally {
    Pop-Location
}

$releaseSource = Join-Path $root ".hemttout\release"
if (-not (Test-Path $releaseSource)) {
    Write-Error "Expected HEMTT output at $releaseSource but it doesn't exist."
    exit 1
}

if (Test-Path $modFolder) {
    Remove-Item $modFolder -Recurse -Force
}
Copy-Item $releaseSource $modFolder -Recurse

Write-Output ""
Write-Output "Mod folder ready: $modFolder"
if (-not $Sign) {
    Write-Output "NOTE: unsigned build - fine for local/Eden testing, but a verifySignatures dedicated server will reject it. Re-run with -Sign once a real key exists (hemtt keys generate)."
}
if (-not $NoArchive) {
    Write-Output "Distributable zips: $root\releases\"
}
