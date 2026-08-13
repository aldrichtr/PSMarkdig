

using namespace System.Text
using namespace System.Collections.Generic
using namespace Markdig
using namespace Markdig.Syntax
using namespace Markdig.Helpers
using namespace Markdig.Parsers

class MarkdigDocument {
  <#
  .SYNOPSIS
    Wrapper for Markdig.Syntax.MarkdownDocument that prevents pipeline unrolling
    and carries parse context alongside the AST.
  .DESCRIPTION
    MarkdownDocument implements IEnumerable, which causes PowerShell to unroll it
    on the pipeline. This class wraps the document and its associated parsing context
    so it can be piped naturally between PSMarkdig functions.
  .PARAMETER Document
    The parsed Abstract Syntax Tree
  .PARAMETER Pipeline
    The pipeline that produced this document (needed for roundtrip rendering and re-parsing)
  .PARAMETER Context
    The parser context (holds extension state, properties, etc.)
  .PARAMETER Path
    Source file path ($null when parsed from a string)
  .PARAMETER Encoding
    Original file encoding (for faithful write-back)
  .PARAMETER LineEnding
    The line-ending style detected in the source
  .PARAMETER Extensions
    The extension shortcodes that were active during parsing
  .PARAMETER Modified
    Tracks whether the AST has been modified since parsing
  .PARAMETER Metadata
    User-extensible metadata bag PSMarkdig doesn't touch this;
    scripts can stash annotations, lint results, etc.
  .PARAMETER ParsedAt
    When the document was parsed
  #>

  [MarkdownDocument]$Ast
  [MarkdownPipeline]$Pipeline
  [MarkdownParserContext]$Context
  [string]$Path
  [Encoding]$Encoding = [Encoding]::UTF8
  [NewLine]$LineEnding = [NewLine]::None
  [OrderedList[IMarkdownExtension]]$Extensions = [OrderedList[IMarkdownExtension]]::new()
  [bool]$Modified = $false
  [hashtable]$Metadata = @{}
  [System.DateTimeOffset]$ParsedAt

  # SECTION Constructors

  MarkdigDocument([MarkdownDocument]$ast, [MarkdownPipeline]$pipeline) {
    $this.Ast = $ast
    $this.Pipeline = $pipeline

    $this.Context  = [MarkdownParserContext]::new()
    $this.ParsedAt = [System.DateTimeOffset]::Now
  }

  MarkdigDocument([MarkdownDocument]$ast,
                  [MarkdownPipeline]$pipeline,
                  [MarkdownParserContext]$context) {
    $this.Ast = $ast
    $this.Pipeline = $pipeline
    $this.Context = $context
    $this.ParsedAt = [System.DateTimeOffset]::Now
  }
  # !SECTION

  # SECTION Methods

  [string] ToString() {
    $blocks = $this.Ast.Count
    $ext = $this.Pipeline.Extensions.Count
    $src = if ($this.Path) {
      $this.Path | Split-Path -Leaf
    } else {
      '<string>'
    }

    $mod = if ($this.Modified) { ' *' } else { '' }
    return "MarkdownDocument [$src] ($blocks blocks, $ext extensions)$mod"
  }

  # Convenience: mark the document as modified
  [void] MarkModified() {
    $this.Modified = $true
  }
  # !SECTION
}