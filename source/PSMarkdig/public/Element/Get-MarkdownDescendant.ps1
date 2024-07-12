
using namespace Markdig
using namespace Markdig.Extensions
using namespace Markdig.Syntax

function Get-MarkdownDescendant {
    [CmdletBinding()]
    [Alias('Get-MarkdownElement')]
    param(
        [Parameter(
            ValueFromPipeline,
            Position = 1
        )]
        [MarkdownObject]$Element,

        # The type of element to return
        [Parameter(
            Position = 0
        )]
        [string]$Type,

        # Return All elements/descendants
        [Parameter(
        )]
        [switch]$All
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
    process {
        <#------------------------------------------------------------------
        If there was a type given, get the descendants of that type using the
        static template method.  Otherwise, use the static method
        ------------------------------------------------------------------#>
        if ($All -or
        ([string]::IsNullOrEmpty($PSBoundParameters['Type']))) {
            Write-Debug "No Type given.  Return all elements"
            [MarkdownObjectExtensions]::Descendants($Element)
        } else {
            Write-Debug "$Type type given"
            #Check Type
            if ($Type -match '^Markdig') {
                # Type name is "fully qualified"
                $objectType = $Type -as [Type]
            } else {
                # try to determine the namespace
                $namespaces = @(
                    'Syntax',
                    'Extensions'
                )
                foreach ($namespace in $namespaces) {
                    $objectType = "Markdig.$namespace.$Type" -as [type]
                    if ($null -ne $objectType) {
                        Write-Debug "Resolved type $($objectType.Name)"
                        break
                    }

                }
            }
            if (-not $objectType) {
                throw "Type: '$Type' not found"
            }
            $methodDescendants = [MarkdownObjectExtensions].GetMethod('Descendants', 1, [MarkdownObject])
            $mdExtensionsType = [MarkdownObjectExtensions]
            $method = $methodDescendants.MakeGenericMethod($objectType)
            $method.Invoke($mdExtensionsType, @(,$Element)) | ForEach-Object {
                Write-Debug "This element is a $($_.GetType().FullName)"
                Write-Output $_ -NoEnumerate
            }
        }

    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
