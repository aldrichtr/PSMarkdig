

using namespace Markdig.Syntax
using namespace Markdig.Extensions.Yaml
function ConvertFrom-MarkdigYamlFrontMatterBlock {
    <#
    .SYNOPSIS
        Convert a front matter block into an object
    #>
    [CmdletBinding()]
    param(
        # The YamlFrontMatterBlock
        [Parameter(
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [YamlFrontMatterBlock]$Block
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
    process {
        if ($null -ne $Block.Lines) {
            try {
                $Block.Lines.ToString() | ConvertFrom-Yaml
            } catch {
                $PSCmdlet.ThrowTerminatingError($_)
            }
        }
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
