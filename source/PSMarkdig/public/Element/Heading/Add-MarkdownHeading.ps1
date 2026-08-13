
using namespace Markdig.Helpers
using namespace Markdig.Parsers
using namespace Markdig.Syntax
using namespace Markdig.Syntax.Inlines

function Add-MarkdownHeading {
  <#
  .SYNOPSIS
    Add a new heading to a parsed markdown document.
  .DESCRIPTION
    Creates a new HeadingBlock with the specified text and level, inserts it into
    the document AST at the given position, and marks the document as dirty.

    Trivia (whitespace after the # character, trailing newline) is set explicitly
    so the RoundtripRenderer produces well-formed output.

  .EXAMPLE
    $doc | Add-MarkdownHeading -Text 'New Section' -Level 2
    # Appends an H2 at the end of the document

  .EXAMPLE
    $doc | Add-MarkdownHeading -Text 'Introduction' -Level 1 -Position 0
    # Inserts an H1 at the very beginning
  #>
  [CmdletBinding()]
  param(
    # The MarkdigDocument wrapper to modify
    [Parameter(
      Mandatory,
      Position = 0,
      ValueFromPipeline
    )]
    [MarkdigDocument]$Document,

    # The heading text
    [Parameter(Mandatory)]
    [string]$Text,

    # The heading level (1-6)
    [Parameter()]
    [ValidateRange(1, 6)]
    [int]$Level = 1,

    # Position (0-based block index) to insert the heading.
    # -1 or omitting appends at the end.
    [Parameter()]
    [int]$Position = -1,

    # Pass through the MarkdigDocument on the pipeline
    [Parameter()]
    [switch]$PassThru
  )
  begin {
    Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
  }
  process {
    # Create the HeadingBlock
    # HeadingBlock requires a BlockParser - use the built-in HeadingBlockParser
    $heading = [HeadingBlock]::new([HeadingBlockParser]::new())
    $heading.Level = $Level
    $heading.HeaderChar = [char]'#'
    $heading.HeaderCharCount = $Level
    $heading.Column = 0
    $heading.IsSetext = $false

    # Set trivia for proper roundtrip rendering:
    # - TriviaAfterAtxHeaderChar = the space after "##" (one space is standard)
    # - NewLine = the line ending at the end of this block
    # - LinesBefore / LinesAfter = blank lines surrounding the heading
    $heading.TriviaAfterAtxHeaderChar = [StringSlice]::new(' ')
    $heading.NewLine = $Document.LineEnding

    # Add a blank line before the heading (unless it's at position 0)
    if ($Position -ne 0 -and $Document.Ast.Count -gt 0) {
      $heading.LinesBefore = [System.Collections.Generic.List[StringSlice]]::new()
      $heading.LinesBefore.Add([StringSlice]::Empty)
    }

    # Create the inline content (the heading text)
    $literal = [LiteralInline]::new($Text)
    $container = [ContainerInline]::new()
    $container.AppendChild($literal)
    $heading.Inline = $container

    # Insert into the document at the specified position
    if ($Position -lt 0 -or $Position -ge $Document.Ast.Count) {
      $Document.Ast.Add($heading)
    } else {
      $Document.Ast.Insert($Position, $heading)
    }

    # Mark the document as modified
    $Document.MarkModified()

    Write-Debug "Added H$Level heading '$Text' at position $(if ($Position -lt 0) { 'end' } else { $Position })"

    if ($PassThru) {
      $Document
    }
  }
  end {
    Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
  }
}