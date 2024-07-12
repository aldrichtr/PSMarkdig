
using namespace System.IO
using namespace Markdig
using namespace Markdig.Parsers
using namespace Markdig.Syntax

function Import-Markdown {
    [CmdletBinding()]
    [OutputType([Markdig.Syntax.MarkdownDocument])]
    param(
        # A markdown file to be converted
        [Parameter(
            ValueFromPipeline
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
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
    process {
        foreach ($File in $Path) {
            if (Test-Path $File) {
                try {
                    Write-Debug "Getting content from $File"
                    $options = $PSBoundParameters
                    [void]$options.Remove('Path')
                    Get-Content $File -Raw
                      | ConvertTo-MarkdigObject @PSBoundParameters
                } catch {
                    $PSCmdlet.ThrowTerminatingError($_)
                }
            } else {
                throw "$File is not a valid path"
            }
        }
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
