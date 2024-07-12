
using namespace Markdig.Syntax
using namespace Markdig.Extensions.Yaml

function ConvertFrom-Markdig {
    <#
    .SYNOPSIS
        Convert the Markdig AST to PowerShell Objects
    #>
    [CmdletBinding()]
    param(
        # The MarkdigObject to convert
        [Parameter(
            ValueFromPipeline
        )]
        [MarkdownObject]$InputObject
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
        $baseCommandName = 'ConvertFrom-Markdig'
    }
    process {
        Write-Debug "Attempting to get type of object"
        $objectType = ($InputObject.GetType().Name)

        if (-not ([string]::IsNullorEmpty($objectType))) {
            Write-Debug "- $objectType found"
            $commandName = (@($baseCommandName, $objectType) -join '')
            Write-Debug "- Command to use is $commandName"
        } else {
            throw "Could not determine type of object given"
        }

        $cmd = Get-Command $commandName -ErrorAction SilentlyContinue

        if ($null -ne $cmd) {
            Write-Debug "Created command"
            try {
                Write-Debug "-- Invoking $commandName --"
                (& $cmd $InputObject)
            }
            catch {
                $message = "Error parsing content"
                $exceptionText = ( @($message, $_.ToString()) -join "`n")
                $thisException = [Exception]::new($exceptionText)
                $eRecord = New-Object System.Management.Automation.ErrorRecord -ArgumentList (
                    $thisException,
                    $null,  # errorId
                    $_.CategoryInfo.Category, # errorCategory
                    $null  # targetObject
                )
                $PSCmdlet.ThrowTerminatingError( $eRecord )
            }
        } else {
            Write-Error "No parser found for Markdig.Syntax.$objectType"
        }
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
