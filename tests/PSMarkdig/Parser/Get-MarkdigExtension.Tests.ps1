
Describe 'Get-MarkdigExtension' -Tags @('unit') {
  Context 'When called' {
    BeforeAll {
      $results = Get-MarkdigExtension
    }

    It 'Should return extension objects' {
      $results | Should-NotBeNull
      @($results).Count | Should-BeGreaterThan 10
    }

    It 'Should include YamlFrontMatter' {
      $results | Should-Any { $_.Name -eq 'YamlFrontMatter' }
    }

    It 'Should include PipeTables' {
      $results | Should-Any { $_.Name -eq 'PipeTables' }
    }

    It 'Should have PSTypeName PSMarkdig.MarkdownExtensionInfo' {
      $first = $results | Select-Object -First 1
      $first.PSTypeNames | Should-Any { $_ -eq 'PSMarkdig.MarkdownExtensionInfo' }
    }

    It 'Should have a ShortCode property' {
      $yaml = $results | Where-Object Name -eq 'YamlFrontMatter'
      $yaml.ShortCode | Should-NotBeEmptyString
    }
  }
}