
Describe 'New-MarkdigPipelineBuilder' -Tags @('unit') {
  Context 'When called with defaults' {
    BeforeAll {
      $builder = New-MarkdigPipelineBuilder
    }

    It 'Should return a MarkdownPipelineBuilder' {
      $builder | Should-HaveType ([Markdig.MarkdownPipelineBuilder])
    }

    It 'Should have TrackTrivia set to false by default' {
      $builder.TrackTrivia | Should-BeFalse
    }

    It 'Should have PreciseSourceLocation set to false by default' {
      $builder.PreciseSourceLocation | Should-BeFalse
    }
  }

  Context 'When called with -TrackTrivia' {
    BeforeAll {
      $builder = New-MarkdigPipelineBuilder -TrackTrivia
    }

    It 'Should set TrackTrivia to true' {
      $builder.TrackTrivia | Should-BeTrue
    }
  }

  Context 'When called with -PreciseSourceLocation' {
    BeforeAll {
      $builder = New-MarkdigPipelineBuilder -PreciseSourceLocation
    }

    It 'Should set PreciseSourceLocation to true' {
      $builder.PreciseSourceLocation | Should-BeTrue
    }
  }
}