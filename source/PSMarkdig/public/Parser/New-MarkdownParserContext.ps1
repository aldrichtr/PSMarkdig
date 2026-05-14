
using namespace Markdig

function New-MarkdownParserContext {
  <#
  .SYNOPSIS
    Create a new Context for the Markdown Parser
  #>
  [CmdletBinding()]
  param()
    [MarkdownParserContext]::new()
}
