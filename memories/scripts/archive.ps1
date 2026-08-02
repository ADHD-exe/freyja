[CmdletBinding()]
param(
  [int]$Days = 7
)

$ErrorActionPreference = 'Stop'

$root    = Split-Path -Parent $PSScriptRoot
$current = Join-Path $root 'current'
$old     = Join-Path $root 'old'
$core    = Join-Path $root 'core'
$index   = Join-Path $root 'INDEX.md'

foreach ($dir in @($current, $old, $core)) {
  if (-not (Test-Path -LiteralPath $dir)) {
    New-Item -ItemType Directory -Path $dir -Force | Out-Null
  }
}

function Get-Meta {
  param([string]$Path)

  $tags = ''
  $topic = ''
  $type = ''
  $summary = ''

  $lines = Get-Content -LiteralPath $Path -TotalCount 20
  $inFrontMatter = $false

  foreach ($line in $lines) {
    if ($line -eq '---') {
      if ($inFrontMatter) { break }
      $inFrontMatter = $true
      continue
    }

    if ($inFrontMatter -and $line -match '^tags:\s*\[(.*)\]')   { $tags = $Matches[1].Trim() }
    if ($inFrontMatter -and $line -match '^topic:\s*(.*)')      { $topic = $Matches[1].Trim() }
    if ($inFrontMatter -and $line -match '^type:\s*(.*)')       { $type = $Matches[1].Trim() }
    if ($inFrontMatter -and $line -match '^summary:\s*(.*)')    { $summary = $Matches[1].Trim() }
  }

  [pscustomobject]@{
    Type    = $type
    Topic   = $topic
    Tags    = $tags
    Summary = $summary
  }
}

$today = (Get-Date).Date
$moved = 0

Get-ChildItem -LiteralPath $current -Filter '*.md' -File | ForEach-Object {
  $fileDate = if ($_.BaseName -match '^(\d{4})-(\d{2})-(\d{2})_') {
    [datetime]::new([int]$Matches[1], [int]$Matches[2], [int]$Matches[3])
  } else {
    $_.LastWriteTime.Date
  }

  if (($today - $fileDate).Days -ge $Days) {
    Move-Item -LiteralPath $_.FullName -Destination (Join-Path $old $_.Name) -Force
    $moved++
  }
}

$out = @(
  '# Memories Index',
  '',
  'Auto-generated. Do not edit by hand.',
  '',
  "Generated: $((Get-Date).ToString('yyyy-MM-dd HH:mm:ss'))"
)

foreach ($section in @(
  @{ Label = 'Core';    Path = $core },
  @{ Label = 'Current'; Path = $current },
  @{ Label = 'Old';     Path = $old }
)) {
  $out += ''
  $out += "## $($section.Label)"
  $out += ''

  $files = Get-ChildItem -LiteralPath $section.Path -Filter '*.md' -File | Sort-Object Name

  if (-not $files) {
    $out += '_empty_'
    continue
  }

  foreach ($f in $files) {
    $m = Get-Meta -Path $f.FullName
    $extra = @()

    if ($m.Type)    { $extra += "type: $($m.Type)" }
    if ($m.Topic)   { $extra += $m.Topic }
    if ($m.Tags)    { $extra += "tags: $($m.Tags)" }
    if ($m.Summary) { $extra += $m.Summary }

    if ($extra.Count -gt 0) {
      $out += "- $($f.Name) ($($extra -join ' | '))"
    } else {
      $out += "- $($f.Name)"
    }
  }
}

$out | Set-Content -LiteralPath $index -Encoding utf8

Write-Output "Archived $moved file(s). Index written to $index."