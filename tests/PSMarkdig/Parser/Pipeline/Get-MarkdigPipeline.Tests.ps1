
Describe 'Get-MarkdigPipeline' -Tags @('unit') {
  BeforeAll {
    $doc = Import-Markdown -Content "# Hello`n`nWorld"
  }

  Context 'When piped a MarkdigDocument' {
    It 'Should return the pipeline from the document' {
      $pipeline = $doc | Get-MarkdigPipeline
      $pipeline | Should-NotBeNull
      $pipeline | Should-HaveType ([Markdig.MarkdownPipeline])
    }

    It 'Should return the same pipeline instance that produced the document' {
      $pipeline = $doc | Get-MarkdigPipeline
      Should-BeSame -Actual $pipeline -Expected $doc.Pipeline
    }
  }

  Context 'When no document is given' {
    It 'Should throw an exception' {
      {Get-MarkdigPipeline -Document $null} | Should-Throw -ExceptionMessage 'No MarkdigDocument was given'
    }
  }
}