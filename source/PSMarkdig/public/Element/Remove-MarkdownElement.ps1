
using namespace Markdig.Syntax

function Remove-MarkdownElement {
  <#
  .SYNOPSIS
    Remove the given Element from the Markdig Object
  #>
  [CmdletBinding()]
  param(
    # The Element to remove it from
    [Parameter(
      ValueFromPipeline
    )]
    [MarkdownObject]$Element
  )
  begin {
    $self = $MyInvocation.MyCommand
    Write-Debug "`n$('-' * 80)`n-- Begin $($self.Name)`n$('-' * 80)"
  }
  process {
    try {
      $Element.Parent.Remove($Element)
    }
    catch {
      $err = $_ # The original error
      $message = "Could not remove element"
      $exceptionText = ( @($message, $err.ToString()) -join "`n")
      $newException = [Exception]::new($exceptionText)
      $eRecord = [System.Management.Automation.ErrorRecord]::new(
        $newException,
        $err.FullyQualifiedErrorId,
        $err.CategoryInfo.Category,
        $Element
      )
      $PSCmdlet.ThrowTerminatingError( $eRecord )
    }
  }
  end {
    Write-Debug "`n$('-' * 80)`n-- End $($self.Name)`n$('-' * 80)"
  }
}
