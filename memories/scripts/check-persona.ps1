[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

$root  = Split-Path -Parent $PSScriptRoot
$repo  = Split-Path -Parent $root
$canon = Join-Path $repo 'Freyja.txt'
$opCopy = Join-Path $root 'freyja.md'

if (-not (Test-Path -LiteralPath $canon))  { throw "Canonical persona not found: $canon" }
if (-not (Test-Path -LiteralPath $opCopy)) { throw "Operational copy not found: $opCopy" }

$canonLines = Get-Content -LiteralPath $canon
if ($canonLines[0] -match '^```') { $canonLines = $canonLines[1..($canonLines.Count - 2)] }
$opLines = Get-Content -LiteralPath $opCopy

$diff = Compare-Object -ReferenceObject $canonLines -DifferenceObject $opLines

Write-Output 'Persona drift check: Freyja.txt (canonical) vs memories/freyja.md (operational)'
Write-Output 'Differences are expected where the operational copy is intentionally sanitized.'
Write-Output ''

if (-not $diff) {
  Write-Output 'No differences - the copies are identical.'
  exit 0
}

Write-Output "Found $($diff.Count) differing line(s):"
Write-Output ''
foreach ($d in $diff) {
  $side = if ($d.SideIndicator -eq '=>') { 'operational-only' } else { 'canonical-only' }
  Write-Output "[$side] $($d.InputObject.ToString().TrimEnd())"
}
