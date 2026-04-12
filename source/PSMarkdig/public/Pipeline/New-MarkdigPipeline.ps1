
function New-MarkdigPipeline {
  <#
  .SYNOPSIS
    Create a parser pipeline for Markdig
  #>
  [CmdletBinding()]
  param(
  )
  begin {
    $self = $MyInvocation.MyCommand
    Write-Debug "`n$('-' * 80)`n-- Begin $($self.Name)`n$('-' * 80)"
  }
  process {

    throw "TODO"

  }
  end {
    Write-Debug "`n$('-' * 80)`n-- End $($self.Name)`n$('-' * 80)"
  }
}
