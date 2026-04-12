

using namespace Markdig.Syntax
function Remove-LinesAfter {
    <#
    .SYNOPSIS
        Remove the given amount of lines from the given element that come after the content
    #>
    [CmdletBinding()]
    param(
        # The markdown object to remove the lines from
        [Parameter(
        )]
        [MarkdownObject]$Element,

        # Number of lines to remove
        [Parameter(
        )]
        [int]$Lines
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
    process {
        if ($null -ne $Element.LinesAfter) {
            if ($Element.LinesAfter.Count -le $Lines) {
                for ($i = 0; $i -lt $Lines; $i++) {
                    $success = $Element.LinesAfter.RemoveAt(0)
                    if ($success) {
                        Write-Verbose "Removed line $i after"
                    } else {
                        throw "Could not remove line $i"
                    }
                }
            }
        }
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
