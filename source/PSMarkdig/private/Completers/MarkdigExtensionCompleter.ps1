
using namespace System.Management.Automation

function MarkdigExtensionCompleter {
  [CmdletBinding()]
  param(
    $commandName,
    $parameterName,
    $wordToComplete,
    $commandAst,
    $fakeBoundParameters )

  Get-MarkdigExtension
  | Where-Object { $_.Name -like "$wordToComplete*" }
  | Foreach-Object {
    [CompletionResult]::new( $_.Name, $_.FullName,
      [CompletionResultType]::Text, $_.FullName )
  }
}