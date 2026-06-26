
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
    $config = Import-Configuration
    $shortCodes = $config.Extensions
  }
  process {
    [Markdig.MarkdownExtensions]
    | Get-Member -Static
    | Where-Object Name -Match '^Use(\w+)'
    | ForEach-Object {
      $shortName = $Matches.1
      if ((-not ($PSBoundParameters.ContainsKey('Name'))) -or
        ($shortName -like "*$Name*")) {
        [PSCustomObject]@{
          PSTypeName = 'PSMarkdig.MarkdownExtensionInfo'
          Name       = $shortName
          FullName   = $_.Name
          ShortCode  = $shortCodes[$Matches.1] ?? ''
          Extension  = $_
        }
      }
    }
  }
  end {
    Write-Debug "`n$('-' * 80)`n-- End $($self.Name)`n$('-' * 80)"
  }
}