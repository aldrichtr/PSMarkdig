
Describe 'Import-DependentLibrary' -Tags @('unit', 'module') {
  Context 'When loading Markdig' {
    BeforeAll {
      $asm = [System.AppDomain]::CurrentDomain.GetAssemblies() | Where-Object {
        ($_.GetName().Name -eq 'Markdig') -and
        ($_.Location -like '*PSMarkdig\bin*')
      }
    }
    It 'Should not throw when loading Markdig 1.1.2 for net10.0' {
      # The suffix.ps1 already calls this, so if we got here the module loaded
      # This test validates the function is callable and the assembly is present
      $asm | Should-NotBeNull
    }

    It 'Should load the correct version' {
      $asm.GetName().Version.ToString() | Should-MatchString '^1\.1'
    }
  }

  Context 'Error handling' {
    It 'Should throw for a non-existent library name' {
      { Import-DependentLibrary -Name 'FakeLibrary' -DotNetVersion '10.0' -LibraryVersion '1.0.0' } | Should-Throw
    }
  }
}