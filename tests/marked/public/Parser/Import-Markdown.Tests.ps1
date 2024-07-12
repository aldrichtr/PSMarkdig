
using namespace System.Management.Automation.Language
using namespace System.Diagnostics.CodeAnalysis

[SuppressMessageAttribute(
    'PSUseDeclaredVarsMoreThanAssignments', '',
    Target        = '^(analysis|datadirectory|rule|doc)$',
    Justification = 'Used inside test scope'
    )]

param()
BeforeDiscovery {
    if (Get-Module 'TestHelpers') {
        $sourceFile = Get-SourceFilePath $PSCommandPath
    } else {
        throw 'TestHelpers module is not loaded'
    }
    if (-not (Test-Path $sourceFile)) {
        throw "Could not find $sourceFile from $PSCommandPath"
    }
    $analyzerRules = Get-ScriptAnalyzerRule -Severity Error, Warning
    | Where-Object {
        $_.RuleName -notmatch '(^PSDSC)|Manifest'
    }
    $analysis = Invoke-ScriptAnalyzer -Path $sourceFile -IncludeRule $analyzerRules
}

BeforeAll {
    $dataDirectory = Get-TestDataPath $PSCommandPath
}

$options = @{
    Name = 'GIVEN the public function Import-Markdown'
    Tag  = @(
        'unit',
        'Import-Markdown'
    )
    Foreach = $sourceFile
}
Describe @options {
    BeforeAll {
        $sourceFile = $_
        Write-Debug "Testing Source file $sourceFile"
    }
    Context 'WHEN The function is sourced in the current environment' {
        BeforeAll {
            $tokens      = $null
            $parseErrors = $null
            [Parser]::ParseFile($sourceFile, [ref]$tokens, [ref]$parseErrors)
        }

        It 'THEN it should parse without error' {
            $parseErrors | Should -BeNullOrEmpty
        }
        It 'THEN it should load without error' {
            (Get-Command 'Import-Markdown') | Should -Not -BeNullOrEmpty
        }
    }

    Context 'WHEN the <rule.RuleName> rule is tested' -ForEach $analyzerRules {
        BeforeAll {
            # Rename automatic variable to rule to make it easier to work with
            $rule = $_
        }

        It 'THEN it should pass' {
            $analysis | Should -Pass $rule
        }
    }
    Context 'Given a file with valid markdown content' {
        BeforeAll {
            $markdownFile = (Join-Path $dataDirectory 'readme.md')
            $doc = Import-Markdown -Path $markdownFile
        }

        Context 'When the content is parsed by the importer' {

            It 'Then it should be a Markdig MarkdownDocument' {
                $doc.GetType()
                | Select-Object -ExpandProperty FullName
                | Should -BeLike 'Markdig.Syntax.MarkdownDocument'
            }

            It 'Then it should have a YAML frontmatter section' {
                $doc[0].GetType()
                | Select-Object -ExpandProperty FullName
                | Should -Be 'Markdig.Extensions.Yaml.YamlFrontMatterBlock'
            }
        }
    }
}
