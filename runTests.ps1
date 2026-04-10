$BuildRoot = $PSScriptRoot


Import-Module "$BuildRoot/source/PSMarkdig/PSMarkdig.psd1" -Force
$config = New-PesterConfiguration

$config.Run.Path = "$BuildRoot/tests"

Invoke-Pester -Configuration $config
