param(
  [string]$OutputPath = $(if ($PSScriptRoot) { Join-Path $PSScriptRoot 'github-pages-build' } else { Join-Path (Get-Location) 'github-pages-build' })
)

$publishProjectRoot = if ($PSScriptRoot) { $PSScriptRoot } else { Get-Location }
$artifactOutputPath = $OutputPath

$requiredFiles = @(
  'index.html',
  'compat.html',
  'THIRD_PARTY_NOTICES.md',
  'analysis_original_dosbox.png',
  'STAR_CHS',
  'STAR_CHT',
  'compat/runtime/js-dos.css',
  'compat/runtime/js-dos.js',
  'compat/runtime/emulators/emulators.js',
  'compat/runtime/emulators/wdosbox-x.js',
  'compat/runtime/emulators/wdosbox-x.wasm'
)

foreach ($relativePath in $requiredFiles) {
  $sourcePath = Join-Path $publishProjectRoot $relativePath
  if (-not (Test-Path -LiteralPath $sourcePath)) {
    throw "Missing publish input: $relativePath"
  }
}

if (Test-Path -LiteralPath $artifactOutputPath) {
  throw "Output path already exists; choose a new path or remove it explicitly: $artifactOutputPath"
}

$assetBuilder = Join-Path $publishProjectRoot 'compat/build-static-assets.ps1'
$assetOutput = Join-Path $publishProjectRoot 'compat/static-assets.js'
if ($PSScriptRoot) {
  & $assetBuilder -OutputPath $assetOutput
  if ($LASTEXITCODE -ne 0) { throw "Static asset generation failed" }
} else {
  $builderText = [System.IO.File]::ReadAllText($assetBuilder)
  Invoke-Expression $builderText
}

$runtimeOutput = Join-Path $artifactOutputPath 'compat/runtime'
$emulatorOutput = Join-Path $runtimeOutput 'emulators'
New-Item -ItemType Directory -Force -Path $emulatorOutput | Out-Null

Copy-Item -LiteralPath @(
  (Join-Path $publishProjectRoot 'index.html'),
  (Join-Path $publishProjectRoot 'compat.html'),
  (Join-Path $publishProjectRoot 'THIRD_PARTY_NOTICES.md'),
  (Join-Path $publishProjectRoot 'analysis_original_dosbox.png'),
  (Join-Path $publishProjectRoot 'analysis_original_dosbox_after_enter.png'),
  (Join-Path $publishProjectRoot 'analysis_original_dosbox_menu.png')
) -Destination $artifactOutputPath -Force

Copy-Item -LiteralPath @(
  (Join-Path $publishProjectRoot 'compat/static-assets.js')
) -Destination (Join-Path $artifactOutputPath 'compat') -Force

Copy-Item -LiteralPath @(
  (Join-Path $publishProjectRoot 'compat/runtime/js-dos.css'),
  (Join-Path $publishProjectRoot 'compat/runtime/js-dos.js')
) -Destination $runtimeOutput -Force

Copy-Item -LiteralPath @(
  (Join-Path $publishProjectRoot 'compat/runtime/emulators/emulators.js'),
  (Join-Path $publishProjectRoot 'compat/runtime/emulators/wdosbox-x.js'),
  (Join-Path $publishProjectRoot 'compat/runtime/emulators/wdosbox-x.wasm')
) -Destination $emulatorOutput -Force

$files = Get-ChildItem -File -Recurse -LiteralPath $artifactOutputPath
$bytes = ($files | Measure-Object -Property Length -Sum).Sum
Write-Output ("GitHub Pages artifact: {0} files, {1} MB, {2}" -f $files.Count, [math]::Round($bytes / 1MB, 2), $artifactOutputPath)
