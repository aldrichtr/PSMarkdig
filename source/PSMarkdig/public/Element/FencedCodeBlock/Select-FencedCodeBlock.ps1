
using namespace Markdig.Syntax

function Select-FencedCodeBlock {
  <#
  .SYNOPSIS
    Select the `Markdig.Syntax.FencedCodeBlock`s from the given object
  .DESCRIPTION
    Accepts a [MarkdigDocument] wrapper or raw [MarkdownDocument] and returns
    all fenced code blocks, with optional selection parameters.
  #>
  [CmdletBinding()]
  param(
    # The MarkdigDocument wrapper or raw MarkdownDocument
    [Parameter(
      Mandatory,
      Position = 0,
      ValueFromPipeline
    )]
    [object]$Element,

    # The number of objects to select from the beginning of the collection of codeblocks
    [Parameter(
    )]
    [Int32]$First,

    # The number of objects to select from the end of the collection of codeblocks
    [Parameter(
    )]
    [Int32]$Last,

    # The number of objects to skip from the beginning of the selection
    [Parameter(
    )]
    [Int32]$Skip,

    # The number of objects to skip from the end of the selection
    [Parameter(
    )]
    [Int32]$SkipLast,

    # Select codeblocks from the collection by their indexes
    [Parameter(
    )]
    [Int32[]]$Index,

    # Skip codeblocks from the collection by their indexes
    [Parameter(
    )]
    [Int32[]]$SkipIndex
  )
  begin {
    $self = $MyInvocation.MyCommand
    Write-Debug "`n$('-' * 80)`n-- Begin $($self.Name)`n$('-' * 80)"
  }
  process {
    # Unwrap if we received a MarkdigDocument wrapper
    if ($Element -is [MarkdigDocument]) {
      $mdDoc = $Element.Ast
    } elseif ($Element -is [MarkdownDocument]) {
      $mdDoc = $Element
    } else {
      throw "Element must be a [MarkdigDocument] or [Markdig.Syntax.MarkdownDocument]. Got: $($Element.GetType().FullName)"
    }

    $options = @{
      Element = $mdDoc
      Type    = 'Markdig.Syntax.FencedCodeBlock'
    }
    try {
      if ($PSBoundParameters.Keys.Count -gt 1) {
        $selectOptions = @{}
        foreach ($key in $PSBoundParameters.Keys) {
          if ($key -ne 'Element') {
            $selectOptions[$key] = $PSBoundParameters[$key]
          }
        }
        Select-MarkdigDescendant @options | Select-Object @selectOptions
      } else {
        Select-MarkdigDescendant @options
      }
    } catch {
      $err = $_ # The original error
      $message = "There was an error finding the code blocks.`n$($_.ErrorDetails)"
      $exceptionText = ( @($message, $err.ErrorDetails) -join "`n")
      $newException = [Exception]::new($exceptionText)
      $eRecord = [ErrorRecord]::new(
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