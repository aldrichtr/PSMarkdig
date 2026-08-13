
using namespace Markdig.Syntax
using namespace Markdig.Renderers.Html

function Get-MarkdigAttribute {
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
        [MarkdownObject]$Element
    )
    begin {}
    process {
        [HtmlAttributesExtensions]::GetAttributes($Element)
    }
    end {}
}