
Describe 'Select-YamlFrontMatter' -Tags @('unit') {
  BeforeAll {
    $markdownWithFm = @"
---
title: My Document
author: Tim Aldrich
tags:
  - powershell
  - markdig
---

# Content

Body text here.
"@
    $markdownWithoutFm = @"
# No Front Matter

Just a regular document.
"@
    $docWithFm = Import-Markdown -Content $markdownWithFm
    $docWithoutFm = Import-Markdown -Content $markdownWithoutFm
  }

  Context 'When document has YAML front matter' {
    It 'Should return front matter when piped a MarkdigDocument' {
      $fm = $docWithFm | Select-YamlFrontMatter
      $fm | Should-NotBeNull
    }

    It 'Should return front matter when passed as argument' {
      $fm = Select-YamlFrontMatter $docWithFm
      $fm | Should-NotBeNull
    }

    It 'Should parse the title field' {
      $fm = $docWithFm | Select-YamlFrontMatter
      $fm.title | Should-Be 'My Document'
    }

    It 'Should parse the author field' {
      $fm = $docWithFm | Select-YamlFrontMatter
      $fm.author | Should-Be 'Tim Aldrich'
    }

    It 'Should parse array fields' {
      $fm = $docWithFm | Select-YamlFrontMatter
      $fm.tags | Should-BeCollection @('powershell', 'markdig')
    }

    It 'Should have PSTypeName PSMarkdig.YamlFrontMatter' {
      $fm = $docWithFm | Select-YamlFrontMatter
      $fm.PSTypeNames | Should-Any { $_ -eq 'PSMarkdig.YamlFrontMatter' }
    }
  }

  Context 'When document has no front matter' {
    It 'Should return null' {
      $fm = $docWithoutFm | Select-YamlFrontMatter
      $fm | Should-BeNull
    }
  }

  Context 'Backward compatibility with raw MarkdownDocument' {
    It 'Should accept a raw MarkdownDocument as argument' {
      $fm = Select-YamlFrontMatter $docWithFm.Ast
      $fm | Should-NotBeNull
      $fm.title | Should-Be 'My Document'
    }
  }
}