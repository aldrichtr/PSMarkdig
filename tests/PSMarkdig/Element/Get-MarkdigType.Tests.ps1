
Describe 'Get-MarkdigType' -Tags @('unit') {
  Context 'When called with no parameters' {
    BeforeAll {
      $results = Get-MarkdigType
    }

    It 'Should return multiple types' {
      @($results).Count | Should-BeGreaterThan 10
    }

    It 'Should include HeadingBlock' {
      $results | Should-Any { $_.Name -eq 'HeadingBlock' }
    }

    It 'Should include ParagraphBlock' {
      $results | Should-Any { $_.Name -eq 'ParagraphBlock' }
    }

    It 'Should have Name, FullName, Type, and BaseType properties' {
      $first = $results | Select-Object -First 1
      $first.Name | Should-NotBeEmptyString
      $first.FullName | Should-NotBeEmptyString
      $first.Type | Should-NotBeEmptyString
      $first.BaseType | Should-NotBeNull
    }
  }

  Context 'When filtering by name' {
    It 'Should return matching types for -Name Heading' {
      $results = Get-MarkdigType -Name 'Heading'
      $results | Should-NotBeNull
      $results | Should-All { $_.Name -like '*Heading*' }
    }

    It 'Should return nothing for a non-matching name' {
      $results = Get-MarkdigType -Name 'ZZZNonExistent'
      $results | Should-BeNull
    }
  }
}