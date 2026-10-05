
"$($PSStyle.Foreground.Cyan)-- PSMarkdig Debug Harness --$($PSStyle.Reset)"

Import-Module "$PSScriptRoot/source/PSMarkdig/PSMarkdig.psd1" -Force

$file = Get-Item "./tests/data/GenericAttributesSpecs.md"

$doc = $file | Import-Markdown


$doc.GetType().FullName
