
using namespace System.IO
using namespace Markdig

function New-MarkdigPipelineBuilder {
  <#
  .SYNOPSIS
    Create a new pipeline builder
  #>
  [CmdletBinding()]
  param(
    # Use precise source location (slower but more accurate parsing)
    [Parameter()]
    [switch]$PreciseSourceLocation,


    # Parse and track trivia such as whitespace, extra heading characters, and unescaped string values
    [Parameter()]
    [switch]$TrackTrivia
  )

  $builder = [MarkdownPipelineBuilder]::new()
  $builder.TrackTrivia = [bool]$TrackTrivia
  $builder.PreciseSourceLocation = [bool]$PreciseSourceLocation

  return $builder
}
