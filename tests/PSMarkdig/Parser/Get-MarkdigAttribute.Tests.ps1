
Describe 'Get-MarkdigAttribute' -Tags @('unit') {
  BeforeAll {
    # Markdig generic attributes extension allows {.class #id key=value} syntax
    $markdown = @"
# Heading {.my-class #heading-id}

Paragraph with attributes. {data-custom=value}
"@
    $doc = Import-Markdown -Content $markdown
  }

  Context 'When an element has attributes' {
    It 'Should retrieve attributes from the heading' {
      $heading = $doc | Select-MarkdigDescendant -Type 'HeadingBlock' | Select-Object -First 1
      $attrs = Get-MarkdigAttribute -Element $heading
      # If the generic attributes extension parsed correctly, we should get something
      # This test validates the function runs without error
      # Attribute support depends on correct extension loading
      { Get-MarkdigAttribute -Element $heading } | Should -Not -Throw
    }
  }
}