Import-Module -Name ".\utilities\GetTimestamp.psm1"

function GetNodes {
    <#
    .SYNOPSIS
    Retrieves XML nodes from a specified file based on the provided XPath expression.

    .DESCRIPTION
    This function loads an XML file and selects nodes based on the provided XPath expression. It returns the selected nodes.

    .PARAMETER FilePath
    Specifies the path to the XML file.

    .PARAMETER NodeName
    Specifies the name of the XML nodes to select. Default is "property".

    .EXAMPLE
    GetCodeSmithNodes -FilePath "C:\Path\To\File.xml" -NodeName "property"
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, HelpMessage = "Specify the path to the XML file.")]
        [string]$FilePath,

        [Parameter(Mandatory = $false, HelpMessage = "Specify the name of the XML nodes to select. Default is 'property'.")]
        [string]$NodeName = "property"
    )
    
    if (-not (Test-Path -Path $FilePath -PathType Leaf)) {
        return $null
    }
    else {
        # Load the XML document
        $xmlDocument = New-Object System.Xml.XmlDocument
        $xmlDocument.Load($FilePath)
        
        # Define namespace for XPath query
        $cs = @{cs = "http://www.codesmithtools.com/schema/csp.xsd" }

        # Select XML nodes based on XPath expression
        $selectedXmlNodes = Select-Xml -xml $xmlDocument -Namespace $cs -XPath "//cs:$NodeName"
        
        # Return the selected XML nodes
        return $selectedXmlNodes.Node
    }
}

function ProcessFiles {
    <#
    .SYNOPSIS
    Processes a list of files in a specified directory.

    .DESCRIPTION
    This function iterates over a list of files in a given directory, checks their existence,
    and extracts CodeSmith nodes from existing XML files. It returns an array containing
    all the extracted nodes.

    .PARAMETER Path
    Specifies the directory path where the files are located.

    .PARAMETER Files
    Specifies an array of filenames to be processed.

    .EXAMPLE
    $propertyArr = ProcessFiles -Path "C:\Some\Directory" -Files @("file1.xml", "file2.xml")
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, HelpMessage = "Specifies the directory path where the files are located.")]
        [string]$Path,

        [Parameter(Mandatory = $true, HelpMessage = "Specifies an array of filenames to be processed.")]
        [array]$Files
    )

    $nodesArr = @()

    foreach ($file in $Files) {

        $filePath = Join-Path -Path $Path -ChildPath $file

        if (-not (Test-Path -Path $filePath -PathType Leaf)) {
            Write-Host (GetTimestamp) -NoNewline; Write-Host "File `"$file`" not found at `"$Path`"."
        }
        else {
            $nodeName = "property"
            $cspNodes = GetNodes -FilePath $filePath -NodeName $nodeName
            if ($cspNodes -eq $null) {
                Write-Host (GetTimestamp) -NoNewline; Write-Host "File `"$file`" at `"$Path`" does not contain any node called `"$nodeName`"." -ForegroundColor Gray
            }
            else {
                $nodesArr += $cspNodes
            }
        }
    }
    
    return $nodesArr
}

function ProcessDirectories_00 {
    <#
    .SYNOPSIS
    Processes directories to generate an XML document with machine information.

    .DESCRIPTION
    This function takes a collection of directories and processes each to extract machine information,
    including checking for configuration files and extracting specific data. The processed information
    is then saved into an XML document.

    .PARAMETER foundDirectories
    Specifies the collection of directories to be processed.

    .PARAMETER outputDirectory
    Specifies the path where the XML document will be saved.

    .PARAMETER seriesInfo
    Provides series-specific information required for processing directories.

    .EXAMPLE
    $directories = Find-Directories -Path "C:\Repo" -RegexPattern "^W5\d{2}_\d{6}$"
    ProcessDirectories -foundDirectories $directories -outputDirectory "C:\OutFiles" -seriesInfo $seriesInfo
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, HelpMessage = "Specify the collection of directories to be processed.")]
        [System.Collections.ObjectModel.Collection[System.IO.DirectoryInfo]]$FoundDirectories,

        [Parameter(Mandatory = $true, HelpMessage = "Specify the path where the XML document will be saved.")]
        [string]$OutputDirectory,

        [Parameter(Mandatory = $true, HelpMessage = "Provide series-specific information required for processing directories.")]
        [pscustomobject]$SeriesInfo
    )

    # Create the XML document
    $xmlDocument = New-Object System.Xml.XmlDocument
    $xmlDeclaration = $xmlDocument.CreateXmlDeclaration("1.0", "UTF-8", $null)
    $xmlDocument.AppendChild($xmlDeclaration) | Out-Null
    $repository = $xmlDocument.CreateElement("repository")
    $xmlDocument.AppendChild($repository) | Out-Null

    # Process each found directory
    $iterator = 1
    foreach ($directory in $foundDirectories) {
        Write-Host (GetTimestamp) -NoNewline; Write-Host " Copying properties from $($directory.Name) [$iterator of $($foundDirectories.Count)]"

        $str = $directory.Name.Split("_")
        $type = $str[0]
        $sn = $str[1]

        $machine = $xmlDocument.CreateElement("machine")
        $machine.SetAttribute("TYPE", $type)
        $machine.SetAttribute("SN", $sn)

        # Check the existence of the config file
        $filePath = Join-Path -Path $directory.FullName -ChildPath $seriesInfo.MuConfigFile
        if (-not (Test-Path -Path $filePath)) {
            Write-Host (GetTimestamp) -NoNewline; Write-Host " File `"$($seriesInfo.MuConfigFile)`" not found at `"$($directory.FullName)`"."
        }
        else {
            $searchString = "HMICFGgszProgramVersion"
            $lineContainingVersion = Get-Content -Path $filePath | Where-Object { $_ -match $searchString }
            if ($lineContainingVersion) {
                $versionRegex = "'(.*?)'"
                $swv = [regex]::Match($lineContainingVersion, $versionRegex).Groups[1].Value
                $machine.SetAttribute("SW_VERSION", $swv)
            }
        }

        $nodesArr = ProcessFiles -Path $directory.FullName -Files $seriesInfo.CspFiles
        if ($nodesArr) {
            foreach ($node in $nodesArr) {
                $machine.SetAttribute($node.GetAttribute('name'), $node.InnerText)
            }
        }
        else {
            Write-Host (GetTimestamp) -NoNewline; Write-Host " No nodes were found at $($directory.FullName)."
        }

        # Add the 'machine' element to the XML document
        $repository.AppendChild($machine) | Out-Null
        $iterator++
    }

    # Save the XML document
    $xmlPath = Join-Path -Path $outputDirectory -ChildPath $seriesInfo.OutFileName
    $xmlDocument.Save($xmlPath)
    Write-Host (GetTimestamp) -NoNewline; Write-Host " Saved `"$xmlPath`"."
}

Export-ModuleMember -Function ProcessDirectories_00