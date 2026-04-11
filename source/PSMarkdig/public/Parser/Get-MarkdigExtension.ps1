
using namespace Markdig
using namespace Markdig.Extensions

function Get-MarkdigExtension {
  <#
    .SYNOPSIS
        List Extensions in the Markdig assembly
    #>
  [CmdletBinding()]
  param(
    # The 'Name' of the Extension
    [Parameter(
    )]
    [ArgumentCompleter({ MarkdigExtensionCompleter @args })]
    [string[]]$Name,

    # Filter the name
    [Parameter(
    )]
    [string]$Filter

  )
  begin {
    <#
        ------------------------------------------------------------------
          looking at
          https://github.com/xoofx/markdig/blob/master/src/Markdig/MarkdownExtensions.cs#L548
          The Configure function uses "hard coded" extension tags to call the
          "Use*" function for that extension.  What's worse is that the extension
          tags and the Use function name do not always match up.
        ? Best to also hard code them here?
        ------------------------------------------------------------------
        #>
    Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
  }
  process {
    Write-Debug "`n$('-' * 80)`n-- Process start $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    [Markdig.MarkdownExtensions]
    | Get-Member -Static
    | Where-Object Name -Match '^Use(\w+)'
    | Foreach-Object {
        [PSCustomObject]@{
          Name = $Matches.1
          Extension = $_
        }
      }
    Write-Debug "`n$('-' * 80)`n-- Process end $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
  }
  end {
    Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
  }
}
