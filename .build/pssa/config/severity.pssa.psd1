@{
    #-------------------------------------------------------------------------------
    #region Severity
    Severity = @(
        # Information: 0 This warning is trivial, but may be useful. They are recommended by PowerShell best practice.
        'Information'
        # Warning:     1 This warning may cause a problem or does not follow PowerShell's recommended guidelines.
        'Warning',
        # Error:       2 This warning is likely to cause a problem or does not follow PowerShell's required guidelines.
        'Error'
        # ParseError:  3 This diagnostic is caused by an actual parsing error, and is generated only by the engine.
        # ParseError   # Only used by the engine
    )
    #endregion Severity
    #-------------------------------------------------------------------------------
}
