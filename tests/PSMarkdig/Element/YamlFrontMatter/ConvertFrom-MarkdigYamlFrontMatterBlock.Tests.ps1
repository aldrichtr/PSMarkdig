
Describe 'ConvertFrom-MarkdigYamlFrontMatterBlock' -Tags @('unit') {
  BeforeAll {
    $markdown = @"
---
title: Test Doc
version: 2
tags:
  - alpha
  - beta
nested:
  key: value
---

# Content
"@
    $doc = Import-Markdown -Content $markdown
    $block = $doc | Select-MarkdigDescendant -Type 'Markdig.Extensions.Yaml.YamlFrontMatterBlock'
  }

  Context 'When converting to a PSCustomObject (default)' {
    BeforeAll {
      $result = $block | ConvertFrom-MarkdigYamlFrontMatterBlock
    }

    It 'Should return a non-null object' {
      $result | Should-NotBeNull
    }

    It 'Should have the title property' {
      $result.title | Should-Be 'Test Doc'
    }

    It 'Should parse integer values' {
      $result.version | Should-Be 2
    }

    It 'Should parse array values' {
      $result.tags | Should-BeCollection @('alpha', 'beta')
    }

    It 'Should have PSTypeName PSMarkdig.YamlFrontMatter' {
      $result.PSTypeNames | Should-Any { $_ -eq 'PSMarkdig.YamlFrontMatter' }
    }
  }

  Context 'When converting with -AsHashtable' {
    BeforeAll {
      $result = $block | ConvertFrom-MarkdigYamlFrontMatterBlock -AsHashtable
    }

    It 'Should return a hashtable' {
      Should-HaveType -Actual $result -Expected ([ordered])
    }

    It 'Should contain the title key' {
      $result['title'] | Should-Be 'Test Doc'
    }

    It 'Should not have a PSTypeName key' {
      $result.Contains('PSTypeName') | Should-BeFalse
    }
  }

  Context 'When block has no content' {
    BeforeAll {
      $emptyFmMarkdown = "---`n---`n`n# Empty front matter"
      $emptyDoc = Import-Markdown -Content $emptyFmMarkdown
      $emptyBlock = $emptyDoc | Select-MarkdigDescendant -Type 'Markdig.Extensions.Yaml.YamlFrontMatterBlock'
    }

    It 'Should handle empty front matter gracefully' {
      # Either returns null or empty - should not throw
      { $emptyBlock | ConvertFrom-MarkdigYamlFrontMatterBlock } | Should -Not -Throw
    }
  }
}