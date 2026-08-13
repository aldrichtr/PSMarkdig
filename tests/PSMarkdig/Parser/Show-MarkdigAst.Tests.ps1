
Describe 'Show-MarkdigAst' -Tags @('unit') {
  BeforeAll {
    $doc = Import-Markdown -Content "# Hello`n`nParagraph`n`n- Item 1`n- Item 2"
  }

  Context 'When showing the AST of a document' {
    It 'Should produce string output' {
      $output =  Show-MarkdigAst $doc.Ast
      $output | Should-NotBeNull
    }

    It 'Should contain block type names' {
      $output =  Show-MarkdigAst $doc.Ast
      ($output -join "`n") | Should-MatchString 'Heading|Paragraph|List'
    }
  }

  Context 'When using -FullName' {
    It 'Should produce output with fully qualified names' {
      $output =  Show-MarkdigAst $doc.Ast -FullName
      ($output -join "`n") | Should-MatchString 'Markdig'
    }
  }
}