
using namespace System.Collections
using namespace System.Text
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

    # Provide a custom list of extensions
    [Parameter(
    )]
    [PSTypeName('PSMarkdig.MarkdownExtensionInfo')]
    [Object[]]$Extensions,

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
    # SECTION Normalize the content
    # We want to pass one *text object* to the parser, so we join all the individual lines, and normalize
    # the line-endings
    if ([string]::IsNullorEmpty($collect)) { throw 'No content receieved' }

    $content = $collect -join "`n"

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
      $options = @{
        TrackTrivia           = (-not $IgnoreTrivia)
        PreciseSourceLocation = $true
      }
      $builder = New-MarkdigPipelineBuilder @options
      # !SECTION

      # SECTION Parser debugging output

      if ($DebugParser) {
        Write-Debug 'Markdown parser debug enabled'
        if ($PSBoundParameters.ContainsKey('LogPath')) {
          Write-Debug "- Writing to $LogPath"
          [TextWriter]$tw = [File]::CreateText( $LogPath )
          $builder.DebugLog = $tw
        } else {
          Write-Debug '- Writing to Console'
          $builder.DebugLog = [System.Console]::Out
        }
      }
      # !SECTION

      # SECTION Setup extensions

      <# NOTE
       # Extension Names
       The extension system is very robust and configurable, but there are two problems we need to deal
       with:
       1.  If what we want is to enable *all* extensions, and thus be able to parse the *most* amount of
           markdown elements, that is not easy to do programmatically.  It is trivial to get a list of
            extensions, see [[Get-MarkdigExtension]], but some of the extensions are "grouping" extensions,
            like the `AdvancedExtensions` which represents about half of the most used (but critically, not
            the YAML front matter ext), or the `SelfPipeline` which ignores all other extensions and builds
            the list from special comments in the document.
            Unfortunately, there is currently no property or method on the extensions that can help with
            identifying which are groups.
        2.  There are *short-codes* for the extensions [^1], which is what gets passed (as a '+' separated
            string) but these names are also not part of the extension object, you just have to *know them*
        That said, I'm making an assumption that by default, we would want all of the extensions that
        actually contribute additional parsing "turned on".  So I'm going to need to hard code those names
        here for the time being until markdig adds some properties or methods to get the list
        programmatically

        [^1] https://github.com/xoofx/markdig/blob/master/src/Markdig/MarkdownExtensions.cs#L548
     #>
     # LINK Get-MarkdigExtension.ps1
      $allExtensions = Get-MarkdigExtension


      if (-not ($PSBoundParameters.ContainsKey('Extensions'))) {
        <# This is my opinionated list of "All" extensions #>
        $wanted = @(
          <# -- Not used
            'Advanced', -- Group of extensions listed individually below
            'SoftlineBreak', -- Non-obvious change to output so it should be explicitly added
            'SelfPipeline',  -- alternate method of adding extensions
            'JiraLinks',  -- Needs a jira url, so it should be configured and added explicitly
            'ReferralLinks', -- Adds rel attributes, should be explicitly added
            'PragmaLines', -- Non-obvious change to code blocks
            'NonAsciiNoEscape', -- Only useful for specific browser rendering
          -- #>
          <# -- Advanced -- #>
          'AlertBlocks', 'Abbreviations', 'AutoIdentifiers', 'Citations', 'CustomContainers',
          'DefinitionLists', 'EmphasisExtras', 'Figures', 'Footers', 'FootNotes', 'GridTables',
          'Mathmatics', 'MediaLinks', 'PipeTables', 'ListExtras', 'TaskLists', 'Diagrams',
          'AutoLinks',
          <# -- Additional -- #>
          'EmojiAndSmiley', 'SmartyPants', 'Bootstrap', 'YamlFrontMatter',
          <# -- Required Last -- #>
          'GenericAttributes'
        )

        $extList = [ArrayList]::new()

        foreach ($w in $wanted) {
          $ext = $allExtensions | Where-Object Name -Like $w
          if ($null -ne $ext) {
            $null = $extList.Add($ext)
          }
        }
      } else {
        $extList = $Extensions
      }

      $mdExt = [StringBuilder]::new()
      $counter = 0
      foreach ($e in $extList) {
        $counter++
        $code = $e.ShortCode
        if (-not ([string]::IsNullorEmpty($code))) {
          if ($counter -gt 1) {
            $null = $mdExt.Append('+')
            $first = $false
          }
          $null = $mdExt.Append($code)
        } else {
          Write-Warning "$($e.Name) Extension has no shortcode. It was not added to the parser"
        }
        Write-Debug "Adding Extension $($e.Name)"
      }


      # -- Add the extensions to the builder
      $builder = [MarkdownExtensions]::Configure($builder, $mdExt.ToString())
      # !SECTION
      # -----------------------------------------------------------------------------------------------------


      # -----------------------------------------------------------------------------------------------------
      # SECTION Build the pipeline
      Write-Debug 'Parser configured'
      Write-Debug ('-' * 40)
      $extensions = $builder.Extensions
      | ForEach-Object {
        $_.GetType()
        | Select-Object -ExpandProperty Name
      }
      Write-Debug ('- {0,-28} => {1}' -f 'Extensions', (($extensions -replace 'Extension$', '') -join ', '))
      Write-Debug ('- {0,-28} => {1}' -f 'Precise Source Location', $builder.PreciseSourceLocation)
      Write-Debug ('- {0,-28} => {1}' -f 'Track trivia(whitespace)', $builder.TrackTrivia)
      Write-Debug ('- {0,-28} => {1}' -f 'Context properties', $context.Properties.Keys.Count)
      Write-Debug ('- {0,-28} => {1}' -f 'Debug Log', $builder.DebugLog)
      Write-Debug ('-' * 40)

      $Pipeline = $builder.Build()
    }
    # !SECTION
    # -----------------------------------------------------------------------------------------------------

    # NOTE: Store the Pipeline in the Module scope, because it is also used for calls to render
    $script:MarkdigPipeline = $Pipeline

    # SECTION Parse the content
    Write-Debug "Parsing document $File"
    $context = [MarkdownParserContext]::new()
    [MarkdownDocument]$document = [MarkdownParser]::Parse( $content , $Pipeline , $context)
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
