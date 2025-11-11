function GetSeriesInfo {
    <#
    .SYNOPSIS
    Retrieves information (Regex pattern and CSP files) based on the specified series prefix.

    .DESCRIPTION
    This function returns the Regex pattern and list of CSP files corresponding to the specified series prefix.

    .PARAMETER SeriesPrefix
    Specifies the series prefix (e.g., 'W5xx' or 'T30x').

    .EXAMPLE
    GetSerieInfo -SeriesPrefix "W5xx"
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, HelpMessage = "Specify the series prefix (e.g., 'W5xx' or 'T30x').")]
        [string]$SeriesPrefix
    )

    switch ($SeriesPrefix) {
        "W5xx" {
            $RepositoryPath = "\\muwo-file1\ST-Data2\masch.abl\W5xx_03"
            $RegexPattern = "^W5\d{2}_\d{6}$"
            $CspFiles = @(
                "ControlUnit\0_MetaDataProject.csp",
                "ControlUnit\1_MachineConfiguration.csp",
                "ControlUnit\2_StationSelection.csp",
                "ControlUnit\3_StationConfiguration.csp",
                "ControlUnit\6_SafetyConfiguration.csp"
            )
            $MuConfigFile = "ControlUnit\MU_Config.TcGVL"
            $OutFileName = "W5xx_machines_v00.xml"
        }
        "T30x" {
            $RepositoryPath = "\\muwo-file1\ST-Data2\masch.abl\T30x_03"
            $RegexPattern = "^T30\d{1}_\d{6}$"
            $CspFiles = @(
                "ControlUnit\0_MetaDataProject.csp",
                "ControlUnit\1_MachineConfiguration.csp"
            )
            $MuConfigFile = "ControlUnit\MU_CONFIG.EXP"
            $OutFileName = "T30x_machines_v00.xml"
        }
        "TX6xx" {
            $RepositoryPath = "\\muwo-file1\ST-Data2\masch.abl\TX6xx_03"
            $RegexPattern = "^TX6\d{2}_\d{6}$"
            $CspFiles = @(
                "ControlUnit\1_MachineConfiguration.csp"
            )
            $MuConfigFile = "ControlUnit\MU_Config.TcGVL"
            $OutFileName = "TX6xx_machines_v00.xml"
        }
        default {
            Write-Error "Invalid series prefix. Supported prefixes are 'W5xx', 'T30x' & 'TX6xx'."
            return
        }
    }

    return @{
        SeriesPrefix   = $SeriesPrefix
        RepositoryPath = $RepositoryPath
        RegexPattern   = $RegexPattern
        CspFiles       = $CspFiles
        MuConfigFile   = $MuConfigFile
        OutFileName    = $OutFileName
    }
}