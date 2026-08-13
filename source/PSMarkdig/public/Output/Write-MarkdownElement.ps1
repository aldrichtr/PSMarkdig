
using namespace System
using namespace System.IO
using namespace Markdig
using namespace Markdig.Syntax
using namespace Markdig.Renderers.Roundtrip
using namespace Microsoft.PowerShell.MarkdownRender

function Write-MarkdownElement {
  <#
  .SYNOPSIS
    Render a Markdown element back to text using the roundtrip renderer or VT100.
  .DESCRIPTION
    Accepts a [MarkdigDocument] wrapper, a raw [MarkdownObject], or individual AST elements
    and renders them back to markdown text. When a [MarkdigDocument] is provided, the pipeline
    that produced it is available for renderer configuration.
  #>
  [CmdletBinding()]
  [Alias('ConvertFrom-MarkdigObject')]
  param(
    [Parameter(
      ValueFromPipeline
    )]
    [object]$Element,

    # Use VT100Encoded strings (console display)
    [Parameter(
    )]
    [switch]$AsVT100Encoded,

    # Output Link References at the end of the document
    [Parameter(
    )]
    [switch]$RenderLinkReferences
  )
  begin {
    Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
  }
  process {
    # Unwrap if we received a MarkdigDocument wrapper
    if ($Element -is [MarkdigDocument]) {
      $mdObject = $Element.Ast
    } elseif ($Element -is [MarkdownObject]) {
      $mdObject = $Element
    } else {
      throw "Element must be a [MarkdigDocument] or [Markdig.Syntax.MarkdownObject]. Got: $($Element.GetType().FullName)"
    }

    $sw = [StringWriter]::new()

    if ($AsVT100Encoded) {
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
    if (-not($RenderLinkReferences)) {
      $lrdr = $rr.ObjectRenderers | Where-Object {
        $_.GetType().Name -like 'LinkReferenceDefinitionRenderer'
      }

      if ($null -ne $lrdr) {
        [void]$rr.ObjectRenderers.Remove($lrdr)
      }
    }
    $rr.Write($mdObject)
    $sw.ToString() | Write-Output
  }
  end {
    Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
  }
}