function FindDirectories {
    <#
    .SYNOPSIS
    Finds directories in the specified path matching the provided regular expression pattern.

    .DESCRIPTION
    This function searches for directories within the specified path that match the provided regular expression pattern.

    .PARAMETER Path
    Specifies the path where you want to search for directories.

    .PARAMETER RegexPattern
    Specifies the regular expression pattern to match directory names against.

    .EXAMPLE
    "C:\Some\Path" | Find-Directories -RegexPattern "^W5\d{2}_\d{6}$"
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, HelpMessage = "Specify the path where you want to search for directories.")]
        [string]$Path,

        [Parameter(Mandatory = $true, HelpMessage = "Specify the regular expression pattern to match directory names against.")]
        [string]$RegexPattern
    )
    
    if (-not (Test-Path -Path $Path -PathType Container)) {
        return $null
    }
    else {
        return Get-ChildItem -Path $Path -Directory | Where-Object { $_.Name -match $RegexPattern }
    }
}