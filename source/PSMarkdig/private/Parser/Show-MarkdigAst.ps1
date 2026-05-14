

using namespace Markdig.Syntax

function Show-MarkdigAst {
  <#
    .SYNOPSIS
      Show a text representation of the Abstract Syntax Tree of this Markdig Object
    .NOTES
      I hacked this function together to use during testing and "exploration".  I do not consider it
      production quality, but it does show the hierarchy.
  #>
  [OutputType('System.String')]
  [CmdletBinding()]
  param(
    # The markdig object to show
    [Parameter(
      ValueFromPipeline
    )]
    [MarkdownObject]$Element,

    # Show full name of object
    [Parameter(
    )]
    [switch]$FullName,

    [Parameter(
      DontShow
    )]
    [int]$Index = 0,

    [Parameter(
      DontShow
    )]
    [int]$Last = 0,

    [Parameter(
      DontShow
    )]
    [int]$Open = 0,

    [Parameter(
      DontShow
    )]
    [int]$Level = 0
  )

  #region Style Elements -----------------------------------------------------------------------------------
  $style = @{
    Index = $PSStyle.Foreground.Blue
    Bracket = $PSStyle.Foreground.BrightBlack
    Name  = $PSStyle.Foreground.Cyan
    Reset = $PSStyle.Reset
  }

  $mark = @{
    open     = '   '
    Continue = '│  '
    Child    = '├──'
    Last     = '└──'
  }
  #endregion -----------------------------------------------------------------------------------------------

  if ($FullName) {
    $type = $Element.GetType().FullName
  } else {
    $type = $Element.GetType().Name
  }

  if ($Index -eq $Last) {
    $pointer = $mark.Last
  } else {
    $pointer = $mark.Child
  }

  switch ($Level) {
    0 {
      $pointer = ''
      $indent = ''
    }
    1 {
      $Open = 0
      $indent = ''
    }
    default {
      $indent  = "$($mark.Continue * (($Level - 1) - $Open))$($mark.Open * $Open)"
      if ($Index -eq $Last) { $Open++}
    }
  }

  # --------------------------------------------------------------------------------------------------------
  # Display the node
  (@(
    $indent,
    $pointer,
    " "
    $style.Name, $type, $style.Reset,
    $style.Bracket, '[' , $style.Reset,
    "$($style.Index)$index$($style.Reset)"
    $style.Bracket, ']' , $style.Reset
  ) -join '')
  # --------------------------------------------------------------------------------------------------------

  $index++
  $count = Write-Output $Element -NoEnumerate | Select-Object -ExpandProperty Count
  $Last = ($count - 1)
  Write-Debug "$type : has $count elements"
  $thisLevel = $Level
  $thisIndex  = $index
  $thisOpen  = $Open
  # If there is more than one Child, Recurse into them
  if ($count -gt 1) {
    $Level++
    for ($i = 0; $i -lt $count; $i++) {
      $options = @{
        Element  = $Element[$i]
        FullName = $FullName
        Index    = $i
        Open     = $Open
        Level    = $Level
        Last     = $Last
      }
      Show-MarkdigAst @options
    }
  }
  $Level = $thisLevel
  $Index  = $thisIndex
  $Open = $thisOpen
}
