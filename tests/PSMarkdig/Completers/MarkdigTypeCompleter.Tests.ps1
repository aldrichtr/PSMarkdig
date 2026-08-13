
Describe 'MarkdigTypeCompleter' -Tags @('unit', 'Completer') {
  Context 'When given <ToComplete>' -ForEach @(
    @{ ToComplete = 'Heading'; ExpectedMatch = 'HeadingBlock' }
    @{ ToComplete = 'Fenced'; ExpectedMatch = 'FencedCodeBlock' }
    @{ ToComplete = 'Paragraph'; ExpectedMatch = 'ParagraphBlock' }
  ) {
    It 'Should return a match containing <ExpectedMatch>' {
      $results = MarkdigTypeCompleter 'Test-Completer' 'Type' $ToComplete
      $results | Should-Any { $_ -like "*$ExpectedMatch*" }
    }
  }

  Context 'When given an empty string' {
    It 'Should return all Markdig types' {
      $results = MarkdigTypeCompleter 'Test-Completer' 'Type' ''
      @($results).Count | Should-BeGreaterThan 5
    }
  }
}