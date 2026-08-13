
using namespace Markdig.Syntax

function Select-MarkdownHeading {
  <#
  .SYNOPSIS
    Get heading blocks from a parsed markdown document.
  .DESCRIPTION
    Returns HeadingBlock elements from the AST, optionally filtered by level.
    Accepts a [MarkdigDocument] wrapper on the pipeline.
  .EXAMPLE
    $doc | Select-MarkdownHeading
    # Returns all headings

  .EXAMPLE
    $doc | Select-MarkdownHeading -Level 2
    # Returns only H2 headings

  .EXAMPLE
    $doc | Select-MarkdownHeading -Level 1,2,3
    # Returns H1, H2, and H3 headings
  #>
  [CmdletBinding()]
  param(
    # The MarkdigDocument wrapper or raw MarkdownDocument
    [Parameter(
      Mandatory,
      Position = 0,
      ValueFromPipeline
    )]
    [object]$Element,

    # Filter by heading level(s). Valid values: 1-6.
    [Parameter()]
    [ValidateRange(1, 6)]
    [int[]]$Level
  )
  begin {
    Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
  }
  process {
    # Unwrap if we received a MarkdigDocument wrapper
    if ($Element -is [MarkdigDocument]) {
      $mdDoc = $Element.Ast
    } elseif ($Element -is [MarkdownDocument]) {
      $mdDoc = $Element
    } else {
      throw "Element must be a [MarkdigDocument] or [Markdig.Syntax.MarkdownDocument]. Got: $($Element.GetType().FullName)"
    }

    $headings = Select-MarkdigDescendant -Element $mdDoc -Type 'Markdig.Syntax.HeadingBlock'

    if ($PSBoundParameters.ContainsKey('Level')) {
      $headings | Where-Object { $_.Level -in $Level }
    } else {
      $headings
    }
  }
  end {
    Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
  }
}