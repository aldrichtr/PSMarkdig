
Describe 'Set-MarkdownHeading' -Tags @('unit', 'Heading') {
  BeforeAll {
    $markdown = @"
# Original Title

## Section One

Content.

## Section Two
"@
  }

  Context 'When changing the level' {
    BeforeAll {
      $doc = Import-Markdown -Content $markdown
      $h2 = $doc | Select-MarkdownHeading -Level 2 | Select-Object -First 1
      $h2 | Set-MarkdownHeading -Level 3 -Document $doc
    }

    It 'Should change the heading level' {
      $h2.Level | Should-Be 3
    }

    It 'Should update HeaderCharCount' {
      $h2.HeaderCharCount | Should-Be 3
    }

    It 'Should mark the document as dirty' {
      $doc.Modified | Should-BeTrue
    }
  }

  Context 'When changing the text' {
    BeforeAll {
      $doc = Import-Markdown -Content $markdown
      $h1 = $doc | Select-MarkdownHeading -Level 1 | Select-Object -First 1
      $h1 | Set-MarkdownHeading -Text 'Updated Title' -Document $doc
    }

    It 'Should change the inline text' {
      $h1 | Format-HeadingText | Should-Be 'Updated Title'
    }

    It 'Should mark the document as dirty' {
      $doc.Modified | Should-BeTrue
    }
  }

  Context 'When changing both level and text' {
    BeforeAll {
      $doc = Import-Markdown -Content $markdown
      $heading = $doc | Select-MarkdownHeading -Level 2 | Select-Object -First 1
      $heading | Set-MarkdownHeading -Level 4 -Text 'New Text' -Document $doc
    }

    It 'Should update both level and text' {
      $heading.Level | Should-Be 4
      $heading | Format-HeadingText | Should-Be 'New Text'
    }
  }

  Context 'Roundtrip rendering after set' {
    BeforeAll {
      $doc = Import-Markdown -Content $markdown
      $h1 = $doc | Select-MarkdownHeading -Level 1 | Select-Object -First 1
      $h1 | Set-MarkdownHeading -Text 'Changed' -Document $doc
      $rendered = $doc | Write-MarkdownElement
    }

    It 'Should render the updated heading text' {
      $rendered | Should-MatchString '# Changed'
    }

    It 'Should not contain the original title' {
      $rendered | Should-NotMatchString 'Original Title'
    }
  }

  Context 'When using -PassThru' {
    BeforeAll {
      $doc = Import-Markdown -Content $markdown
      $heading = $doc | Select-MarkdownHeading -Level 1 | Select-Object -First 1
      $result = $heading | Set-MarkdownHeading -Level 2 -Document $doc -PassThru
    }

    It 'Should return the heading block' {
      $result | Should-HaveType ([Markdig.Syntax.HeadingBlock])
    }
  }
}