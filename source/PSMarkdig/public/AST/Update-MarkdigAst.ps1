
using namespace Markdig

function Update-MarkdigAst {
    <#
    .SYNOPSIS
        Rebuild the AST from the content of the modified document
    .EXAMPLE
        $doc = Update-MarkdigAst $doc
        #>
    [CmdletBinding()]
    param(
        # The Markdig object to update
        [Parameter(
        )]
        [MarkdownObject]$InputObject
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
    process {

        $InputObject | Write-MarkdownElement | ConvertTo-MarkdigObject
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
