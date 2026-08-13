
using namespace System.Collections
using namespace System.IO
using namespace System.Text
using namespace Markdig
using namespace Markdig.Parsers
using namespace Markdig.Helpers
using namespace Markdig.Syntax

function Import-Markdown {
  <#
    .SYNOPSIS
      Parse markdown from the pipeline or a file into a [MarkdigDocument] wrapper.
    .DESCRIPTION
      Accepts markdown content as text or a file path, parses it using the Markdig library,
      and returns a [MarkdigDocument] object that carries the AST, pipeline, context, source
      path, encoding, and line-ending metadata together.

      The wrapper prevents PowerShell's pipeline unrolling of the underlying MarkdownDocument
      (which implements IEnumerable), so you can pipe naturally:

        $doc = Import-Markdown ./README.md
        $doc | Select-YamlFrontMatter

    .EXAMPLE
      $doc = Get-ChildItem "Changelog.md" | Import-Markdown

    .EXAMPLE
      $doc = Get-Content "Changelog.md" | Import-Markdown

    .EXAMPLE
      $doc = Import-Markdown -Path "./notes.md" -Extensions 'pipetables','yaml'
  #>
  [CmdletBinding(
    DefaultParameterSetName = 'AsText'
  )]
  param(

    # Content to be converted
    [Parameter(
      ParameterSetName = 'AsText',
      ValueFromPipeline
    )]
    [string[]]$Content,

    # A markdown file to be converted
    [Parameter(
      ParameterSetName = 'AsPath',
      ValueFromPipelineByPropertyName
    )]
    [Alias('PSPath')]
    [string[]]$Path,

    # A list of Markdig Extensions to add to the pipeline
    # all Extensions are enabled by default
    [Parameter()]
    [string[]]$Extensions,

    # Ignore trivia (whitespace, extra heading characters, unescaped strings, etc)
    [Parameter(
    )]
    [switch]$IgnoreTrivia,

    # Enable debug logging in the Markdown parser
    [Parameter(
    )]
    [switch]$DebugParser,

    # Path to the debug log for the parser (if enabled)
    [Parameter(
    )]
    [string]$LogPath
  )
  begin {
    $parserParameters = [ArrayList]::new(@(
        'Extensions', 'IgnoreTrivia', 'DebugParser', 'LogPath'
      ))
    $collect = [ArrayList]::new()
  }
  process {
    switch ($PSCmdlet.ParameterSetName) {
      'AsText' {
        Write-Debug 'Received text content'
        $null = $collect.Add($Content)
      }
      'AsPath' {
        foreach ($File in $Path) {
          if (Test-Path $File) {
            try {
              Write-Debug "Received Path to $File"
              $File = $File | Convert-Path
              Write-Debug "Checking on Encoding for '$File'"
              $encoding = $File | Get-FileEncoding
            } catch {
              Write-Warning "Could not determine the file encoding for '$File'"
            }

            $options = @{
              Content = [File]::ReadAllText($File)
            }
            foreach ($p in $parserParameters) {
              if ($PSBoundParameters.ContainsKey($p)) {
                $options[$p] = $PSBoundParameters[$p]
              }
            }
            try {
              Write-Debug "Parsing '$"
              $result = ConvertTo-MarkdigObject @options
              $result.Path = $File
              $result.Encoding = $encoding
            } catch {
              $err = $_ # The original error
              $message = "Could not parse '$File'"
              $exceptionText = ( @($message, $err.ToString()) -join "`n")
              $newException = [Exception]::new($exceptionText)
              $eRecord = [System.Management.Automation.ErrorRecord]::new(
                $newException,
                $err.FullyQualifiedErrorId,
                $err.CategoryInfo.Category,
                $File
              )
              $PSCmdlet.ThrowTerminatingError( $eRecord )
            }
            $result
          } else {
            throw "$File is not a valid path"
          }
        }
      }
    }
  }
  end {
    if ($PSCmdlet.ParameterSetName -like 'AsText') {
      Write-Debug 'Collected all incoming text'
      $options = @{
        Content = $collect
      }
      foreach ($p in $parserParameters) {
        if ($PSBoundParameters.ContainsKey($p)) {
          $options[$p] = $PSBoundParameters[$p]
        }
      }
      try {
        ConvertTo-MarkdigObject @options
      } catch {
        $err = $_ # The original error
        $message = "Could not parse content"
        $exceptionText = ( @($message, $err.ToString()) -join "`n")
        $newException = [Exception]::new($exceptionText)
        $eRecord = [System.Management.Automation.ErrorRecord]::new(
          $newException,
          $err.FullyQualifiedErrorId,
          $err.CategoryInfo.Category,
          $collect
        )
        $PSCmdlet.ThrowTerminatingError( $eRecord )
      }
    }
  }
}