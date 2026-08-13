
function MarkdigTypeCompleter {
  [CmdletBinding()]
  param(
    $commandName,
    $parameterName,
    $wordToComplete,
    $commandAst,
    $fakeBoundParameters
  )

  Get-MarkdigType
  | Select-Object -ExpandProperty Name
  | Where-Object { $_ -like "*$wordToComplete*" }
}