
function MarkdigExtensionCompleter {
  [CmdletBinding()]
  param(
    $commandName,
    $parameterName,
    $wordToComplete,
    $commandAst,
    $fakeBoundParameters )

  Get-MarkdigExtension |
    Select-Object -ExpandProperty Name
}
