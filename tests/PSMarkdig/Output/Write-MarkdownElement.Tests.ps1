
Describe 'Write-MarkdownElement' -Tags @('unit') {
  BeforeAll {
    $markdown = @"
---
title: Roundtrip Test
---

# Heading

Paragraph with **bold** and *italic*.

- List item 1
- List item 2
"@
    $doc = Import-Markdown -Content $markdown
  }

  Context 'When rendering a full MarkdigDocument' {
    BeforeAll {
      $output = $doc | Write-MarkdownElement
    }

    It 'Should return a string' {
      $output | Should-HaveType ([string])
    }

    It 'Should contain the heading' {
      $output | Should-MatchString '# Heading'
    }

    It 'Should contain the front matter delimiters' {
      $output | Should-MatchString '^---'
    }

    It 'Should contain bold markup' {
      $output | Should-MatchString '\*\*bold\*\*'
    }
  }

  Context 'When rendering individual AST elements' {
    It 'Should render a single heading block' {
      $heading = $doc | Select-MarkdigDescendant -Type 'HeadingBlock' | Select-Object -First 1
      $output = Write-MarkdownElement -Element $heading
      $output | Should-NotBeEmptyString
      $output | Should-MatchString 'Heading'
    }
  }

  Context 'Roundtrip fidelity' {
    It 'Should preserve content through parse-then-render' {
      $simpleMarkdown = "# Simple`n`nParagraph.`n"
      $doc2 = Import-Markdown -Content $simpleMarkdown
      $rendered = $doc2 | Write-MarkdownElement
      # Roundtrip should preserve the structure (may have minor whitespace differences)
      $rendered | Should-MatchString '# Simple'
      $rendered | Should-MatchString 'Paragraph\.'
    }
  }

  Context 'Backward compatibility' {
    It 'Should accept a raw MarkdownObject' {
      $output = Write-MarkdownElement -Element $doc.Ast
      $output | Should-HaveType ([string])
      $output | Should-NotBeEmptyString
    }
  }
}