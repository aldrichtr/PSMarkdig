
using namespace Markdig.Syntax

function ConvertFrom-Markdig {
    <#
    .SYNOPSIS
        Convert the Markdig AST to PowerShell Objects
    #>
    [CmdletBinding()]
    param(
        # The MarkdigObject to convert
        [Parameter(
            ValueFromPipeline
        )]
        [MarkdownObject]$InputObject
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
    process {

        $objectType = ($InputObject.GetType().Name)
        $cmd        = Get-Command "ConvertFrom-Markdig$objectType" -ErrorAction SilentlyContinue

        if ($null -ne $cmd) {
            $astObject = (& $cmd $InputObject)

        } else {
            throw "No parser found for Markdig.Syntax.$objectType"
        }

    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
