
Describe 'New-MarkdigPipeline' -Tags @('unit') {
  Context 'When called with defaults' {
    BeforeAll {
      $pipeline = New-MarkdigPipeline
    }

    It 'Should return a MarkdownPipeline' {
      $pipeline | Should-HaveType ([Markdig.MarkdownPipeline])
    }

    It 'Should have extensions loaded' {
      $pipeline.Extensions.Count | Should-BeGreaterThan 10
    }

    It 'Should include YamlFrontMatter extension' {
      $names = $pipeline.Extensions | ForEach-Object { $_.GetType().Name }
      $names | Should-Any { $_ -like '*YamlFrontMatter*' }
    }
  }

  Context 'When called with -IgnoreTrivia' {
    BeforeAll {
      $pipeline = New-MarkdigPipeline -IgnoreTrivia
    }

    It 'Should still return a valid pipeline' {
      $pipeline | Should-HaveType ([Markdig.MarkdownPipeline])
    }
  }

  Context 'When called with custom extensions' {
    BeforeAll {
      $ext = Get-MarkdigExtension | Where-Object Name -eq 'PipeTables'
      $pipeline = New-MarkdigPipeline -Extensions $ext
    }

    It 'Should build a pipeline with the specified extensions' {
      $pipeline | Should-HaveType ([Markdig.MarkdownPipeline])
    }

    It 'Should have fewer extensions than the default' {
      $defaultPipeline = New-MarkdigPipeline
      $pipeline.Extensions.Count | Should-BeLessThan $defaultPipeline.Extensions.Count
    }
  }
}