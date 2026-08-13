
function Convert-LineEndings {
  <#
    .SYNOPSIS
        Convert the line endings in the given file to "Windows" (CRLF) or "Unix" (LF)
    .DESCRIPTION
        `Convert-LineEndings` will convert all of the line endings in the given file to the type specified.  If
        'Windows' or 'CRLF' is given, all line endings will be '\r\n' and if 'Unix' or 'LF' is given all line
        endings will be '\n'

        'Unix' (LF) is the default
    .EXAMPLE
        Get-ChildItem . -Filter "*.txt" | Convert-LineEndings -LF

        Convert all txt files in the current directory to '\n'
    .NOTES
        WARNING! this can corrupt a binary file.
    #>
  [CmdletBinding(
    DefaultParameterSetName = 'Unix'
  )]
  param(
    # The file to be converted
    [Parameter(
      Position = 1,
      ValueFromPipeline,
      ValueFromPipelineByPropertyName
    )]
    [Alias('PSPath')]
    [string[]]$Path,

    # Convert line endings to 'Unix' (LF)
    [Parameter( ParameterSetName = 'Unix',
      Position = 0
    )]
    [switch]$LF,

    # Convert line endings to 'Unix' (LF)
    [Parameter( ParameterSetName = 'LF',
      Position = 0
    )]
    [switch]$Unix,

    # Convert line endings to 'Windows' (CRLF)
    [Parameter( ParameterSetName = 'CRLF',
      Position = 0
    )]
    [switch]$CRLF,

    # Convert line endings to 'Windows' (CRLF)
    [Parameter( ParameterSetName = 'Windows',
      Position = 0
    )]
    [switch]$Windows
  )
  begin {
    Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
  }
  process {
    $isLF = ($PSBoundParameters.ContainsKey('Unix') -or $PSBoundParameters.ContainsKey('LF'))
    $isCRLF = ($PSBoundParameters.ContainsKey('Windows') -or $PSBoundParameters.ContainsKey('CRLF'))

    foreach ($file in $Path) {
      if ($isCRLF) {
        Write-Verbose "  Converting line endings in $($file.Name) to 'CRLF'"
        # ! note that Get-Content without parameters strips line endings
        ((Get-Content $file) -join "`r`n") | Set-Content -NoNewline -Path $file
      } elseif ($isLF) {
        Write-Verbose "  Converting line endings in $($file.Name) to 'LF'"
        ((Get-Content $file) -join "`n") | Set-Content -NoNewline -Path $file
      } else {
        Write-Error "No EOL format specified.  Please use '-LF' or '-CRLF'"
      }
    }
  }
  end {
    Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
  }
}