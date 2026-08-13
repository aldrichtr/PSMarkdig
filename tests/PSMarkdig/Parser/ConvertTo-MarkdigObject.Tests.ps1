
Describe 'ConvertTo-MarkdigObject' -Tags @('unit', 'MarkdigDocument') {
  BeforeAll {
    $sampleMarkdown = @"
---
title: Test Document
tags: [test, pester]
---

# Heading One

Some paragraph text here.

## Heading Two

- Item 1
- Item 2

``````powershell
Get-Process | Select-Object Name
``````
"@
  }

  Context 'When parsing markdown text' {
    BeforeAll {
      $result = ConvertTo-MarkdigObject -Content $sampleMarkdown
    }

    It 'Should return a MarkdigDocument type' -Tag @('Type') {
      $result | Should-HaveType ([MarkdigDocument])
    }

    It 'Should contain a MarkdownDocument in the Document property' {
      Should-HaveType -Actual $result.Ast -Expected ([Markdig.Syntax.MarkdownDocument])
    }

    It 'Should have a non-null Pipeline' {
      $result.Pipeline | Should-NotBeNull
    }

    It 'Should have a non-null Context' {
      $result.Context | Should-NotBeNull
    }

    It 'Should have a ParsedAt timestamp' {
      $result.ParsedAt | Should-NotBeNull
    }

    It 'Should have Extensions populated' {
      $result.Extensions | Should-NotBeNull
      $result.Extensions.Count | Should-BeGreaterThan 0
    }

    It 'Should not be marked dirty' {
      $result.Modified | Should-BeFalse
    }

    It 'Should have no source path (parsed from string)' {
      $result.Path | Should-BeNull
    }

    It 'Should have an empty Metadata hashtable' {
      Should-HaveType -Actual $result.Metadata -Expected ([hashtable])
      $result.Metadata.Count | Should-Be 0
    }
  }

  Context 'When parsing with a custom pipeline' {
    BeforeAll {
      $pipeline = New-MarkdigPipeline -Extensions (
        Get-MarkdigExtension | Where-Object Name -eq 'PipeTables'
      )
      $result = ConvertTo-MarkdigObject -Content '| A | B |' -Pipeline $pipeline
    }

    It 'Should use the provided pipeline' {
      Should-BeSame -Actual $result.Pipeline -Expected $pipeline
    }
  }

  Context 'When content is null or empty' {
    It 'Should throw when no content is provided' {
      { ConvertTo-MarkdigObject -Content '' } | Should-Throw
    }
  }

  Context 'Pipeline unrolling prevention' {
    BeforeAll {
      $result = ConvertTo-MarkdigObject -Content $sampleMarkdown
    }

    It 'Should survive the pipeline without unrolling' {
      $piped = $result | ForEach-Object { $_ }
      $piped | Should-HaveType ([MarkdigDocument])
    }

    It 'Should pipe to downstream functions correctly' {
      # This is THE test - the whole reason for the wrapper
      $frontMatter = $result | Select-YamlFrontMatter
      $frontMatter | Should-NotBeNull
      $frontMatter.title | Should-Be 'Test Document'
    }
  }
}