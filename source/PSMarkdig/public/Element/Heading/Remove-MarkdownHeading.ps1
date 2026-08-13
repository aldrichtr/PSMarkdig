
using namespace Markdig.Syntax

function Remove-MarkdownHeading {
  <#
  .SYNOPSIS
    Remove a heading from the document AST.
  .DESCRIPTION
    Removes the specified HeadingBlock from its parent container using Markdig's
    built-in Remove() helper, which handles parent/child ownership correctly.

  .EXAMPLE
    $doc | Select-MarkdownHeading -Level 3 | Remove-MarkdownHeading -Document $doc
    # Remove all H3 headings from the document
  #>
  [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
  param(
    # The HeadingBlock to remove
    [Parameter(
      Mandatory,
      Position = 0,
      ValueFromPipeline
    )]
    [HeadingBlock]$Heading,

    # The MarkdigDocument that contains this heading (needed to mark dirty)
    [Parameter(Mandatory)]
    [MarkdigDocument]$Document
  )
  begin {
    Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
  }
  process {
    $inlineText = if ($null -ne $Heading.Inline) {
      $Heading.Inline.ToString()
    } else { '<empty>' }
    $description = "H$($Heading.Level) '$inlineText' at line $($Heading.Line)"

    if ($PSCmdlet.ShouldProcess($description, 'Remove heading')) {
      Write-Debug "Removing heading: $description"
      # Markdig's Block.Remove() handles parent/child cleanup
      $Heading.Remove()
      $Document.MarkModified()
    }
  }
  end {
    Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
  }
}