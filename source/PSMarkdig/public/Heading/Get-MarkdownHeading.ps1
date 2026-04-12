
using namespace Markdig.Syntax
function Get-MarkdownHeading {
    [CmdletBinding()]
    param(
        [Parameter(
            ValueFromPipeline
        )]
        [MarkdownObject]$Element
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
    process {
        Get-MarkdownDescendant 'Markdig.Syntax.HeadingBlock' -Element $Element
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }

}
