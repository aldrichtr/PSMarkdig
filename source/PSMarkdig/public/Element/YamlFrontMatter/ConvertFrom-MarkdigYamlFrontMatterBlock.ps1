

using namespace Markdig.Syntax
using namespace Markdig.Extensions.Yaml

function ConvertFrom-MarkdigYamlFrontMatterBlock {
  <#
    .SYNOPSIS
        Convert a front matter block into an object
    #>
  [CmdletBinding()]
  param(
    # The YamlFrontMatterBlock
    [Parameter(
      ValueFromPipeline,
      ValueFromPipelineByPropertyName
    )]
    [YamlFrontMatterBlock]$Block,

    # Optionally return a hashtable instead of an object
    [Parameter(
    )]
    [switch]$AsHashtable,

    # Options to be passed to the Yaml parser:
    # AllDocuments = $true|$false
    # MergingParser = $true|$false
    # Ordered = $true|$false
    [Parameter()]
    [hashtable]$Options
  )
  begin {
    Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
  }
  process {
    if ($null -ne $Block.Lines) {
      try {
        if ($PSBoundParameters.ContainsKey('Options')) {
          $fm = $Block.Lines.ToString() | ConvertFrom-Yaml @Options
        } else {
          $fm = $Block.Lines.ToString() | ConvertFrom-Yaml
        }
      } catch {
        $err = $_ # The original error
        $message = 'There was an error parsing the yaml content'
        $exceptionText = ( @($message, $err.ErrorDetails) -join "`n")
        $newException = [Exception]::new($exceptionText)
        $eRecord = [System.Management.Automation.ErrorRecord]::new(
          $newException,
          $err.FullyQualifiedErrorId,
          $err.CategoryInfo.Category,
          $TargetObject
        )
        $PSCmdlet.ThrowTerminatingError( $eRecord )
      }

      if ($null -ne $fm) {
        if ($AsHashtable) {
          $fm
        } else {
          $fm['PSTypeName'] = 'PSMarkdig.YamlFrontMatter'
          [PSCustomObject]$fm
        }
      }
    }
  }
  end {
    Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
  }
}