$ErrorActionPreference = 'Stop'
$analysisRoot = if ($PSScriptRoot) { $PSScriptRoot } else { Join-Path (Get-Location) 'analysis' }
$root = Split-Path -Parent $analysisRoot
$indexPath = Join-Path $analysisRoot 'workspace_knowledge_index.json'
$registryPath = Join-Path $analysisRoot 'analysis_interface_registry.json'
$factsPath = Join-Path $analysisRoot 'facts.jsonl'

foreach ($path in @($indexPath, $registryPath, $factsPath)) {
  if (-not (Test-Path -LiteralPath $path)) { throw "missing: $path" }
}

$index = Get-Content -Raw -Encoding UTF8 $indexPath | ConvertFrom-Json
$registry = Get-Content -Raw -Encoding UTF8 $registryPath | ConvertFrom-Json
$factLines = Get-Content -Encoding UTF8 $factsPath | Where-Object { $_.Trim() }
$factIds = @{}
foreach ($line in $factLines) {
  $fact = $line | ConvertFrom-Json
  if ($factIds.ContainsKey($fact.id)) { throw "duplicate fact id: $($fact.id)" }
  $factIds[$fact.id] = $true
}

$ids = @{}
foreach ($item in $registry.interfaces) {
  if ($ids.ContainsKey($item.id)) { throw "duplicate interface id: $($item.id)" }
  $ids[$item.id] = $true
  foreach ($source in @($item.source_files)) {
    if ($source -notmatch '[*?]') {
      $path = Join-Path $root $source
      if (-not (Test-Path -LiteralPath $path)) { throw "missing source: $source" }
    }
  }
}

foreach ($pathValue in @($index.entrypoints.report, $index.entrypoints.registry, $index.entrypoints.facts, $index.entrypoints.web, $index.validation)) {
  $path = Join-Path $root $pathValue
  if (-not (Test-Path -LiteralPath $path)) { throw "missing index path: $pathValue" }
}

Write-Output ("analysis index valid: interfaces={0}, facts={1}" -f $registry.interfaces.Count, $factLines.Count)
