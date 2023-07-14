
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
        # **Note** by default, the following extensions are enabled:
        # UseAbbreviations
        # UseAutoIdentifiers
        # UseCitations
        # UseCustomContainers
        # UseDefinitionLists
        # UseEmphasisExtras
        # UseFigures
        # UseFooters
        # UseFootnotes
        # UseGridTables
        # UseMathematics
        # UseMediaLinks
        # UsePipeTables
        # UseListExtras
        # UseTaskLists
        # UseDiagrams
        # UseAutoLinks
        # UseGenericAttributes
        # UseYamlFrontMatter
        # UseReferralLinks("noreferrer")

        [Parameter(
        )]
        [string[]]$Extension,

        # Enable debug logging in the Markdown parser
        [Parameter(
        )]
        [switch]$DebugParser,

        # Path to the debug log for the parser (if enabled)
        [Parameter(
        )]
        [string]$LogPath = "$(Get-Location)\markdig.parser.log"
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
        if ($PSBoundParameters.ContainsKey('Extension')) {
            $markdigExtension = $Extension -join '+'
        } else {
            $markdigExtension = 'advanced+yaml+noreferrerlinks'
        }
        Write-Debug "Setting extensions to $markdigExtension"
    }
    process {
        foreach ($File in $Path) {
            if (Test-Path $File) {
                try {
                    Write-Debug "Getting content from $File"
                    $content = Get-Content $File -Raw
                    $builder = [MarkdownPipelineBuilder]::new()

                    if ($DebugParser) {
                        Write-Debug "Markdown parser debug enabled.  Writing to $LogPath"

                        [TextWriter]$tw = [File]::CreateText( $LogPath )
                        $builder.DebugLog = $tw
                    }
                    $builder = [MarkdownExtensions]::Configure($builder, $markdigExtension)
                    # This enables the parser to track whitespace and newlines
                    $builder.PreciseSourceLocation = $true
                    $builder = [MarkdownExtensions]::EnableTrackTrivia($builder)

                    Write-Debug 'Parser configured'
                    $extensions = $builder.Extensions | ForEach-Object { $_.GetType() | Select-Object -ExpandProperty Name }
                    Write-Debug ('- {0,-28} => {1}' -f 'Extensions', (($extensions -replace 'Extension$', '') -join ', '))
                    Write-Debug ('- {0,-28} => {1}' -f 'Precise Source Location', $builder.PreciseSourceLocation)
                    Write-Debug ('- {0,-28} => {1}' -f 'Track trivia(whitespace)', $builder.TrackTrivia)
                    Write-Debug ('- {0,-28} => {1}' -f 'Debug Log', $builder.DebugLog)

                    $pipeline = $builder.Build()

                    Write-Debug "Parsing document $File"

                    $document = New-Object MarkdownDocument
                    $document = [MarkdownParser]::Parse( $content , $pipeline )

                    Write-Debug "Parsing complete. created $($document.GetType())"

                    if ($null -ne $document) {

                        $PSCmdlet.WriteObject([ref]$document, $false)
                    } else {
                        throw "There was an error parsing $File"
                    }
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
