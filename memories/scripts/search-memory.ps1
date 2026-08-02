[CmdletBinding()]
param(
  [Parameter(Mandatory)]
  [string]$Query
)

$root = Split-Path -Parent $PSScriptRoot

Get-ChildItem -Path $root -Recurse -Filter '*.md' -File |
  Select-String -Pattern $Query -SimpleMatch |
  ForEach-Object {
    [pscustomobject]@{
      File = $_.Path
      Line = $_.LineNumber
      Text = $_.Line.Trim()
    }
  }