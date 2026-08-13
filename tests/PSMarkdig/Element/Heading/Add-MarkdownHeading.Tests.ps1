
Describe 'Add-MarkdownHeading' -Tags @('unit') {
  BeforeAll {
    $markdown = @"
# Existing Title

Some content here.
"@
  }

  Context 'When appending a heading at the end' {
    BeforeAll {
      $doc = Import-Markdown -Content $markdown
      $originalCount = $doc.Ast.Count
      $doc | Add-MarkdownHeading -Text 'New Section' -Level 2
    }

    It 'Should add a block to the document' {
      $doc.Ast.Count | Should-Be ($originalCount + 1)
    }

    It 'Should add a HeadingBlock as the last element' {
      $last = $doc.Ast[$doc.Ast.Count - 1]
      $last | Should-HaveType ([Markdig.Syntax.HeadingBlock])
    }

    It 'Should set the correct level' {
      $last = $doc.Ast[$doc.Ast.Count - 1]
      $last.Level | Should-Be 2
    }

    It 'Should set the heading text' {
      $last = $doc.Ast[$doc.Ast.Count - 1]
      $last.Inline.FirstChild.Content.ToString() | Should-Be 'New Section'
    }

    It 'Should mark the document as dirty' {
      $doc.Modified | Should-BeTrue
    }
  }

  Context 'When inserting at a specific position' {
    BeforeAll {
      $doc = Import-Markdown -Content $markdown
      $doc | Add-MarkdownHeading -Text 'Inserted' -Level 3 -Position 0
    }

    It 'Should insert at position 0' {
      $first = $doc.Ast[0]
      $first | Should-HaveType ([Markdig.Syntax.HeadingBlock])
      $first.Inline.FirstChild.Content.ToString() | Should-Be 'Inserted'
    }

    It 'Should have level 3' {
      $doc.Ast[0].Level | Should-Be 3
    }
  }

  Context 'Roundtrip rendering after add' {
    BeforeAll {
      $doc = Import-Markdown -Content $markdown
      $doc | Add-MarkdownHeading -Text 'Appended' -Level 2
      $rendered = $doc | Write-MarkdownElement
    }

    It 'Should contain the new heading in rendered output' {
      $rendered | Should-MatchString '## Appended'
    }

    It 'Should still contain the original heading' {
      $rendered | Should-MatchString '# Existing Title'
    }
  }

  Context 'When using -PassThru' {
    It 'Should return the document' -Skip {
      $doc = Import-Markdown -Content $markdown
      $result = $doc | Add-MarkdownHeading -Text 'Test' -Level 1 -PassThru
      Should-HaveType -Actual $result -Expected ([MarkdigDocument])
    }
  }
}