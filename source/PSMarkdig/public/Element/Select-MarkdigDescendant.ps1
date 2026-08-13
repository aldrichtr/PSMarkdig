
using namespace Markdig
using namespace Markdig.Extensions
using namespace Markdig.Syntax

function Select-MarkdigDescendant {
  <#
  .SYNOPSIS
    Enumerate children of the markdown element
  .DESCRIPTION
    Walks the AST of a MarkdownDocument and returns descendant elements, optionally
    filtered by type. Accepts either a [MarkdigDocument] wrapper or a raw [MarkdownObject].
  .LINK
    <https://github.com/xoofx/markdig/blob/main/src/Markdig/Syntax/MarkdownObjectExtensions.cs>
  #>
  [CmdletBinding()]
  [Alias('Select-MarkdigElement')]
  param(
    [Parameter(
      Mandatory,
      Position = 0,
      ValueFromPipeline
    )]
    [object]$Element,

    # The **fully-qualified** type name of element to return
    [Parameter(
      ValueFromPipelineByPropertyName
    )]
    [ArgumentCompleter({ MarkdigTypeCompleter @args })]
    [string]$Type
  )
  begin {
    Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    $objExtensions = [MarkdownObjectExtensions]
    $descendants = $objExtensions.GetMethod('Descendants', 1, [MarkdownObject])
  }
  process {
    # Unwrap if we received a MarkdigDocument wrapper
    if ($Element -is [MarkdigDocument]) {
      $mdObject = $Element.Ast
    } elseif ($Element -is [MarkdownObject]) {
      $mdObject = $Element
    } else {
      throw "Element must be a [MarkdigDocument] or [Markdig.Syntax.MarkdownObject]. Got: $($Element.GetType().FullName)"
    }

    if ([string]::IsNullOrEmpty($PSBoundParameters['Type'])) {
      Write-Debug 'No Type given.  Return all elements'
      # Use the static method
      # public static IEnumerable<MarkdownObject> Descendants(this MarkdownObject markdownObject)
      [MarkdownObjectExtensions]::Descendants($mdObject)
    } else {
      Write-Debug "Checking if Type '$Type' is valid"
      # Use the template method
      #public static IEnumerable<T> Descendants<T>(this MarkdownObject markdownObject)
      if ($Type -notmatch '^Markdig') {
        Write-Debug "Type is not fully qualified to Markdig"
        Write-Debug "Looking up $Type"
        $possibleType = Get-MarkdigType
        | Where-Object Name -Like $Type
        | Select-Object -ExpandProperty FullName
        if ($null -ne $possibleType) {
          Write-Debug "- Found. Expanding to $possibleType"
          $Type = $possibleType
        } else {
          throw 'Type must be a member of Markdig'
        }
      }

      # Try to cast to the given type
      $objectType = $Type -as [Type]
      if ($null -eq $objectType) { throw "'$Type' is not a valid type." }
      Write-Debug '- Type is valid.  Getting Elements'

      # Create the template method so we can use it on our element
      $method = $descendants.MakeGenericMethod($objectType)
      $method.Invoke($objExtensions, @(, $mdObject))
    }
  }
  end {
    Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
  }
}