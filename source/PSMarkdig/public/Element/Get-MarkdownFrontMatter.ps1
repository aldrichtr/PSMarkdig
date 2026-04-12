
using namespace Markdig.Syntax

function Get-MarkdownFrontMatter {
    [CmdletBinding()]
    param(
        [Parameter(
            ValueFromPipeline
        )]
        [MarkdownObject]$Element,

        # Return the object as an ordered hashtable
        [Parameter(
        )]
        [switch]$Ordered
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
    process {
        $fm = Get-MarkdownDescendant -Element $Element -TypeName 'Markdig.Extensions.Yaml.YamlFrontMatterBlock'
        if ($null -ne $fm) {
            Write-Debug "Frontmatter: $($fm.GetType().FullName)"
            $yamlContent = $fm | Write-MarkdownElement
            if (-not ([string]::IsNullorEmpty($yamlContent))) {
                try {
                    $yaml = $yamlContent | ConvertFrom-Yaml -AllDocuments -Ordered:$Ordered
                } catch {
                    $PSCmdlet.ThrowTerminatingError($_)
                }
                $yaml | Write-Output
            } else {
                Write-Verbose "YAML content was empty"
            }
        } else {
            Write-Verbose "No YAML content found in Markdown"
        }
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }

}
