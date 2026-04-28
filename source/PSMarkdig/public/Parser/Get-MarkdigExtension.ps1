
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
    [string]$Name
  )
  begin {
    <# -------------------------------------------------------------------------
      looking at
      https://github.com/xoofx/markdig/blob/master/src/Markdig/MarkdownExtensions.cs#L548
      The Configure function uses "hard coded" extension tags to call the "Use*"
      function for that extension.  What's worse is that the extension tags and
      the Use function name do not always match up.
    ------------------------------------------------------------------------- #>
    $self = $MyInvocation.MyCommand
    Write-Debug "`n$('-' * 80)`n-- Begin $($self.Name)`n$('-' * 80)"
  }
  process {
    $extensions = [Markdig.MarkdownExtensions]
    | Get-Member -Static
    | Where-Object Name -Match '^Use(\w+)'
    | ForEach-Object {
      [PSCustomObject]@{
        Name      = $Matches.1
        Extension = $_
      }
    }

    foreach ($ext in $extensions) {
      if ((-not ($PSBoundParameters.ContainsKey('Name'))) -or
        ($ext.Name -like "*$Name*")) {
        $ext
      }
    }
  }
  end {
    Write-Debug "`n$('-' * 80)`n-- End $($self.Name)`n$('-' * 80)"
  }
}
