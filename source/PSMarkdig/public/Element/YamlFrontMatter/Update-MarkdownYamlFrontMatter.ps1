
using namespace System.Management.Automation

function Update-MarkdownYamlFrontMatter {
  <#
  .SYNOPSIS
    Update the values in the markdown frontmatter
  #>
  [Alias(
    'Update-MarkdownFrontMatter',
    'Update-FrontMatter')]
  [CmdletBinding(
    SupportsShouldProcess
  )]
  param(
    # A hashtable of values to update the yaml frontmatter with
    [Parameter(
      Position = 0
    )]
    [hashtable]$Frontmatter,

    # The MarkdigDocument to update
    [Parameter(
      Mandatory,
      ValueFromPipeline
    )]
    [MarkdigDocument]$Document
  )
  begin {
    # TODO: Offer these as configuration options
    # Number of nested object levels before parser truncates output
    $conversion_depth = 16
    $indentLists = $true
    $scalar_style = 'SingleQuoted'
    $collection_style = 'Block'
  }
  process {
    try {
      $fmblock = $Document | Select-MarkdownYamlFrontMatterBlock
    } catch {
      $PSCmdlet.ThrowTerminatingError($PSItem)
    }

    if ($null -ne $fmblock) {
      $fm = ConvertFrom-MarkdownYamlFrontMatterBlock -Block $fmblock -AsHashtable
    } else {
      $PSCmdlet.ThrowTerminatingError(
        [ErrorRecord]::new(
          [System.Exception]::new('Frontmatter not found in document'),
          'MarkdownYamlFrontMatterBlockNotFound',
          [ErrorCategory]::ObjectNotFound,
          $Document
        ))
    }
    $fm = $fm | Update-Object $Frontmatter
    $formatOptions = @{
      ScalarStyle     = $scalar_style
      CollectionStyle = $collection_style
      PassThru        = $true
    }
    $convertOptions = @{
      Depth          = $conversion_depth
      IndentSequence = $indentLists
    }

    $newDocSource = (@(
        '---',
        ($fm | Add-YamlFormat @formatOptions | ConvertTo-Yaml @convertOptions),
        '---'
      ) -join "`n")
    Remove-Variable @('formatOptions', 'convertOptions') -Force

    try {
      $options = @{
        Content  = $newDocSource
        Pipeline = $Document.Pipeline
        Context  = $Document.Context
      }
      $newDoc = ConvertTo-MarkdigObject @options
      Remove-Variable 'options'
    } catch {
      $PSCmdlet.ThrowTerminatingError($PSItem)
    }

    if ($null -ne $newDoc) {
      try {
        $newFm = $newDoc | Select-MarkdownYamlFrontMatterBlock
      } catch {
        $PSCmdlet.ThrowTerminatingError($PSItem)
      }

      if ($null -ne $newFm) {
        try {
          if ($PSCmdlet.ShouldProcess('Frontmatter', 'Update')) {
            $null = $newDoc.Ast.Remove($newFM)
            $null = $Document.Ast.Remove($fmblock)
            $null = $Document.Ast.Insert(0, $newFm)
          }
        } catch {
          $PSCmdlet.ThrowTerminatingError($PSItem)
        }
      }
    }
  }
  end {
  }
}
