
function Remove-MarkdownYamlFrontMatterBlock {
  <#
  .SYNOPSIS
    Delete the YAML frontmatter block from the document
  #>
  [CmdletBinding()]
  param(
    # The Document to remove frontmatter from
    [Parameter(
      ValueFromPipeline
    )]
    [MarkdigDocument]$Document
  )
  begin {}
  process {
    $fm = $Document | Select-MarkdownYamlFrontMatterBlock
    if ($null -ne $fm) {
      try {
        $success = $Document.Ast.Remove($fm)
        if ($success) {
          $Document.Modified = $true
          Write-Verbose 'Removed Frontmatter from document'
        }
      } catch {
        $PSCmdlet.ThrowTerminatingError($PSItem)
      }
    }
  }
  end {}
}
