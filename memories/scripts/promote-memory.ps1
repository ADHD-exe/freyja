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

$source = Join-Path $current $FileName
$dest   = Join-Path $core $NewName

if (-not (Test-Path -LiteralPath $source)) {
  throw "Source file not found: $source"
}

Copy-Item -LiteralPath $source -Destination $dest -Force
Write-Output "Promoted memory to core: $dest"