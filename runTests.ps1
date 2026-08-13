param(
  [string[]]$Tags
)
$ProjectName = 'PSMarkdig'
$BuildRoot = $PSScriptRoot

$sourceDir = (Join-Path $BuildRoot "source" $ProjectName)
$manifest  = (Join-Path $sourceDir "$ProjectName.psd1")

$mod = Get-Module $ProjectName -ErrorAction SilentlyContinue

if ($null -ne $mod) {
  try {
    $mod | Remove-Module -ErrorAction Stop
  } catch {
    throw "Could not unload $ProjectName.`n$_"
  }
}
try {
  Import-Module $manifest -Force
} catch {
  throw "Could not load $ProjectName from $manifest`n$_"
}

$config = New-PesterConfiguration
$config.Run.Path = "$BuildRoot/tests"
$config.Output.Verbosity = "Normal"

if ($null -ne $Tags) {
  if ($Tags -notlike "All") {
    $config.Filter.Tag = $Tags
  }
}
Invoke-Pester -Configuration $config