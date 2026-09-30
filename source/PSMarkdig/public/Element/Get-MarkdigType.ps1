
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
  begin {}
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
  end {}
}
