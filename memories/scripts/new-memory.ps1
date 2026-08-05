[CmdletBinding()]
param(
  [Parameter(Mandatory)]
  [ValidateSet('core','current')]
  [string]$Bucket,

  [Parameter(Mandatory)]
  [string]$Topic,

  [string[]]$Tags = @(),

  [string]$Summary = '',

  [string]$Status = 'open'
)

$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
$dir  = Join-Path $root $Bucket

if (-not (Test-Path -LiteralPath $dir)) {
  New-Item -ItemType Directory -Path $dir -Force | Out-Null
}

$now      = Get-Date
$date     = $now.ToString('yyyy-MM-dd')
$iso      = $now.ToString("yyyy-MM-dd'T'HH:mm:ss")
$safeTopic = ($Topic.ToLower() -replace '[^a-z0-9\-_]+', '_').Trim('_')

$fileName = if ($Bucket -eq 'current') {
  "${date}_${safeTopic}.md"
} else {
  "${safeTopic}.md"
}

$path = Join-Path $dir $fileName
$tagText = if ($Tags.Count -gt 0) { $Tags -join ', ' } else { '' }

$content = @"
---
id: ${date}_${safeTopic}
type: $Bucket
topic: $Topic
tags: [$tagText]
priority: medium
date: $iso
updated: $iso
status: $Status
summary: $Summary
---

# $Topic

## Goal
- 

## Current state
- 

## Notes
- 
"@

$content | Set-Content -LiteralPath $path -Encoding utf8
Write-Output "Created memory: $path"

$archive = Join-Path $PSScriptRoot 'archive.ps1'
if (Test-Path -LiteralPath $archive) {
  & $archive | Out-Null
  Write-Output "Index regenerated."
}