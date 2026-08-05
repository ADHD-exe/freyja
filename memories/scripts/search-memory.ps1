[CmdletBinding()]
param(
  [Parameter(Mandatory)]
  [string]$Query
)

$ErrorActionPreference = 'Stop'

$root    = Split-Path -Parent $PSScriptRoot
$current = Join-Path $root 'current'

$results = Get-ChildItem -Path $root -Recurse -Filter '*.md' -File |
  Select-String -Pattern $Query -SimpleMatch

foreach ($match in $results) {
  if ($match.Path.StartsWith($current, [System.StringComparison]::OrdinalIgnoreCase)) {
    (Get-Item -LiteralPath $match.Path).LastWriteTime = Get-Date
  }
}

$results | ForEach-Object {
  [pscustomobject]@{
    File = $_.Path
    Line = $_.LineNumber
    Text = $_.Line.Trim()
  }
}
