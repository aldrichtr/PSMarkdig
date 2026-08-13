
using namespace System.Management.Automation
using namespace System.Collections
using namespace System.Text
using namespace Markdig
using namespace Markdig.Parsers
using namespace Markdig.Syntax
using namespace Markdig.Helpers

function ConvertTo-MarkdigObject {
  <#
    .SYNOPSIS
        Convert the given Markdown text into a MarkdigDocument wrapper object
    .DESCRIPTION
        Parses markdown content using the Markdig library and returns a [MarkdigDocument]
        wrapper that carries the AST, pipeline, context, and source metadata together.
        This wrapper prevents PowerShell pipeline unrolling of the MarkdownDocument.
    #>
  [CmdletBinding()]
  [OutputType([MarkdigDocument])]
  param(
    # The text to parse into a markdig object
    [Parameter(
      ValueFromPipeline,
      ValueFromPipelineByPropertyName
    )]
    [string[]]$Content,

    # Provide a custom list of extensions
    [Parameter()]
    [PSTypeName('PSMarkdig.MarkdownExtensionInfo')]
    [Object[]]$Extensions,

    # Use an existing pipeline
    [Parameter(
    )]
    [MarkdownPipeline]$Pipeline,

    # Pass in a custom ParserContext
    [Parameter(
    )]
    [MarkdownParserContext]$Context,

    # Ignore trivia (whitespace, extra heading characters, unescaped strings, etc)
    [Parameter(
    )]
    [switch]$IgnoreTrivia,

    # Enable debug logging in the Markdown parser
    [Parameter(
      ParameterSetName = 'debuglog'
    )]
    [switch]$DebugParser,

    # If DebugParser is given but no LogPath, then use [System.Console]::Out as the TextWriter
    # Path to the debug log for the parser (if enabled)
    [Parameter(
      ParameterSetName = 'debuglog'
    )]
    [string]$LogPath
  )
  begin {
    $collect = [ArrayList]::new()
  }
  process {
    # SECTION Collect incoming content

    foreach ($text in $Content) {
      $null = $collect.Add($text)
    }
    # !SECTION
  }
  end {
    # SECTION Normalize the content
    # MarkdownParser.Parse needs a single string. We must join the collected
    # pieces WITHOUT clobbering any line endings they already carry, otherwise
    # the parser (and downstream NewLine detection) loses CRLF fidelity.
    if ([string]::IsNullorEmpty($collect)) { throw 'No content received' }

    if ($collect.Count -gt 1) {
      # Two shapes reach here:
      #   1. A single ReadAllText() result split into one element -- handled by
      #      the else branch below (its embedded `r`n is preserved verbatim).
      #   2. Many elements (e.g. Get-Content, which strips line endings). We
      #      must re-insert a separator between them. If ANY element already
      #      contains its own line ending, the content is pre-formatted -- join
      #      with the empty string so we don't inject or alter endings. Only
      #      when the elements are bare (no endings at all) do we join with a
      #      newline, honoring the source style if we can infer it.
      $joined = ($collect -join '')
      if ($joined -match "`r`n" -or $joined -match "`r" -or $joined -match "`n") {
        # Elements already carry their own endings -- preserve exactly.
        $Content = $joined
      } else {
        # Bare lines with no endings: re-join with a single LF. (CommonMark is
        # LF-oriented; a caller wanting CRLF should pass pre-formatted text or
        # a file path, which flow through the fidelity-preserving paths above.)
        $Content = $collect -join "`n"
      }
    } else {
      # Single element -- pass through untouched so embedded `r`n survives.
      $Content = $collect
    }
    # !SECTION

    if (-not ($PSBoundParameters.ContainsKey('Pipeline'))) {
      $options = @{}
      foreach ($p in @('Extensions', 'IgnoreTrivia', 'DebugParser', 'LogPath')) {
        if ($PSBoundParameters.ContainsKey($p)) {
          $options[$p] = $PSBoundParameters[$p]
        }
      }
      $Pipeline = New-MarkdigPipeline @options
      Remove-Variable options
    }

    # SECTION Parse the content
    if (-not ($PSBoundParameters.ContainsKey('Context'))) {
      $Context = New-MarkdownParserContext
    }
    Write-Debug 'Parsing document'
    Write-Debug "Document Content:`n$Content"
    try {
      [MarkdownDocument]$document = [MarkdownParser]::Parse( $Content , $Pipeline , $Context)
    } catch {
      $err = $_ # The original error
      $message = 'There was an error parsing the content'
      $exceptionText = ( @($message, $err.ToString()) -join "`n")
      $newException = [Exception]::new($exceptionText)
      $eRecord = [ErrorRecord]::new(
        $newException,
        $err.FullyQualifiedErrorId,
        $err.CategoryInfo.Category,
        $null
      )
      $PSCmdlet.ThrowTerminatingError( $eRecord )
    } finally {
      if ($null -ne $Script:ParserDebugWriter) {
        $Script:ParserDebugWriter.Flush()
        $Script:ParserDebugWriter.Close()
        Remove-Variable 'ParserDebugWriter' -Scope Script -ErrorAction SilentlyContinue
      }
    }

    Write-Debug "Parsing complete. created $($document.GetType())"
    # !SECTION

    if ($null -ne $document) {
      # SECTION Build the MarkdigDocument wrapper
      Write-Debug "Creating MarkdigDocument"
      $result = [MarkdigDocument]::new($document, $Pipeline, $Context)

      # SECTION Detect the source line ending
      # MarkdownDocument is the outermost container Block and has no "last
      # newline" of its own, so $document.NewLine is always None (0). The
      # detected line ending lives on the child blocks -- see Markdig
      # Roundtrip.md ("Newlines": the Block class defines
      # 'public NewLine NewLine { get; set; }' as "the last newline of this
      # block"). NewLine is only populated when TrackTrivia is enabled, which
      # New-MarkdigPipeline does by default (-not $IgnoreTrivia).
      #
      # Scan the child blocks for the first one carrying a real newline. If no
      # block records one (trivia-only or empty input), fall back to sniffing
      # the raw parsed text.
      $detected = [NewLine]::None
      foreach ($block in $document) {
        if ($block.NewLine -ne [NewLine]::None) {
          $detected = $block.NewLine
          break
        }
      }

      if ($detected -eq [NewLine]::None) {
        # Fallback: derive from the raw text handed to the parser. Order
        # matters -- test for CRLF before the bare CR/LF cases.
        $text = [string]$Content
        if ($text -match "`r`n") {
          $detected = [NewLine]::CarriageReturnLineFeed
        } elseif ($text -match "`r") {
          $detected = [NewLine]::CarriageReturn
        } elseif ($text -match "`n") {
          $detected = [NewLine]::LineFeed
        }
      }
      $result.LineEnding = $detected
      Write-Debug "Detected line ending: $detected"
      # !SECTION

      # Record which extensions were active (shortcodes for easy inspection)
      $result.Extensions = $Pipeline.Extensions

      $result
      # !SECTION
    } else {
      throw 'There was an error parsing. No Markdown object was produced'
    }
    Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
  }
}