Import-Module -Name "$PSScriptRoot\Get-Timestamp.psm1"

function Get-CodeSmithNodes {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$FilePath,

        [string]$NodeName = "property"
    )

    if (-not (Test-Path $FilePath -PathType Leaf)) {
        Write-Warning "File not found: $FilePath"
        return @()
    }

    $xmlDoc = New-Object System.Xml.XmlDocument
    $xmlDoc.Load($FilePath)
    $ns = @{ cs = "http://www.codesmithtools.com/schema/csp.xsd" }
    $nodes = Select-Xml -Xml $xmlDoc -Namespace $ns -XPath "//cs:$NodeName"

    return $nodes.Node
}

function Get-FileNodes {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Path,

        [Parameter(Mandatory = $true)]
        [string[]]$Files
    )

    $NodeList = @()
    foreach ($file in $Files) {
        $filePath = Join-Path $Path $file
        $nodes = Get-CodeSmithNodes -FilePath $filePath
        if ($nodes) { $NodeList += $nodes }
        else { Write-Host "$(Get-Timestamp) File '$file' has no 'property' nodes." -ForegroundColor Gray }
    }
    return $NodeList
}

function Get-MachineDataFromDirectories {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [System.IO.DirectoryInfo[]]$FoundDirectories,

        [Parameter(Mandatory = $true)]
        [string]$OutputDirectory,

        [Parameter(Mandatory = $true)]
        [pscustomobject]$SeriesInfo
    )

    $xmlPath = Join-Path $OutputDirectory $SeriesInfo.OutFileName
    $xmlDoc = New-Object System.Xml.XmlDocument
    $xmlDoc.AppendChild($xmlDoc.CreateXmlDeclaration("1.0", "UTF-8", $null)) | Out-Null
    $repository = $xmlDoc.CreateElement("repository")
    $xmlDoc.AppendChild($repository) | Out-Null
    $xmlDoc.Save($xmlPath)

    $iterator = 1
    foreach ($dir in $FoundDirectories) {
        Write-Host "$(Get-Timestamp) Copying properties from $($dir.Name) [$iterator/$($FoundDirectories.Count)]"

        $type, $sn = $dir.Name.Split("_")
        $machine = $xmlDoc.CreateElement("machine")
        $machine.SetAttribute("TYPE", $type)
        $machine.SetAttribute("SN", $sn)

        # Leer versión software
        $muFile = Join-Path $dir.FullName $SeriesInfo.MuConfigFile
        if (Test-Path $muFile) {
            $line = Get-Content $muFile | Where-Object { $_ -match "HMICFGgszProgramVersion" }
            if ($line) {
                $swv = [regex]::Match($line, "'(.*?)'").Groups[1].Value
                $machine.SetAttribute("SW_VERSION", $swv)
            }
        }

        # Procesar CSP files
        foreach ($csp in $SeriesInfo.CspFiles) {
            $nodes = Get-FileNodes -Path $dir.FullName -Files @($csp)
            foreach ($node in $nodes) {
                $machine.SetAttribute($node.GetAttribute('name'), $node.InnerText)
                $xmlDoc.Save($xmlPath)
            }
        }

        $repository.AppendChild($machine) | Out-Null
        $xmlDoc.Save($xmlPath)
        $iterator++
    }

    # Guardar XML
    $xmlPath = Join-Path $OutputDirectory $SeriesInfo.OutFileName
    $xmlDoc.Save($xmlPath)
    Write-Host "$(Get-Timestamp) Saved '$xmlPath'."
}

Export-ModuleMember -Function Get-MachineDataFromDirectories
