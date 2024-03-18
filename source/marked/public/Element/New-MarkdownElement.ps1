function New-MarkdownElement {
    [CmdletBinding()]
    param(
        # Text to parse into Markdown Element(s)
        [Parameter(
            ValueFromPipeline
        )]
        [string[]]$Element
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
        $collect = [string]''
    }
    process {
        $collect += $Element
    }
    end {
        try {
            $markdown = [Markdig.Markdown]::Parse($collect , (-not $IgnoreTrivia))
            Write-Debug "Markdown has $($markdown.Count) objects"
            Write-Output $markdown -NoEnumerate
        } catch {
            $PSCmdlet.ThrowTerminatingError($_)
        }
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
