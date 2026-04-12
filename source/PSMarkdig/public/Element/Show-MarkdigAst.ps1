
using namespace Markdig.Syntax

function Show-MarkdigAst {
    <#
    .SYNOPSIS
        Show a text representation of the Abstract Syntax Tree of this Markdig Object
    #>
    [OutputType('System.String')]
    [CmdletBinding()]
    param(
        # The markdig object to show
        [Parameter(
            ValueFromPipeline
        )]
        [MarkdownObject]$Element,

        # Show full name of object
        [Parameter(
        )]
        [switch]$FullName,

        [Parameter(
            DontShow
        )]
        [int]$index = 0,

        [Parameter(
            DontShow
        )]
        [int]$indent = 0
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
    process {
        Write-Debug "Index is $index, Indent is $indent"
        if ($FullName) {
            $type = $Element.GetType().FullName
        } else {
            $type = $Element.GetType().Name
        }
        "$(' ' * $indent)[$index] - $type"
        $index++
        $count = Write-Output $Element -NoEnumerate | Select-Object -ExpandProperty Count
        Write-Debug "$type : has $count elements"
        $currentIndent = $indent
        $currentIndex  = $index
        if ($count -gt 1) {
            $indent++
            for ($i = 0; $i -lt $count; $i++) {
                Show-MarkdigAst $Element[$i] -FullName:$FullName -index $i -indent $indent
            }
        }
        $indent = $currentIndent
        $index  = $currentIndex
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
