
using namespace System.Management.Automation
using namespace Markdig.Syntax

function Select-YamlFrontMatter {
  <#
  .SYNOPSIS
    Return an object representing the Yaml Frontmatter of the given markdown document
  .DESCRIPTION
    Accepts a [MarkdigDocument] wrapper or raw [MarkdownDocument] and extracts the
    YAML front matter block, converting it to a PowerShell object.
  #>
  [CmdletBinding()]
  param(
    # The MarkdigDocument wrapper or raw MarkdownDocument
    [Parameter(
      Mandatory,
      Position = 0,
      ValueFromPipeline
    )]
    [object]$Element
  )
  begin {
    $self = $MyInvocation.MyCommand
    Write-Debug "`n$('-' * 80)`n-- Begin $($self.Name)`n$('-' * 80)"
  }
  process {
    # Unwrap if we received a MarkdigDocument wrapper
    if ($Element -is [MarkdigDocument]) {
      $mdDoc = $Element.Ast
    } elseif ($Element -is [MarkdownDocument]) {
      $mdDoc = $Element
    } else {
      throw "Element must be a [MarkdigDocument] or [Markdig.Syntax.MarkdownDocument]. Got: $($Element.GetType().FullName)"
    }

    $options = @{
      Element = $mdDoc
      Type    = 'Markdig.Extensions.Yaml.YamlFrontMatterBlock'
    }
    try {
      $block = Select-MarkdigDescendant @options
    } catch {
      $err = $_ # The original error
      $message = "There was an error finding the front matter.`n$($_.ErrorDetails)"
      $exceptionText = ( @($message, $err.ErrorDetails) -join "`n")
      $newException = [Exception]::new($exceptionText)
      $eRecord = [ErrorRecord]::new(
        $newException,
        $err.FullyQualifiedErrorId,
        $err.CategoryInfo.Category,
        $Element
      )
      $PSCmdlet.ThrowTerminatingError( $eRecord )
    }

    if ($null -ne $block) {
      $block | ConvertFrom-MarkdigYamlFrontMatterBlock
    } else {
      $null
    }
  }
  end {
    Write-Debug "`n$('-' * 80)`n-- End $($self.Name)`n$('-' * 80)"
  }
}