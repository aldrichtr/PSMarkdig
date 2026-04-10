
using namespace System.Collections
using namespace Markdig
using namespace Markdig.Parsers
using namespace Markdig.Syntax

function ConvertTo-MarkdigObject {
  <#
    .SYNOPSIS
        Convert the given Markdown text into a Markdig object
    #>
  [CmdletBinding()]
  param(
    # The text to parse into a markdig object
    [Parameter(
      ValueFromPipeline,
      ValueFromPipelineByPropertyName
    )]
    [string[]]$Content,

    # Short-names of extensions to add
    [Parameter(
    )]
    [string[]]$Extension,

    # Use an existing pipeline
    [Parameter(
    )]
    [MarkdownPipeline]$Pipeline,

    # Ignore trivia (whitespace, extra heading characters, unescaped strings, etc)
    [Parameter(
    )]
    [switch]$IgnoreTrivia,

    # Enable debug logging in the Markdown parser
    [Parameter(
      ParameterSetName = 'debuglog'
    )]
    [switch]$DebugParser,

    # If DebugParser is given but no LogPath, then use [System.Console]::Out as the TextWriter
    # Path to the debug log for the parser (if enabled)
    [Parameter(
      ParameterSetName = 'debuglog'
    )]
    [string]$LogPath
  )
  begin {
    $self = $MyInvocation.MyCommand
    Write-Debug "`n$('-' * 80)`n-- Begin $($self.Name)`n$('-' * 80)"


    $collect = [ArrayList]::new()
  }
  process {
    # SECTION Collect incoming content

    foreach ($text in $Content) {
      $null = $collect.Add($text)
    }
    # !SECTION
  }
  end {
    # SECTION Format the content
    $content = $collect -join "`n"

    Write-Debug "Content is:`n$([regex]::Escape($content) -replace '\\n', "\n`n")"
    if ([string]::IsNullorEmpty($content)) {
      throw 'No content was received'
    } else {
      Write-Debug "Length of content to be parsed: $($content.Length)"
    }
    # !SECTION

    # SECTION Create the parser pipeline
    if ($PSBoundParameters.ContainsKey('Pipeline')) {
      Write-Debug '- Using existing pipeline'
    } else {
      $builder = [MarkdownPipelineBuilder]::new()
    # !SECTION

    # SECTION Parser Debugging
      if ($DebugParser) {
        Write-Debug 'Markdown parser debug enabled'
        if ($PSBoundParameters.ContainsKey('LogPath')) {
          Write-Debug "- Writing to $LogPath"
          [TextWriter]$tw = [File]::CreateText( $LogPath )
          $builder.DebugLog = $tw
          #TODO: Move this into a New-MarkdigBuilder so that options can be built up and accessed programatically
        } else {
          Write-Debug '- Writing to Console'
          $builder.DebugLog = [System.Console]::Out
        }
      }
      # !SECTION

    # SECTION Setup extensions
    if ($PSBoundParameters.ContainsKey('Extension')) {
      $markdigExtension = $Extension -join '+'
    } else {
      $markdigExtension = 'advanced+yaml'
    }
    Write-Debug "Setting extensions to $markdigExtension"
    $builder = [MarkdownExtensions]::Configure($builder, $markdigExtension)
    # !SECTION

      # SECTION track whitespace and newlines
      if (-not($IgnoreTrivia)) {
        $builder.PreciseSourceLocation = $true
        $builder = [MarkdownExtensions]::EnableTrackTrivia($builder)

      } else {
        Write-Verbose 'Ignoring whitespace and other trivia'
      }
      # !SECTION

      # SECTION Build the pipeline
      Write-Debug 'Parser configured'
      $extensions = $builder.Extensions
      | ForEach-Object {
        $_.GetType()
        | Select-Object -ExpandProperty Name
      }
      Write-Debug ('- {0,-28} => {1}' -f 'Extensions', (($extensions -replace 'Extension$', '') -join ', '))
      Write-Debug ('- {0,-28} => {1}' -f 'Precise Source Location', $builder.PreciseSourceLocation)
      Write-Debug ('- {0,-28} => {1}' -f 'Track trivia(whitespace)', $builder.TrackTrivia)
      Write-Debug ('- {0,-28} => {1}' -f 'Debug Log', $builder.DebugLog)

      $Pipeline = $builder.Build()
    }
    # !SECTION

    # NOTE: Store the Pipeline in the Module scope
    $script:MarkdigPipeline = $Pipeline

    # SECTION Parse the content
    Write-Debug "Parsing document $File"
    $context = [MarkdownParserContext]::new()
    [MarkdownDocument]$document = [MarkdownParser]::Parse( $content , $Pipeline , $context)
    Write-Debug "Context properties: $($context.Properties.Keys.Count))"
    if ($null -ne $tw) {
      $tw.Flush()
      $tw.Close()
    }
    Write-Debug "Parsing complete. created $($document.GetType())"
    # !SECTION

    if ($null -ne $document) {
      Write-Output $document -NoEnumerate
    } else {
      throw "There was an error parsing $File"
    }
    Write-Debug "`n$('-' * 80)`n-- End $($self.Name)`n$('-' * 80)"
  }
}
