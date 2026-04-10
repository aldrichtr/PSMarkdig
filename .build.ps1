
task add_markdig_lib {
  dotnet package download Markdig --output "source/PSMarkdig/bin"
}


task Validate {
  # Synopsis:  Validate that the environment is set up



}

task Test {
  Import-Module "$BuildRoot/source/PSMarkdig/PSMarkdig.psd1" -Force
  $config = New-PesterConfiguration

  $config.Run.Path = "$BuildRoot/tests"

  Invoke-Pester -Configuration $config
}
