
using namespace Markdig
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
        [string[]]$Text,

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
            ParameterSetName = 'debuglog'
        )]
        [switch]$DebugParser,

        # Path to the debug log for the parser (if enabled)
        [Parameter(
            ParameterSetName = 'debuglog'
        )]
        [string]$LogPath = "$(Get-Location)\markdig.parser.log"
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
        if ($PSBoundParameters.ContainsKey('Extension')) {
            $markdigExtension = $Extension -join '+'
        } else {
            $markdigExtension = 'advanced+yaml'
        }
        Write-Debug "Setting extensions to $markdigExtension"


        $collect = [string]''
    }
    process {
        $collect += $Text
    }
    end {
        Write-Debug "Content is:`n$([regex]::Escape($collect) -replace '\\n', "\n`n")"
        if ([string]::IsNullorEmpty($collect)) {
            throw 'No content was received'
        } else {
            Write-Debug "Length of content to be parsed: $($collect.Length)"
        }

        $builder = [MarkdownPipelineBuilder]::new()

        if ($DebugParser) {
            Write-Debug "Markdown parser debug enabled.  Writing to $LogPath"

            [TextWriter]$tw = [File]::CreateText( $LogPath )
            $builder.DebugLog = $tw
        }
        $builder = [MarkdownExtensions]::Configure($builder, $markdigExtension)

        # This enables the parser to track whitespace and newlines
        if (-not($IgnoreTrivia)) {
            $builder.PreciseSourceLocation = $true
            $builder = [MarkdownExtensions]::EnableTrackTrivia($builder)

        } else {
            Write-Verbose 'Ignoring whitespace and other trivia'
        }

        $builder = [MarkdownExtensions]::UseReferralLinks($builder, 'nofollow')
        $builder = [MarkdownExtensions]::UseReferralLinks($builder, 'noopener')
        Write-Debug 'Parser configured'
        $extensions = $builder.Extensions
        | ForEach-Object {
            $_.GetType()
            | Select-Object -ExpandProperty Name
        }
        Write-Debug ('- {0,-28} => {1}' -f 'Extensions', (($extensions -replace 'Extension$', '') -join ', '))
        Write-Debug ('- {0,-28} => {1}' -f 'Precise Source Location', $builder.PreciseSourceLocation)
        Write-Debug ('- {0,-28} => {1}' -f 'Track trivia(whitespace)', $builder.TrackTrivia)
        Write-Debug ('- {0,-28} => {1}' -f 'Debug Log', $builder.DebugLog)

        $script:pipeline = $builder.Build()

        Write-Debug "Parsing document $File"
        $context = [MarkdownParserContext]::new()
        $document = New-Object MarkdownDocument
        $document = [MarkdownParser]::Parse( $collect , $script:pipeline , $context)
        Write-Debug "Context properties: $($context.Properties.Keys.Count))"
        if ($null -ne $tw) {
            $tw.Flush()
            $tw.Close()
        }
        Write-Debug "Parsing complete. created $($document.GetType())"

        if ($null -ne $document) {
            Write-Output $document -NoEnumerate
        } else {
            throw "There was an error parsing $File"
        }
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
