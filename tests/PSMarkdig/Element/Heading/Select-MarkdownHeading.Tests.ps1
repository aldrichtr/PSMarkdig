
Describe 'Select-MarkdownHeading' -Tags @('unit') {
  BeforeAll {
    $markdown = @"
---
title: Test
---

# Title

## Section One

Some content.

### Subsection

## Section Two

#### Deep Heading
"@
    $doc = Import-Markdown -Content $markdown
  }

  Context 'When getting all headings' {
    BeforeAll {
      $headings = $doc | Select-MarkdownHeading
    }

    It 'Should return all heading blocks' {
      @($headings).Count | Should-Be 5
    }

    It 'Should return HeadingBlock types' {
      $headings | Should-All { $_ -is [Markdig.Syntax.HeadingBlock] }
    }
  }

  Context 'When filtering by single level' {
    It 'Should return only H1 headings for -Level 1' {
      $h1 = $doc | Select-MarkdownHeading -Level 1
      @($h1).Count | Should-Be 1
      $h1 | Should-All { $_.Level -eq 1 }
    }

    It 'Should return only H2 headings for -Level 2' {
      $h2 = $doc | Select-MarkdownHeading -Level 2
      @($h2).Count | Should-Be 2
      $h2 | Should-All { $_.Level -eq 2 }
    }

    It 'Should return only H3 headings for -Level 3' {
      $h3 = $doc | Select-MarkdownHeading -Level 3
      @($h3).Count | Should-Be 1
      $h3 | Should-All { $_.Level -eq 3 }
    }
  }

  Context 'When filtering by multiple levels' {
    It 'Should return H1 and H2 for -Level 1,2' {
      $headings = $doc | Select-MarkdownHeading -Level 1,2
      @($headings).Count | Should-Be 3
      $headings | Should-All { $_.Level -in @(1, 2) }
    }
  }

  Context 'When document has no headings' {
    BeforeAll {
      $noHeadingDoc = Import-Markdown -Content "Just a paragraph.`n`nAnother paragraph."
    }

    It 'Should return nothing' {
      $result = $noHeadingDoc | Select-MarkdownHeading
      $result | Should-BeNull
    }
  }

  Context 'When passed as positional argument' {
    It 'Should accept a MarkdigDocument' {
      $headings = Select-MarkdownHeading $doc
      @($headings).Count | Should-Be 5
    }
  }
}