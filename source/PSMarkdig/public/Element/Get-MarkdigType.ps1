
using namespace Markdig
using namespace Markdig.Syntax

function Get-MarkdigType {
  <#
  .SYNOPSIS
    Retrieve the Markdown types available from Markdig
  #>
  [CmdletBinding()]
  param(
    # The name of the type to return
    [Parameter(
      Position = 0
    )]
    [string]$Name
  )
  begin {
    $self = $MyInvocation.MyCommand
    Write-Debug "`n$('-' * 80)`n-- Begin $($self.Name)`n$('-' * 80)"
  }
  process {
    [Markdown].Assembly.GetTypes()
    | Where-Object { $_.IsSubclassOf([MarkdownObject]) }
    | ForEach-Object {
      if ((-not ($PSBoundParameters.ContainsKey('Name'))) -or
          ($_.Name -like "*$Name*")) { $_ } }
    | Select-Object -Property @(
      'Name',
      'FullName',
      @{ Name = 'Type'; Expression = { $_.FullName }},
      'BaseType')

  }
  end {
    Write-Debug "`n$('-' * 80)`n-- End $($self.Name)`n$('-' * 80)"
  }
}
