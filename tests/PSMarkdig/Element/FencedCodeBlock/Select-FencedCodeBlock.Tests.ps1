
Describe 'Select-FencedCodeBlock' -Tags @('unit', 'Element', 'FencedCodeBlock') {
  BeforeAll {
    $markdown = @"
# Code Examples

``````powershell
Get-Process | Where-Object { `$_.CPU -gt 100 }
``````

Some text between blocks.

``````python
import os
print(os.getcwd())
``````

``````json
{ "key": "value" }
``````
"@
    $doc = Import-Markdown -Content $markdown
  }

  Context 'When piped a MarkdigDocument' {
    It 'Should return all fenced code blocks' {
      $blocks = $doc | Select-FencedCodeBlock
      @($blocks).Count | Should-Be 3
    }

    It 'Should return FencedCodeBlock types' {
      $blocks = $doc | Select-FencedCodeBlock
      $blocks | Should-All { $_ -is [Markdig.Syntax.FencedCodeBlock] }
    }
  }

  Context 'When using -First' {
    It 'Should return only the first N blocks' {
      $blocks = $doc | Select-FencedCodeBlock -First 2
      @($blocks).Count | Should-Be 2
    }
  }

  Context 'When using -Skip' {
    It 'Should skip the first N blocks' {
      $blocks = $doc | Select-FencedCodeBlock -Skip 1
      @($blocks).Count | Should-Be 2
    }
  }

  Context 'When passed as argument' {
    It 'Should accept a MarkdigDocument positionally' {
      $blocks = Select-FencedCodeBlock $doc
      @($blocks).Count | Should-Be 3
    }
  }

  Context 'When document has no code blocks' {
    BeforeAll {
      $noCodeDoc = Import-Markdown -Content "# Just a heading`n`nParagraph."
    }

    It 'Should return nothing' {
      $blocks = $noCodeDoc | Select-FencedCodeBlock
      $blocks | Should-BeNull
    }
  }
}