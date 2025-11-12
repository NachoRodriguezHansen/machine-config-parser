Import-Module -Name ".\utilities\Get-Timestamp.psm1"

function Convert-XmlToHashtable {
    <#
    .SYNOPSIS
    Converts an XML file into a nested hashtable representation.

    .DESCRIPTION
    Recursively parses an XML document and builds a nested hashtable structure.
    Useful as a common step before exporting to CSV or JSON.

    .PARAMETER XmlPath
    Path to the XML file.

    .EXAMPLE
    Convert-XmlToHashtable -XmlPath "C:\Data\machines.xml"
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$XmlPath
    )

    if (-not (Test-Path -Path $XmlPath -PathType Leaf)) {
        Write-Host (Get-Timestamp) -NoNewline
        Write-Host " XML file not found at '$XmlPath'." -ForegroundColor Red
        return $null
    }

    try {
        $xml = [xml](Get-Content -Path $XmlPath -Raw)
    }
    catch {
        Write-Host (Get-Timestamp) -NoNewline
        Write-Host " Failed to parse XML: $_" -ForegroundColor Red
        return $null
    }

    function ConvertNode($node) {
        $hash = @{}
        foreach ($attribute in $node.Attributes) {
            $hash[$attribute.Name] = $attribute.Value
        }
        foreach ($child in $node.ChildNodes) {
            if ($child.NodeType -eq 'Element') {
                if ($hash.ContainsKey($child.Name)) {
                    if (-not ($hash[$child.Name] -is [System.Collections.IList])) {
                        $hash[$child.Name] = @($hash[$child.Name])
                    }
                    $hash[$child.Name] += , (ConvertNode $child)
                }
                else {
                    $hash[$child.Name] = ConvertNode $child
                }
            }
        }
        return $hash
    }

    return ConvertNode $xml.DocumentElement
}

function Convert-XmlToCsv {
    <#
    .SYNOPSIS
    Converts XML machine data into a CSV file.

    .DESCRIPTION
    Parses the given XML, flattens attributes under <machine> elements, and exports them to CSV.

    .PARAMETER XmlPath
    Path to the source XML file.

    .PARAMETER CsvPath
    Output path for the CSV file.

    .EXAMPLE
    Convert-XmlToCsv -XmlPath "C:\data\machines.xml" -CsvPath "C:\data\machines.csv"
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$XmlPath,

        [Parameter(Mandatory = $true)]
        [string]$CsvPath
    )

    if (-not (Test-Path $XmlPath)) {
        Write-Host (Get-Timestamp) -NoNewline
        Write-Host " XML not found at '$XmlPath'." -ForegroundColor Red
        return
    }

    [xml]$xml = Get-Content -Path $XmlPath
    $machines = $xml.repository.machine

    if (-not $machines) {
        Write-Host (Get-Timestamp) -NoNewline
        Write-Host " No <machine> nodes found in XML." -ForegroundColor Yellow
        return
    }

    $data = foreach ($machine in $machines) {
        $obj = @{}
        foreach ($attr in $machine.Attributes) {
            $obj[$attr.Name] = $attr.Value
        }
        [PSCustomObject]$obj
    }

    $data | Export-Csv -Path $CsvPath -NoTypeInformation -Force
    Write-Host (Get-Timestamp) -NoNewline
    Write-Host " Saved CSV: $CsvPath" -ForegroundColor Green
}

function Convert-XmlToJson {
    <#
    .SYNOPSIS
    Converts an XML file into a JSON file.

    .DESCRIPTION
    Loads an XML file, converts it into a nested hashtable, and exports it to JSON format.

    .PARAMETER XmlPath
    Path to the XML file.

    .PARAMETER JsonPath
    Output path for the JSON file.

    .EXAMPLE
    Convert-XmlToJson -XmlPath "C:\data\machines.xml" -JsonPath "C:\data\machines.json"
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$XmlPath,

        [Parameter(Mandatory = $true)]
        [string]$JsonPath
    )

    $data = Convert-XmlToHashtable -XmlPath $XmlPath
    if ($null -eq $data) { return }

    $json = $data | ConvertTo-Json -Depth 10
    $json | Out-File -FilePath $JsonPath -Encoding UTF8

    Write-Host (Get-Timestamp) -NoNewline
    Write-Host " Saved JSON: $JsonPath" -ForegroundColor Green
}

Export-ModuleMember -Function Convert-XmlToCsv, Convert-XmlToJson, Convert-XmlToHashtable
