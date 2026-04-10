
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

    # Additional extensions to add
    <#
          **Note** by default, the following extensions are enabled:

          | list                | of                             | extensions           |
          | :---                | :---                           | :---                 |
          | UseAbbreviations    | UseAutoIdentifiers             | UseCitations         |
          | UseCustomContainers | UseDefinitionLists             | UseEmphasisExtras    |
          | UseFigures          | UseFooters                     | UseFootnotes         |
          | UseGridTables       | UseMathematics                 | UseMediaLinks        |
          | UsePipeTables       | UseListExtras                  | UseTaskLists         |
          | UseDiagrams         | UseAutoLinks                   | UseGenericAttributes |
          | UseYamlFrontMatter  | UseReferralLinks("noreferrer") |                      |

        #>
    [Parameter(
    )]
    [string[]]$Extension,

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
  begin {
    $self = $MyInvocation.MyCommand
    Write-Debug "`n$('-' * 80)`n-- Begin $($self.Name)`n$('-' * 80)"
  }
  process {
    switch ($PSCmdlet.ParameterSetName) {
      'AsText' {
        Write-Debug "Received text content`n$Content"
        Write-Debug "Calling convert with $($PSBoundParameters | Out-String)"
        ConvertTo-MarkdigObject @PSBoundParameters
      }
      'AsPath' {
        foreach ($File in $Path) {
          if (Test-Path $File) {
            try {
              Write-Debug "Getting content from $File"
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
  end {
    Write-Debug "`n$('-' * 80)`n-- End $($self.Name)`n$('-' * 80)"
  }
}
