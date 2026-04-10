
Describe 'Testing the ConvertTo-MarkdigObject function' -Tag @('Parser') {
  Context 'WHEN given the markdown <Content>' -ForEach @(
    @{ Content = "---`ntitle: A test markdown`n---`n`n# Heading 1"
      Results  = @{
        First = 'Markdig.Extensions.Yaml.YamlFrontMatterBlock'
      }
    }
  ) {
    BeforeAll {
      $result = ConvertTo-MarkdigObject -Content $Content
    }

    It 'Returns a MarkdownDocument' {
      $result.GetType() | Should -Be 'Markdig.Syntax.MarkdownDocument'
    }
    It 'The first element is a <Results.First>' {
      $result[0].GetType() | Should -Be $Results.First
    }
  }
}
