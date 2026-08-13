
Describe 'Import-Markdown' -Tags @('unit', 'MarkdigObject') {
  BeforeAll {
    # Create a temp markdown file with known encoding and content
    $tempDir = Join-Path ([System.IO.Path]::GetTempPath()) "PSMarkdig_Tests_$([guid]::NewGuid().ToString('N'))"
    New-Item -ItemType Directory -Path $tempDir -Force | Out-Null

    $utf8Content = @"
---
title: UTF8 Test
---

# Hello World

Paragraph text.
"@
    $utf8Path = Join-Path $tempDir 'utf8.md'
    [System.IO.File]::WriteAllText($utf8Path, $utf8Content, [System.Text.UTF8Encoding]::new($false))

    $utf8BomPath = Join-Path $tempDir 'utf8bom.md'
    [System.IO.File]::WriteAllText($utf8BomPath, $utf8Content, [System.Text.UTF8Encoding]::new($true))

    $crlfContent = "# Title`r`n`r`nParagraph`r`n"
    $crlfPath = Join-Path $tempDir 'crlf.md'
    [System.IO.File]::WriteAllText($crlfPath, $crlfContent, [System.Text.UTF8Encoding]::new($false))

    $lfContent = "# Title`n`nParagraph`n"
    $lfPath = Join-Path $tempDir 'lf.md'
    [System.IO.File]::WriteAllText($lfPath, $lfContent, [System.Text.UTF8Encoding]::new($false))
  }

  AfterAll {
    Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue
  }

  Context 'When importing from a file path' {
    BeforeAll {
      $result = Import-Markdown -Path $utf8Path
    }

    It 'Should return a MarkdigDocument' {
      $result | Should-HaveType ([MarkdigDocument])
    }

    It 'Should populate the Path property' {
      $result.Path | Should-NotBeEmptyString
    }

    It 'Should resolve to the full path' {
      $result.Path | Should-BeString $utf8Path
    }

    It 'Should detect UTF-8 encoding (no BOM)' {
      $result.Encoding.GetPreamble().Length | Should-Be 0
    }

    It 'Should have parsed the AST' {
      $result.Ast.Count | Should-BeGreaterThan 0
    }
  }

  Context 'When importing a UTF-8 BOM file' {
    BeforeAll {
      $result = Import-Markdown -Path $utf8BomPath
    }

    It 'Should detect UTF-8 BOM encoding' {
      $result.Encoding.GetPreamble().Length | Should-BeGreaterThan 0
    }
  }

  Context 'When detecting line endings' {
    It 'Should detect CRLF' {
      $result = Import-Markdown -Path $crlfPath
      ($result.LineEnding).ToString() | Should-Be ([Markdig.Helpers.Newline]::CarriageReturnLineFeed).ToString()
    }

    It 'Should detect LF' {
      $result = Import-Markdown -Path $lfPath
      ($result.LineEnding).ToString() | Should-Be ([Markdig.Helpers.Newline]::LineFeed).ToString()
    }
  }

  Context 'When importing from pipeline text' {
    BeforeAll {
      $markdown = "# Test`n`nContent here"
      $result = $markdown | Import-Markdown
    }

    It 'Should return a MarkdigDocument' {
      $result | Should-HaveType ([MarkdigDocument])
    }

    It 'Should have no source path' {
      $result.Path | Should-BeNull
    }

    It 'Should parse the content' {
      $result.Ast.Count | Should-BeGreaterThan 0
    }
  }

  Context 'When importing from Get-ChildItem (PSPath binding)' {
    BeforeAll {
      $result = Get-ChildItem $utf8Path | Import-Markdown
    }

    It 'Should return a MarkdigDocument' {
      $result | Should-HaveType ([MarkdigDocument])
    }

    It 'Should have the file path set' {
      $result.Path | Should-NotBeEmptyString
    }
  }

  Context 'Pipeline unrolling - the core scenario' {
    It 'Should pipe directly to Select-YamlFrontMatter without the comma trick' {
      $doc = Import-Markdown -Path $utf8Path
      $fm = $doc | Select-YamlFrontMatter
      $fm | Should-NotBeNull
      $fm.title | Should-Be 'UTF8 Test'
    }

    It 'Should pipe directly to Select-MarkdigDescendant' {
      $doc = Import-Markdown -Path $utf8Path
      $descendants = $doc | Select-MarkdigDescendant
      $descendants | Should-NotBeNull
    }
  }

  Context 'Error handling' {
    It 'Should throw for a non-existent file' {
      { Import-Markdown -Path 'C:\nonexistent\fake.md' } | Should-Throw
    }
  }
}