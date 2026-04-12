
using namespace Markding.Syntax

function Add-MarkdownHeading {
    <#
    .SYNOPSIS
        Add a heading to the given markdown document
    #>
    [CmdletBinding(
        DefaultParameterSetName = 'AsObject'
    )]
    param(
        # The markdown heading to add
        [Parameter(
            ParameterSetName = 'AsObject',
            Position = 0
        )]
        [MarkdownObject]$Heading,

        # The heading to create and add
        [Parameter(
            ParameterSetName = 'AsString',
            Position = 0
        )]
        [string]$HeadingText,

        # The markdown document to add it to
        [Parameter(
            Mandatory,
            Position = 1,
            ValueFromPipeline
        )]
        [MarkdownObject]$Document,

        # The array index to add the header at
        [Parameter(
        )]
        [int]$Index
    )
    begin {}
    process {
        if ($PSBoundParameters.ContainsKey('HeadingText')) {
            Write-Debug 'Received text.  Converting to Markdig.HeadingBlock'
            try {
                $Heading = $HeadingText | ConvertTo-MarkdigObject -Pipeline (Get-MarkdigPipeline)
            } catch {
                $message = "Could not convert '$HeadingText' to a markdig heading"
                $exceptionText = ( @($message, $_.ToString()) -join "`n")
                $thisException = [Exception]::new($exceptionText)
                $eRecord = New-Object System.Management.Automation.ErrorRecord -ArgumentList (
                    $thisException,
                    $null, # errorId
                    $_.CategoryInfo.Category, # errorCategory
                    $null  # targetObject
                )
                $PSCmdlet.ThrowTerminatingError( $eRecord )
            }
        } elseif ($PSBoundParameters.ContainsKey('Heading')) {
            Write-Debug 'Received markdig object'
        } else {
            throw "No heading was given"
        }
        try {
            if ($null -ne $Heading) {
                if ($Heading -is [MarkdownDocument]) {
                    #! Markdig prohibits adding an element to a doc that already has a parent,
                    #! so we need to Insert the newly created document with the heading in it,
                    #! and then copy the heading out into the parent document, then delete the
                    #! original inserted document
                    Write-Debug "- Inserting markdowndocument into main document"
                    [void]$Document.Insert($Index, $Heading)
                    Write-Debug "$($Document | Show-MarkdigAst)"
                    Write-Debug "- Copying the heading out of the inserted document"
                    [void]$Document[($Index)].CopyTo($Document, ($Index + 1))
                    [void]$Document.Remove($Heading)
                }
            } else {
                throw 'No Heading was given'
            }
        } catch {
            $message = 'Could not add header'
            $exceptionText = ( @($message, $_.ToString()) -join "`n")
            $thisException = [Exception]::new($exceptionText)
            $eRecord = New-Object System.Management.Automation.ErrorRecord -ArgumentList (
                $thisException,
                $null, # errorId
                $_.CategoryInfo.Category, # errorCategory
                $null  # targetObject
            )
            $PSCmdlet.ThrowTerminatingError( $eRecord )
        }
    }
    end {}
}
