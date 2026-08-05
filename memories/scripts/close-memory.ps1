[CmdletBinding()]
param(
  [string]$Filter,
  [string]$Tag,
  [switch]$NoArchive
)

$ErrorActionPreference = 'Stop'

$root    = Split-Path -Parent $PSScriptRoot
$current = Join-Path $root 'current'
$archive = Join-Path $PSScriptRoot 'archive.ps1'

if (-not $Filter -and -not $Tag) {
  throw "Provide at least one of -Filter (name/topic partial) or -Tag."
}

$files = Get-ChildItem -LiteralPath $current -Filter '*.md' -File

$targets = @()
foreach ($f in $files) {
  $lines = Get-Content -LiteralPath $f.FullName -TotalCount 20
  $inFrontMatter = $false
  $topic = ''
  $tags = ''
  $status = ''

  foreach ($line in $lines) {
    if ($line -eq '---') {
      if ($inFrontMatter) { break }
      $inFrontMatter = $true
      continue
    }
    if ($inFrontMatter -and $line -match '^topic:\s*(.*)')   { $topic = $Matches[1].Trim() }
    if ($inFrontMatter -and $line -match '^tags:\s*\[(.*)\]') { $tags = $Matches[1] }
    if ($inFrontMatter -and $line -match '^status:\s*(.*)')   { $status = $Matches[1].Trim() }
  }

  if (-not $status) { $status = 'open' }

  $byFilter = $Filter -and ($f.BaseName -like "*$Filter*" -or $topic -like "*$Filter*")
  $byTag    = $Tag    -and ($tags -split ',' | ForEach-Object { $_.Trim() }) -contains $Tag

  if (($byFilter -or $byTag) -and $status -ne 'done') {
    $targets += $f
  }
}

if ($targets.Count -eq 0) {
  Write-Output 'No matching open notes found in current/.' 
  exit 0
}

$marked = 0
foreach ($f in $targets) {
  $content = Get-Content -LiteralPath $f.FullName -Raw
  $updated = $content -replace '(?m)^status:\s*.*$', 'status: done'
  if ($updated -ne $content) {
    $updated | Set-Content -LiteralPath $f.FullName -Encoding utf8 -NoNewline
    $marked++
    Write-Output "Marked done: $($f.Name)"
  }
}

Write-Output "Marked $marked of $($targets.Count) note(s) done."

if (-not $NoArchive) {
  if (Test-Path -LiteralPath $archive) {
    & $archive
  } else {
    throw "archive.ps1 not found: $archive"
  }
}
