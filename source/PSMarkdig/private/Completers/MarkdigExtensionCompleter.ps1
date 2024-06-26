
using namespace Markdig
function MarkdigExtensionCompleter {
    [CmdletBinding()]
    param(
        $commandName,
        $parameterName,
        $wordToComplete,
        $commandAst,
        $fakeBoundParameters )

    $functionNames = [MarkdownExtensions]
    | Get-Member -Static
    | Where-Object Name -Match '^Use\w+'
    | Select-Object -expand Name

    if ($functionNames.Count -gt 0) {
        $functionNames -replace '^Use', ''
    }
}
