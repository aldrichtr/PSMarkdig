
function Get-MarkdigExtension {
    <#
    .SYNOPSIS
        List Extensions in the Markdig assembly
    #>
    [CmdletBinding()]
    param(
        # The 'Name' of the Extension
        [Parameter(
        )]
        [ArgumentCompleter({MarkdigExtensionCompleter @args})]
        [string[]]$Name,

        # Filter the name
        [Parameter(
        )]
        [string]$Filter

    )
    begin {
        <#
        ------------------------------------------------------------------
          looking at
          https://github.com/xoofx/markdig/blob/master/src/Markdig/MarkdownExtensions.cs#L548
          The Configure function uses "hard coded" extension tags to call the
          "Use*" function for that extension.  What's worse is that the extension
          tags and the Use function name do not always match up.
        ? Best to also hard code them here?
        ------------------------------------------------------------------
        #>

        $extensionMap = @{
                 common = ''
                 advanced =  'UseAdvancedExtensions()'
                 pipetables= 'UsePipeTables()'
                 "gfm-pipetables"= 'UsePipeTables(new PipeTableOptions { UseHeaderForColumnCount = true })'
                 emphasisextras= 'UseEmphasisExtras()'
                 listextras= 'UseListExtras()'
                 hardlinebreak= 'UseSoftlineBreakAsHardlineBreak()'
                 footnotes= 'UseFootnotes()'
                 footers= 'UseFooters()'
                 citations= 'UseCitations()'
                 attributes= 'UseGenericAttributes()'
                 gridtables= 'UseGridTables()'
                 abbreviations= 'UseAbbreviations()'
                 emojis= 'UseEmojiAndSmiley()'
                 definitionlists= 'UseDefinitionLists()'
                 customcontainers= 'UseCustomContainers()'
                 figures= 'UseFigures()'
                 mathematics= 'UseMathematics()'
                 bootstrap= 'UseBootstrap()'
                 medialinks= 'UseMediaLinks()'
                 smartypants= 'UseSmartyPants()'
                 autoidentifiers= 'UseAutoIdentifiers()'
                 tasklists= 'UseTaskLists()'
                 diagrams= 'UseDiagrams()'
                 nofollowlinks= 'UseReferralLinks("nofollow")'
                 noopenerlinks= 'UseReferralLinks("noopener")'
                 noreferrerlinks= 'UseReferralLinks("noreferrer")'
                 nohtml= 'DisableHtml()'
                 yaml= 'UseYamlFrontMatter()'
                 "nonascii-noescape"= 'UseNonAsciiNoEscape()'
                 autolinks= 'UseAutoLinks()'
                 globalization= 'UseGlobalization()'
        }
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
    process {
        Write-Debug "`n$('-' * 80)`n-- Process start $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
        <#
        One way of getting the extension names
        --------------------------------------------------------------------------------
        $functionNames = [Markdig.MarkdownExtensions] | Get-Member -Static |
        Where-Object Name -Match '^Use\w+' | Select-Object -expand Name
        Write-Debug "Found $($functionNames.Count) Extension functions"
        if ($functionNames.Count -gt 0) {
            $functionNames -replace '^Use', '' | Write-Output
        }
        --------------------------------------------------------------------------------
        #>

        $extensionMap.Keys

        Write-Debug "`n$('-' * 80)`n-- Process end $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
