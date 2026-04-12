
using namespace Markdig.Syntax
using namespace Markdig.Extensions
function Set-MarkdownHeading {
    <#
    .SYNOPSIS
        Set or change the given markdown heading
    #>
    [CmdletBinding()]
    param(
        # The heading to modify
        [Parameter(
            Mandatory,
            Position = 1,
            ValueFromPipeline
        )]
        [HeadingBlock]$Heading,

        # The new title to set this heading to
        [Parameter(
        )]
        [string]$NewTitle,

        # The new level to set this heading to
        [Parameter(
        )]
        [int]$NewLevel
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
    process {
        if ($PSBoundParameters.ContainsKey('NewTitle')) {
            $Heading.Inline.FirstChild.Content = $NewTitle
        }

        if ($PSBoundParameters.ContainsKey('NewLevel')) {
            $Heading.Level = $NewLevel
        }
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
