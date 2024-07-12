
using namespace Markdig.Syntax

function ConvertFrom-MarkdigHeadingBlock {
    <#
    .SYNOPSIS
        Convert the Markdig HeadingBlock object into a PowerShell Object
    #>
    [CmdletBinding()]
    param(
        # The heading block object
        [Parameter(
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [HeadingBlock]$Block
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
    process {
        $heading = @{
            PSTypeName = 'PSMarkdig.Heading'
            Level      = $Block.Level
            Arguments  = $Block.Arguments
            Attributes = $Block | Get-MarkdigAttributes
            Title      = $Block.Inline.Content.ToString()
        }

        [PSCustomObject]$heading
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
