
Describe 'Select-MarkdigDescendant' -Tags @('unit') {
  BeforeAll {
    $markdown = @"
---
title: Test
---

# Heading 1

Paragraph one.

## Heading 2

- List item 1
- List item 2

``````powershell
Get-Process
``````
"@
    $doc = Import-Markdown -Content $markdown
  }

  Context 'When piped a MarkdigDocument wrapper' {
    It 'Should accept a MarkdigDocument on the pipeline' {
      $results = $doc | Select-MarkdigDescendant
      $results | Should-NotBeNull
    }

    It 'Should return multiple descendants' {
      $results = $doc | Select-MarkdigDescendant
      @($results).Count | Should-BeGreaterThan 1
    }
  }

  Context 'When passed as a positional argument' {
    It 'Should accept a MarkdigDocument as Position 0' {
      $results = Select-MarkdigDescendant $doc
      $results | Should-NotBeNull
    }
  }

  Context 'When filtering by type' {
    It 'Should return only HeadingBlock elements for -Type HeadingBlock' {
      $headings = $doc | Select-MarkdigDescendant -Type 'HeadingBlock'
      $headings | Should-NotBeNull
      $headings | Should-All { $_ -is [Markdig.Syntax.HeadingBlock] }
    }

    It 'Should return FencedCodeBlock elements' {
      $codeBlocks = $doc | Select-MarkdigDescendant -Type 'FencedCodeBlock'
      $codeBlocks | Should-NotBeNull
      @($codeBlocks).Count | Should-Be 1
    }

    It 'Should accept a fully-qualified type name' {
      $headings = $doc | Select-MarkdigDescendant -Type 'Markdig.Syntax.HeadingBlock'
      $headings | Should-NotBeNull
    }

    It 'Should throw for an invalid type' {
      { $doc | Select-MarkdigDescendant -Type 'NotARealType' } | Should-Throw
    }
  }

  Context 'When passed a raw MarkdownObject (backward compat)' {
    It 'Should still work with a raw MarkdownDocument using positional binding' {
      $results = Select-MarkdigDescendant $doc.Ast
      $results | Should-NotBeNull
    }
  }

  Context 'When passed an invalid type' {
    It 'Should throw for a non-Markdig object' {
      { Select-MarkdigDescendant 'just a string' } | Should-Throw
    }
  }
}