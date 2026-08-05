[CmdletBinding()]
param(
  [Parameter(Mandatory)]
  [string]$FileName,

  [Parameter(Mandatory)]
  [string]$NewName
)

$ErrorActionPreference = 'Stop'

$root    = Split-Path -Parent $PSScriptRoot
$current = Join-Path $root 'current'
$core    = Join-Path $root 'core'
$archive = Join-Path $root 'scripts\archive.ps1'

if (-not $FileName.EndsWith('.md', [System.StringComparison]::OrdinalIgnoreCase)) {
  $FileName = "$FileName.md"
}
if (-not $NewName.EndsWith('.md', [System.StringComparison]::OrdinalIgnoreCase)) {
  $NewName = "$NewName.md"
}

$dest   = Join-Path $core $NewName

$source = Join-Path $current $FileName
if (-not (Test-Path -LiteralPath $source)) {
  $matches = Get-ChildItem -LiteralPath $current -Filter "*_$FileName" -File -ErrorAction SilentlyContinue
  if ($matches.Count -eq 1) {
    $source = $matches[0].FullName
  } elseif ($matches.Count -gt 1) {
    throw "Multiple current memories match '$FileName'. Pass the full filename (e.g. '2026-08-04_$FileName')."
  }
}

if (-not (Test-Path -LiteralPath $source)) {
  throw "Source file not found: $source"
}

if (Test-Path -LiteralPath $dest) {
  throw "Destination already exists: $dest"
}

Move-Item -LiteralPath $source -Destination $dest -Force
Write-Output "Promoted memory to core: $dest"

if (Test-Path -LiteralPath $archive) {
  & $archive | Out-Null
  Write-Output "Index regenerated."
}
