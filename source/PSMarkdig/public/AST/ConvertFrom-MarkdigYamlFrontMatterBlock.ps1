
using namespace Markdig.Syntax
using namespace Markdig.Extensions.Yaml

function ConvertFrom-MarkdigYamlFrontMatterBlock {
    <#
    .SYNOPSIS
        Convert a Markdig::YamlFrontMatterBlock into a powershell object
    #>
    [CmdletBinding()]
    param(
        # The YAML front matter block object
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
                #TODO: Add the parameters for convertfrom-yaml to this function to control output
                $data = $Block.Lines.ToString() | ConvertFrom-Yaml
            }
            catch {
                $message = "There was a problem converting the yaml content"
                $exceptionText = ( @($message, $_.ToString()) -join "`n")
                $thisException = [Exception]::new($exceptionText)
                $eRecord = New-Object System.Management.Automation.ErrorRecord -ArgumentList (
                    $thisException,
                    $null,  # errorId
                    $_.CategoryInfo.Category, # errorCategory
                    $null  # targetObject
                )
                $PSCmdlet.ThrowTerminatingError( $eRecord )
            }
            $blockInfo = @{
                PSTypeName = 'PSMarkdig.YamlFrontMatter'
                Data = $data
                Span = $Block.Span
            }
            [PSCustomObject]$blockInfo
        }
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
