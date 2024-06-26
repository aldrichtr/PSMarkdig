
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
        )]
        [MarkdownObject]$Element,

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
        $type = $Element.GetType().FullName
        "$(' ' * $indent)[$index] - $type"
        $index++
        $count = (Write-Output $Element -NoEnumerate | Select-Object -ExpandProperty Count)
        Write-Debug "$type : has $count elements"
        for ($i=0;$i -ge $count;$i++) {
            "$(' ' * $indent)[$i] - $type"

            $Element | ForEach-Object {
                $indent++
                $index++
                Show-MarkdigAst $_ -index $index -indent $indent
            }
        }
}
end {
    Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
}
}
