
using namespace System.Management.Automation
using namespace Markdig.Syntax

function Select-MarkdownYamlFrontMatterBlock {
  <#
  .SYNOPSIS
    Return an object representing the Yaml Frontmatter of the given markdown document
  .DESCRIPTION
    Accepts a [MarkdigDocument] wrapper or raw [MarkdownDocument] and extracts the
    YAML front matter block, converting it to a PowerShell object.
  #>
  [CmdletBinding()]
  param(
    # The MarkdigDocument wrapper or raw MarkdownDocument
    [Parameter(
      Mandatory,
      ValueFromPipeline,
      Position = 0
    )]
    [object]$Element
  )
  begin {}
  process {
    # Unwrap if we received a MarkdigDocument wrapper
    if ($Element -is [MarkdigDocument]) {
      $mdDoc = $Element.Ast
    } elseif ($Element -is [MarkdownDocument]) {
      $mdDoc = $Element
    } else {
      throw (@(
        'Element must be a [MarkdigDocument]',
        'or [Markdig.Syntax.MarkdownDocument].',
        'Got:',
        $Element.GetType().FullName
      ) -join ' ')
    }

    $options = @{
      Element = $mdDoc
      Type    = 'Markdig.Extensions.Yaml.YamlFrontMatterBlock'
    }
    try {
      Select-MarkdigDescendant @options
    } catch {
      $PSCmdlet.ThrowTerminatingError($PSItem)
    }
  }
  end {}
}
