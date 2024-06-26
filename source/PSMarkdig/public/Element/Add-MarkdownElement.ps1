
using namespace Markdig
using namespace Markdig.Syntax

function Add-MarkdownElement {
    <#
    .SYNOPSIS
        Add a markdig.Markdown object to the Markdown document at the given index
    .EXAMPLE
        $doc | Add-MarkdownElement $anotherHeading -After $firstHeading
    #>
    [CmdletBinding(
        DefaultParameterSetName = 'Index'
    )]
    param(
        # Markdown element(s) to add to the document
        [Parameter(
            Position = 0
        )]
        [MarkdownObject]$Element,

        # Index to insert the Elements to, append to end if not specified
        [Parameter(
            ParameterSetName = 'Index',
            Position = 1
        )]
        [int]$Index,

        # Add the element after this one
        [Parameter(
            ParameterSetName = 'After',
            Position = 1
        )]
        [MarkdownObject]$After,

        # Add the element Before this one
        [Parameter(
            ParameterSetName = 'Before',
            Position = 1
        )]
        [MarkdownObject]$Before,

        # The document to add the element to
        [Parameter(
            Position = 2,
            ValueFromPipeline
        )]
        [MarkdownObject]$Document,

        # Return the updated document to the pipeline
        [Parameter(
        )]
        [switch]$PassThru
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
    process {
        if ($PSBoundParameters.ContainsKey('Before')) {
            $Index = ($Document.IndexOf($Before) - 1)
        } elseif ($PSBoundParameters.ContainsKey('After')) {
            $Index = ($Document.IndexOf($After) + 1)
        }

        if (-not ([string]::IsNullOrEmpty($Index))) {
            Write-Debug "Inserting Element $($Element.GetType().FullName) at index $Index"
            try {
                $Document.Insert($Index, $Element)
            } catch {
                $PSCmdlet.ThrowTerminatingError($_)
            }

        } else {
            try {
                $Document.Add($Element)
            } catch {
                $PSCmdlet.ThrowTerminatingError($_)
            }
        }

        if ($PassThru) { Write-Output $Document -NoEnumerate }
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
