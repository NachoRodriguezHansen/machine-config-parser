param (
    [Parameter(Mandatory = $false)]
    [string[]]$SeriesPrefixes = @('W5xx'),   # Now supports multiple series
    [switch]$SkipConvert                       # Optional flag to skip XML → CSV/JSON conversions
)

# --- Reload utilities modules automatically ---
$modules = @(
    ".\utilities\Convert-Xml.psm1",
    ".\utilities\Find-Directories.psm1",
    ".\utilities\Get-Timestamp.psm1",
    ".\utilities\Get-SeriesInfo.psm1",
    ".\utilities\Get-MachineDataFromDirectories.psm1"
)

foreach ($modulePath in $modules) {
    $moduleName = [System.IO.Path]::GetFileNameWithoutExtension($modulePath)

    # Remove old version if already loaded
    if (Get-Module $moduleName) {
        Remove-Module $moduleName -Force -ErrorAction SilentlyContinue
    }

    # Import fresh version from disk
    Import-Module $modulePath -Force -ErrorAction Stop
    Write-Host "Reloaded module '$moduleName'" -ForegroundColor DarkGray
}
# ------------------------------------------------

try {
    $outDir = Join-Path $PSScriptRoot "outfiles"
    if (-not (Test-Path $outDir)) { 
        New-Item $outDir -ItemType Directory -Force | Out-Null 
    }

    foreach ($SeriesPrefix in $SeriesPrefixes) {
        Write-Host "--------------------------------------------" -ForegroundColor DarkGray
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

        Process-Directories -FoundDirectories $foundDirs -OutputDirectory $outDir -SeriesInfo $seriesInfo

        $xmlPath = Join-Path $outDir $seriesInfo.OutFileName

        if (-not $SkipConvert) {
            $csvPath = [System.IO.Path]::ChangeExtension($xmlPath, ".csv")
            $jsonPath = [System.IO.Path]::ChangeExtension($xmlPath, ".json")

            Write-Host "$(Get-Timestamp) Starting conversions..." -ForegroundColor DarkGray

            # XML → CSV
            Convert-XmlToCsv -XmlPath $xmlPath -CsvPath $csvPath

            # XML → JSON
            Convert-XmlToJson -XmlPath $xmlPath -JsonPath $jsonPath

            Write-Host "$(Get-Timestamp) Conversion complete for '$SeriesPrefix'." -ForegroundColor Yellow
        }
        else {
            Write-Host "$(Get-Timestamp) Skipping conversion for '$SeriesPrefix'." -ForegroundColor DarkYellow
        }
    }

    Write-Host "--------------------------------------------" -ForegroundColor DarkGray
    Write-Host "$(Get-Timestamp) All series processed successfully." -ForegroundColor Green
}
catch {
    Write-Host "$(Get-Timestamp) ERROR: $_" -ForegroundColor Red
}
