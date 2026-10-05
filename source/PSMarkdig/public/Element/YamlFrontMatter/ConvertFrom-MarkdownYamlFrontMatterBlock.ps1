

using namespace System.Management.Automation
using namespace Markdig.Extensions.Yaml
using namespace Markdig.Syntax

function ConvertFrom-MarkdownYamlFrontMatterBlock {
  <#
  .SYNOPSIS
    Convert a front matter block into an object
  .EXAMPLE
    PS> $fm = cat file.md | Import-Markdown | ConvertFrom-MarkdownYamlFrontMatterBlock
  #>
  [CmdletBinding( DefaultParameterSetName = 'AsDocument')]
  param(
    # The Document to get the frontmatter from
    [Parameter(
      ParameterSetName = 'AsDocument',
      ValueFromPipeline,
      ValueFromPipelineByPropertyName
    )]
    [MarkdigDocument]$Document,

    # The Markdig YamlFrontMatterBlock object
    [Parameter(
      ParameterSetName = 'AsBlock',
      ValueFromPipeline
    )]
    [YamlFrontMatterBlock]$Block,

    # Optionally return a hashtable instead of an object
    [Parameter(
    )]
    [switch]$AsHashtable,

    # Optionally return an Ordered Dictionary instead of an object
    [Parameter(
    )]
    [switch]$Ordered,

    # Options to be passed to the Yaml parser:
    # - **AllDocuments**:  `$true`|`$false`
    # - **MergingParser**: `$true`|`$false`
    # - **Ordered**:       `$true`|`$false`
    [Parameter()]
    [hashtable]$Options
  )
  begin {
    Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
  }
  process {
    if ($PSCmdlet.ParameterSetName -eq 'AsDocument') {
      try {
        $fm = $Document | Select-MarkdownYamlFrontMatterBlock
      } catch {
        $PSCmdlet.ThrowTerminatingError($PSItem)
      }
      if ($null -eq $fm) {
        $PSCmdlet.ThrowTerminatingError(
          [ErrorRecord]::new(
            [System.NullReferenceException]::new(
              'No YAML Frontmatter found in document'
            ),
            'PSMarkdig.Parser.YamlFrontmatterBlockNotFound',
            [ErrorCategory]::ObjectNotFound,
            $Document
          ))
      }
      $Block = $fm
    }

    if ($null -eq $Block) {
      $PSCmdlet.ThrowTerminatingError(
        [ErrorRecord]::new(
          [System.NullReferenceException]::new(
            'No YAML Frontmatter was found'
          ),
          'PSMarkdig.Parser.YamlFrontmatterBlockNotFound',
          [ErrorCategory]::ObjectNotFound,
          $Document
        ))
    }
    # --------------------------------------------------------------------------------
    # Now we can be reasonably sure that we have some frontmatter to convert
    try {
      if ($PSBoundParameters.ContainsKey('Options')) {
        $fm = $Block.Lines.ToString() | ConvertFrom-Yaml @Options
      } else {
        $fm = $Block.Lines.ToString() | ConvertFrom-Yaml
      }
    } catch {
      $PSCmdlet.ThrowTerminatingError($PSItem)
    }

    if ($null -ne $fm) {
      if ($AsHashtable) {
        [hashtable]$fm
      } elseif ($Ordered) {
        $fm # ConvertFrom-Yaml returns an [ordered] by default
      } else {
        $fm['PSTypeName'] = 'PSMarkdig.YamlFrontMatterBlock'
        [PSCustomObject]$fm
      }
    }
  }
  end {
    Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
  }
}
