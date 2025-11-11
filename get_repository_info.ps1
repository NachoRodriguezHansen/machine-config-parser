param (
    [Parameter(Mandatory = $false, HelpMessage = "Specify the series identifier letter. Default is 'W5xx'.")]
    [string]$SeriesPrefix = 'W5xx'
    #[string]$SeriesPrefix = 'T30x'
)

try {
    # Import required modules
    Import-Module -Name ".\utilities\GetTimestamp.psm1"
    Import-Module -Name ".\utilities\FindDirectories.psm1"
    Import-Module -Name ".\utilities\GetSeriesInfo.psm1"
    Import-Module -Name ".\utilities\CodeSmith.psm1"

    # Define the output directory path
    $outFilesDirectoryPath = Join-Path -Path $PSScriptRoot -ChildPath "outfiles_1"

    # Check and create the output directory if it doesn't exist
    if (-not (Test-Path -Path $outFilesDirectoryPath -PathType Container)) {
        New-Item -Path $outFilesDirectoryPath -ItemType Directory -Force | Out-Null
    }

    # Get series information
    $seriesInfo = GetSeriesInfo -SeriesPrefix $SeriesPrefix

    Write-Host (GetTimestamp) -NoNewline; Write-Host " Checking repository path `"$($seriesInfo.RepositoryPath)`"..."

    # Check if the repository directory exists
    if (-not (Test-Path -Path $seriesInfo.RepositoryPath -PathType Container)) {
        throw [System.Exception]::new("Check repository path `"$($seriesInfo.RepositoryPath)`" failed.")
    }

    Write-Host (GetTimestamp) -NoNewline; Write-Host " Check repository path `"$($seriesInfo.RepositoryPath)`" succeeded." -ForegroundColor Green

    # Find directories matching the pattern
    $foundDirectories = FindDirectories -Path $seriesInfo.RepositoryPath -RegexPattern $seriesInfo.RegexPattern

    if (-not $foundDirectories -or $foundDirectories.Count -eq 0) {
        throw [System.Exception]::new("No directories found matching `"$($seriesInfo.RegexPattern)`".")
    }

    Write-Host (GetTimestamp) -NoNewline; Write-Host " Found $($foundDirectories.Count) directories matching `"$($seriesInfo.RegexPattern)`"." -ForegroundColor Green
    Write-Host (GetTimestamp) -NoNewline; Write-Host " Generating `"$($seriesInfo.OutFileName)`"."

    ProcessDirectories_00 -SeriesInfo $seriesInfo -FoundDirectories $foundDirectories -OutputDirectory $outFilesDirectoryPath

}
catch {
    Write-Host (GetTimestamp) -NoNewline; Write-Host " $_.Exception.Message" -ForegroundColor Red
}

# Pause to keep the console open
pause
