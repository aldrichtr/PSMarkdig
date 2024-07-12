
using namespace System
using namespace System.IO
using namespace Markdig
using namespace Markdig.Syntax
using namespace Markdig.Renderers.Roundtrip
using namespace Microsoft.PowerShell.MarkdownRender

function Write-MarkdownElement {
    [CmdletBinding()]
    [Alias('ConvertFrom-MarkdigObject')]
    param(
        [Parameter(
            ValueFromPipeline
        )]
        [MarkdownObject]$Element,

        # Use VT100Encoded strings
        [Parameter(
        )]
        [switch]$AsVT100Encodeded,

        # Output Link References at the end of the document
        [Parameter(
        )]
        [switch]$RenderLinkReferences

    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
    process {
        $sw = [StringWriter]::new()

        if ($AsVT100Encodeded) {
            $options = (Get-MarkdownOption)
            $rr = [VT100Renderer]::new($sw, $options)
        } else {
            $rr = [RoundtripRenderer]::new($sw)
        }

        # There is a bug in the YAML renderer... see
        # <https://github.com/xoofx/markdig/issues/579>
        #! The Yaml renderer needs to be before the Codeblock renderer
        [void]$rr.ObjectRenderers.Insert(0, [Extensions.Yaml.YamlFrontMatterRoundtripRenderer]::new())

        # The LinkReferenceDefinitionRenderer puts these []: at the bottom
        # I tried using the UseReferralLinks('nofollow') UseReferralLinks('noopener') and
        # UseReferralLinks('noreferrer'), but that didn't stop them from being rendered
        if (-not($RenderLinkReferences)) {
            $lrdr = $rr.ObjectRenderers | Where-Object {
                $_.GetType().Name -like 'LinkReferenceDefinitionRenderer'
            }

            if ($null -ne $lrdr) {
                [void]$rr.ObjectRenderers.Remove($lrdr)
            }
        }
        $rr.Write($Element)
        $sw.ToString() | Write-Output
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
