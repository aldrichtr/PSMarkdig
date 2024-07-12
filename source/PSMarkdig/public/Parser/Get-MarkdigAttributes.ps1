
using namespace Markdig.Syntax
using namespace Markdig.Renderers.Html

function Get-MarkdigAttributes {
    <#
    .SYNOPSIS
        Return the HTML attributes associated with the given Markdig Object
    #>
    [CmdletBinding()]
    param(
        # The Markdig Object to get the attributes from
        [Parameter(
            ValueFromPipeline
        )]
        [MarkdownObject]$InputObject
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
    process {
        [HtmlAttributesExtensions]::GetAttributes($InputObject)
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
