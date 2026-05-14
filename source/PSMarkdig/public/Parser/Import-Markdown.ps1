
using namespace System.Collections
using namespace System.IO
using namespace Markdig
using namespace Markdig.Parsers
using namespace Markdig.Syntax

function Import-Markdown {
  <#
    .SYNOPSIS
      Accept markdown from the pipeline or file
    .EXAMPLE
      $doc = Get-ChildItem "Changlog.md" | Import-Markdown

    .EXAMPLE
      $doc = Get-Content "Changelog.md" | Import-Markdown
  #>
  [CmdletBinding(
    # NOTE: We expect text on the pipeline, unless the object has a `Path` or `PSPath` Property
    DefaultParameterSetName = 'AsText'
  )]
  [OutputType([Markdig.Syntax.MarkdownDocument])]
  param(

    # Content to be converted
    [Parameter(
      ParameterSetName = 'AsText',
      ValueFromPipeline
    )]
    [string[]]$Content,

    # A markdown file to be converted
    [Parameter(
      ParameterSetName = 'AsPath',
      ValueFromPipelineByPropertyName
    )]
    [Alias('PSPath')]
    [string[]]$Path,

    # A list of Markdig Extensions to add to the pipeline
    # all Extensions are enabled by default
    [Parameter()]
    [string[]]$Extensions,

    # Ignore trivia (whitespace, extra heading characters, unescaped strings, etc)
    [Parameter(
    )]
    [switch]$IgnoreTrivia,

    # Enable debug logging in the Markdown parser
    [Parameter(
    )]
    [switch]$DebugParser,

    # Path to the debug log for the parser (if enabled)
    [Parameter(
    )]
    [string]$LogPath
  )
  begin {}
  <# --------------------------------------------------------------------------
  This function is basically a wrapper around our private function
  `ConvertTo-MarkdigObject`
  -------------------------------------------------------------------------- #>
  process {
    switch ($PSCmdlet.ParameterSetName) {
      'AsText' {
        Write-Debug "Received text content"
        ConvertTo-MarkdigObject @PSBoundParameters
      }
      'AsPath' {
        foreach ($File in $Path) {
          if (Test-Path $File) {
            try {
              Write-Debug "Received Path to $File"
              $options = $PSBoundParameters
              [void]$options.Remove('Path')
              Get-Content $File -Raw
              | ConvertTo-MarkdigObject @PSBoundParameters
            } catch {
              $err = $_ # The original error
              $message = "Could not read from File"
              $exceptionText = ( @($message, $err.ToString()) -join "`n")
              $newException = [Exception]::new($exceptionText)
              $eRecord = [System.Management.Automation.ErrorRecord]::new(
                $newException,
                $err.FullyQualifiedErrorId,
                $err.CategoryInfo.Category,
                $File
              )
              $PSCmdlet.ThrowTerminatingError( $eRecord )
            }
          } else {
            throw "$File is not a valid path"
          }
        }
      }
    }
  }
  end {}
}
