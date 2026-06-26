
using namespace System.Management.Automation
using namespace System.Collections
using namespace System.Text
using namespace Markdig
using namespace Markdig.Parsers
using namespace Markdig.Syntax

function ConvertTo-MarkdigObject {
  <#
    .SYNOPSIS
        Convert the given Markdown text into a Markdig object
    #>
  [CmdletBinding()]
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
    # We want to pass one *text object* to the parser, so we join all the individual lines, and normalize
    # the line-endings
    if ([string]::IsNullorEmpty($collect)) { throw 'No content receieved' }

    # Stuff the content back into the Content parameter
    if ($collect.Count -gt 1) {
      $Content = $collect -join "`n"
    } else {
      $Content = $collect
    }
    # !SECTION

    if (-not ($PSBoundParameters.ContainsKey('Pipeline'))) {
      $options = $PSBoundParameters
      foreach ($p in @('Content', 'Context')) {
        if (-not ($PSBoundParameters.ContainsKey($p))) {
          $null = $options.Remove($p)
        }
      }
      $Pipeline = New-MarkdigPipeline @options
      Remove-Variable options
    }

    # SECTION Parse the content
    if (-not ($PSBoundParameters.ContainsKey('Context'))) {
      $Context = New-MarkdownParserContext
    }
    Write-Debug "Parsing document $File"
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
      # NOTE: powershell sees the MarkdownDocument object as an array, and loves to
      # unroll it on the pipeline, so whenever you want to access the MarkdownDocument
      # object directly, do it like this:
      Write-Output $document -NoEnumerate
    } else {
      throw "There was an error parsing. No Markdown object was produced"
    }
    Write-Debug "`n$('-' * 80)`n-- End $($self.Name)`n$('-' * 80)"
  }
}