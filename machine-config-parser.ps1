param (
    [Parameter(Mandatory = $false)]
    [string[]]$SeriesPrefixes = @('Wxxx'), # Now supports multiple series
    [switch]$ExportFormats,                # Optional flag to convert XML → CSV/JSON
    [switch]$ReloadModules,                # Optional switch to reload utility modules
    [switch]$Help
)

if ($Help) {
    Write-Host @"
machine-config-parser.ps1
=========================

Parses and analyzes machine configuration XML files to extract relevant attributes and version information.

Usage:
    .\machine-config-parser.ps1 [-SeriesPrefixes <string[]>] [-ExportFormats] [-Help]

Parameters:
    -SeriesPrefixes  Optional. Array of machine series prefixes to process (default: 'W5xx').
    -ExportFormats   Optional switch. If specified, converts the resulting XML to CSV and JSON.
    -ReloadModules   Optional switch. If specified, reloads utility modules (useful for debugging).
    -Help            Shows this help message.

Examples:
    .\machine-config-parser.ps1
        Runs the script for the default series prefix 'Wxxx'.

    .\machine-config-parser.ps1 -SeriesPrefixes W4xx W5xx
        Runs the script for all machines in the 'W4xx' and 'W5xx' series.

"@
    return
}

$modules = @(
    ".\utilities\Convert-Xml.psm1",
    ".\utilities\Find-Directories.psm1",
    ".\utilities\Get-Timestamp.psm1",
    ".\utilities\Get-SeriesInfo.psm1",
    ".\utilities\Get-MachineDataFromDirectories.psm1"
)

if ($ReloadModules) {
    foreach ($modulePath in $modules) {
        $moduleName = [System.IO.Path]::GetFileNameWithoutExtension($modulePath)

        if (Get-Module $moduleName) {
            Remove-Module $moduleName -Force -ErrorAction SilentlyContinue
        }

        Import-Module $modulePath -Force -ErrorAction Stop
        Write-Host "Reloaded module '$moduleName'" -ForegroundColor DarkGray
    }
}
else {
    foreach ($modulePath in $modules) {
        Import-Module $modulePath -Force -ErrorAction Stop
    }
}

Write-Host "----------------------------------------------------------------------------------------------------" -ForegroundColor DarkGray

function Get-Configuration {
    try {
        $outDir = Join-Path $PSScriptRoot "outfiles"
        if (-not (Test-Path $outDir)) { 
            New-Item $outDir -ItemType Directory -Force | Out-Null 
        }

        Write-Host "$(Get-Timestamp) Processing series prefix '$SeriesPrefix'..." -ForegroundColor Cyan

        $seriesInfo = Get-SeriesInfo -SeriesPrefix $SeriesPrefix

        Write-Host "$(Get-Timestamp) Checking repository path '$($seriesInfo.RepositoryPath)'..."
        if (-not (Test-Path $seriesInfo.RepositoryPath)) { 
            throw "Repository path not found: $($seriesInfo.RepositoryPath)" 
        }
        Write-Host "$(Get-Timestamp) Repository path exists." -ForegroundColor Green

        $foundDirs = Find-Directories -Path $seriesInfo.RepositoryPath -RegexPattern $seriesInfo.RegexPattern
        if (-not $foundDirs) { 
            throw "No directories found matching '$($seriesInfo.RegexPattern)'" 
        }

        Write-Host "$(Get-Timestamp) Found $($foundDirs.Count) directories matching pattern." -ForegroundColor Green
        Write-Host "$(Get-Timestamp) Generating '$($seriesInfo.OutFileName)'..."

        Get-MachineDataFromDirectories -FoundDirectories $foundDirs -OutputDirectory $outDir -SeriesInfo $seriesInfo

        $xmlPath = Join-Path $outDir $seriesInfo.OutFileName

        if ($ExportFormats) {
            $csvPath = [System.IO.Path]::ChangeExtension($xmlPath, ".csv")
            $jsonPath = [System.IO.Path]::ChangeExtension($xmlPath, ".json")

            Write-Host "$(Get-Timestamp) Starting conversions..." -ForegroundColor DarkGray

            Convert-XmlToCsv -XmlPath $xmlPath -CsvPath $csvPath

            Convert-XmlToJson -XmlPath $xmlPath -JsonPath $jsonPath

            Write-Host "$(Get-Timestamp) Conversion complete for '$SeriesPrefix'." -ForegroundColor Yellow
        }
        else {
            Write-Host "$(Get-Timestamp) Skipping conversion for '$SeriesPrefix'." -ForegroundColor DarkYellow
        }
    
        Write-Host "----------------------------------------------------------------------------------------------------" -ForegroundColor DarkGray
        
    }
    catch {
        Write-Host "$(Get-Timestamp) ERROR: $_" -ForegroundColor Red
    }
}

foreach ($SeriesPrefix in $SeriesPrefixes) {
    Get-Configuration 
}

Write-Host "$(Get-Timestamp) All series processed successfully." -ForegroundColor Green