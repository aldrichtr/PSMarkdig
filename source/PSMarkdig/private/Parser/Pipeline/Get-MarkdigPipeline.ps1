
function Get-MarkdigPipeline {
  <#
  .SYNOPSIS
    Retrieve the pipeline from a MarkdigDocument wrapper
  .DESCRIPTION
    Returns the MarkdownPipeline associated with a parsed document.
    This is a convenience accessor - equivalent to $doc.Pipeline.
  #>
  [CmdletBinding()]
  param(
    # The MarkdigDocument to get the pipeline from
    [Parameter(
      ValueFromPipeline
    )]
    [MarkdigDocument]$Document
  )
  begin {
    $self = $MyInvocation.MyCommand
    Write-Debug "`n$('-' * 80)`n-- Begin $($self.Name)`n$('-' * 80)"
  }
  process {
    if ($null -ne $Document) {
      $Document.Pipeline
    } else {
      throw 'No MarkdigDocument was given'
    }
  }
  end {
    Write-Debug "`n$('-' * 80)`n-- End $($self.Name)`n$('-' * 80)"
  }
}