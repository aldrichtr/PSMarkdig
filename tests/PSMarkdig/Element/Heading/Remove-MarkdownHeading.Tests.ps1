
Describe 'Remove-MarkdownHeading' -Tags @('unit') {
  BeforeAll {
    $markdown = @"
# Title

## Section One

Content one.

## Section Two

Content two.

### Subsection
"@
  }

  Context 'When removing a specific heading' {
    BeforeAll {
      $doc = Import-Markdown -Content $markdown
      $originalCount = $doc.Ast.Count
      $h3 = $doc | Select-MarkdownHeading -Level 3 | Select-Object -First 1
      $h3 | Remove-MarkdownHeading -Document $doc
    }

    It 'Should reduce the block count' {
      $doc.Ast.Count | Should-BeLessThan $originalCount
    }

    It 'Should no longer contain H3 headings' {
      $remaining = $doc | Select-MarkdownHeading -Level 3
      $remaining | Should-BeNull
    }

    It 'Should mark the document as dirty' {
      $doc.Modified | Should-BeTrue
    }
  }

  Context 'When removing multiple headings' {
    BeforeAll {
      $doc = Import-Markdown -Content $markdown
      $doc | Select-MarkdownHeading -Level 2 | Remove-MarkdownHeading -Document $doc
    }

    It 'Should remove all H2 headings' {
      $remaining = $doc | Select-MarkdownHeading -Level 2
      $remaining | Should-BeNull
    }

    It 'Should still have the H1' {
      $h1 = $doc | Select-MarkdownHeading -Level 1
      @($h1).Count | Should-Be 1
    }
  }

  Context 'Roundtrip rendering after remove' {
    BeforeAll {
      $doc = Import-Markdown -Content $markdown
      $doc | Select-MarkdownHeading -Level 3 | Remove-MarkdownHeading -Document $doc
      $rendered = $doc | Write-MarkdownElement
    }

    It 'Should not contain the removed heading in output' {
      $rendered | Should-NotMatchString '### Subsection'
    }

    It 'Should still contain the remaining headings' {
      $rendered | Should-MatchString '# Title'
      $rendered | Should-MatchString '## Section One'
    }
  }
}