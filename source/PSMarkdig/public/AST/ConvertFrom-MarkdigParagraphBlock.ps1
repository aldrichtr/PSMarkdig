
using namespace System.Text
using namespace Markdig.Syntax
using namespace Markdig.Helpers
using namespace Markdig.Syntax.Inlines

function ConvertFrom-MarkdigParagraphBlock {
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
        [ParagraphBlock]$Block
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
        $content = [StringBuilder]::new()
    }
    process {
        if ($null -ne $Block.Lines) {
            try {
                $child = $Block.Inline.FirstChild
                while ($null -ne $child) {
                    if ($child -is [LineBreakInline]) {
                         [void]$content.Append(
                            [NewLineExtensions]::AsString($child.NewLine)
                         )
                    } else {
                        [void]$content.Append($child.ToString())
                    }

                    $child = $child.NextSibling
                }
            }
            catch {
                $message = "There was a problem converting the content"
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
                PSTypeName = 'PSMarkdig.Paragraph'
                Text = $content.ToString()
                Span = $Block.Span
            }
            [PSCustomObject]$blockInfo
        }
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
