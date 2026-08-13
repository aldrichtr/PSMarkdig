
Describe 'MarkdigExtensionCompleter' -Tags @('unit', 'Completer') {
  BeforeAll {
    $fnName = 'Test-Completer'
    $pName = 'Extension'
  }

  Context 'When given <ToComplete>' -ForEach @(
    @{ ToComplete = 'YamlF'; Completion = 'YamlFrontMatter' }
    @{ ToComplete = 'Pipe'; Completion = 'PipeTables' }
  ) {
    BeforeAll {
      $result = MarkdigExtensionCompleter $fnName $pName $ToComplete
    }
    It 'Should return <Completion>' {
      $result.CompletionText | Should-BeLikeString $Completion
    }
  }

  Context 'When given an empty string' {
    It 'Should return all extensions' {
      $results = MarkdigExtensionCompleter 'Test-Completer' 'Extension' ''
      @($results).Count | Should-BeGreaterThan 10
    }
  }

  Context 'When given a non-matching prefix' {
    It 'Should return nothing' {
      $results = MarkdigExtensionCompleter 'Test-Completer' 'Extension' 'ZZZNonExistent'
      $results | Should-BeNull
    }
  }
}