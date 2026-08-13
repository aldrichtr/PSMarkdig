
Describe 'New-MarkdownParserContext' -Tags @('unit') {
  Context 'When called' {
    BeforeAll {
      $context = New-MarkdownParserContext
    }

    It 'Should return a MarkdownParserContext' {
      $context | Should-HaveType ([Markdig.MarkdownParserContext])
    }

    It 'Should have an empty Properties dictionary' {
      $context.Properties | Should-NotBeNull
    }
  }
}