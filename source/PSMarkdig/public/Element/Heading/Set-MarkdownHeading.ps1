
using namespace Markdig.Helpers
using namespace Markdig.Syntax
using namespace Markdig.Syntax.Inlines

function Set-MarkdownHeading {
  <#
  .SYNOPSIS
    Modify an existing heading's level or text.
  .DESCRIPTION
    Changes the level and/or text of an existing HeadingBlock in the AST.
    Accepts a HeadingBlock from the pipeline (e.g., from Select-MarkdownHeading)
    and a reference to the parent MarkdigDocument to mark dirty.

  .EXAMPLE
    $doc | Select-MarkdownHeading -Level 2 | Select-Object -First 1 | Set-MarkdownHeading -Level 3 -Document $doc
    # Demote the first H2 to an H3

  .EXAMPLE
    $doc | Select-MarkdownHeading -Level 1 | Set-MarkdownHeading -Text 'New Title' -Document $doc
    # Change the text of all H1 headings
  #>
  [CmdletBinding(SupportsShouldProcess)]
  param(
    # The HeadingBlock to modify
    [Parameter(
      Mandatory,
      Position = 0,
      ValueFromPipeline
    )]
    [HeadingBlock]$Heading,

    # The MarkdigDocument that contains this heading (needed to mark dirty)
    [Parameter(Mandatory)]
    [MarkdigDocument]$Document,

    # New heading level (1-6)
    [Parameter()]
    [ValidateRange(1, 6)]
    [int]$Level,

    # New heading text
    [Parameter()]
    [string]$Text,

    # Pass through the HeadingBlock on the pipeline
    [Parameter()]
    [switch]$PassThru
  )
  begin {
    Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
  }
  process {
    $description = "Heading at line $($Heading.Line)"

    if ($PSCmdlet.ShouldProcess($description, 'Modify heading')) {
      if ($PSBoundParameters.ContainsKey('Level')) {
        Write-Debug "Changing heading level from $($Heading.Level) to $Level"
        $Heading.Level = $Level
        $Heading.HeaderCharCount = $Level
      }

      if ($PSBoundParameters.ContainsKey('Text')) {
        Write-Debug "Changing heading text to '$Text'"
        # Replace the inline content
        $literal = [LiteralInline]::new($Text)
        $container = [ContainerInline]::new()
        $container.AppendChild($literal)
        $Heading.Inline = $container
      }

      $Document.MarkModified()
    }

    if ($PassThru) {
      $Heading
    }
  }
  end {
    Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
  }
}