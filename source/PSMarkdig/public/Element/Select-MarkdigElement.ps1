
using namespace Markdig
using namespace Markdig.Extensions
using namespace Markdig.Syntax

function Select-MarkdigDescendant {
  <#
  .SYNOPSIS
    Enumerate children of the markdown element
  .LINK
    <https://github.com/xoofx/markdig/blob/main/src/Markdig/Syntax/MarkdownObjectExtensions.cs>
  #>
  [CmdletBinding()]
  [Alias('Select-MarkdigElement')]
  param(
    [Parameter(
      Mandatory,
      Position = 0
    )]
    [MarkdownObject]$Element,

    # The **fully-qualified** type name of element to return
    [Parameter(
      ValueFromPipelineByPropertyName
    )]
    [string]$Type
  )
  begin {
    Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    $objExtensions = [MarkdownObjectExtensions]
    $descendants = $objExtensions.GetMethod('Descendants', 1, [MarkdownObject])
  }
  process {
    if ([string]::IsNullOrEmpty($PSBoundParameters['Type'])) {
      Write-Debug 'No Type given.  Return all elements'
      # Use the static method
      # public static IEnumerable<MarkdownObject> Descendants(this MarkdownObject markdownObject)
      [MarkdownObjectExtensions]::Descendants($Element)
    } else {
      Write-Debug "Checking if Type '$Type' is valid"
      # Use the template method
      #public static IEnumerable<T> Descendants<T>(this MarkdownObject markdownObject)
      if ($Type -notmatch '^Markdig') { throw 'Type must be a member of Markdig' }

      # Try to cast to the given type
      $objectType = $Type -as [Type]
      if ($null -eq $objectType) { throw "'$Type' is not a valid type." }
      Write-Debug "- Type is valid.  Getting Elements"

      # Create the template method so we can use it on our element
      $method = $descendants.MakeGenericMethod($objectType)
      $method.Invoke($objExtensions, @(,$Element))
      # $method.Invoke([MarkdownObjectExtensions], (Write-Output $Element -NoEnumerate))
    }

  }
  end {
    Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
  }
}
