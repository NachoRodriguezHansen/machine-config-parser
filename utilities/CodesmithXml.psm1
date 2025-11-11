# #####
function Get-CodeSmith-ElementList {
    param (
        [Parameter(Mandatory = $true, HelpMessage = "Specify the folder where the XML file is located.")]
        [System.IO.FileSystemInfo]$folder,
        [Parameter(Mandatory = $true, HelpMessage = "Specify the name of the XML file.")]
        [string]$file,
        [Parameter(Mandatory = $true, HelpMessage = "Specify the name of the node to search for in the XML.")]
        [string]$node
    )
    
    WriteHostWithTimestamp "Get $file element list" -MessageForegroundColorColor Cyan
    $fileLocation = Join-Path -Path $folder.FullName -ChildPath "ControlUnit\$file"
    
    if (-not $fileLocation) {
        WriteHostWithTimestamp "File not found: $($folder.FullName)\$file"
        return $null
    }
    
    $xmlDocument = New-Object System.Xml.XmlDocument
    $xmlDocument.Load($fileLocation)
    $cs = @{cs = "http://www.codesmithtools.com/schema/csp.xsd" }
    $nodeList = Select-Xml -xml $xmlDocument -Namespace $cs  -XPath "//cs:$node"
    
    return $nodeList.Node
}

# #####
function Create-Xml-W1 {
    param (
        [System.Array]$folders
    )

    WriteHostWithTimestamp "Creating xml w1..."

    # Create xml object
    $xmlDocument = New-Object System.Xml.XmlDocument
    $xmlDeclaration = $xmlDocument.CreateXmlDeclaration("1.0", "UTF-8", $null)
    $xmlDocument.AppendChild($xmlDeclaration)

    # Create and append root element "Repository"
    $repository = $xmlDocument.CreateElement("repository")
    $xmlDocument.AppendChild($repository)

    $iterator = 1

    # Create XML structure for machines and attributes
    foreach ($folder in $foundFolders) {
        
        WriteHostWithTimestamp "From $($folder.Name) [$iterator of $($foundFolders.Count)]"

        # Get and add properties from '*.csp' files
        $properties_csp_0 = Get-CodeSmith-ElementList -Folder $folder -File "0_MetaDataProject.csp" -Node "property"
        $properties_csp_1 = Get-CodeSmith-ElementList -Folder $folder -File "1_MachineConfiguration.csp" -Node "property"
        $properties_csp_2 = Get-CodeSmith-ElementList -Folder $folder -File "2_StationSelection.csp" -Node "property"
        $properties_csp_3 = Get-CodeSmith-ElementList -Folder $folder -File "3_StationConfiguration.csp" -Node "property"
        $properties_csp_6 = Get-CodeSmith-ElementList -Folder $folder -File "6_SafetyConfiguration.csp" -Node "property"

        # Get folder information
        $str = $folder.Name.Split("_")
        $type = $str[0]
        $sn = $str[1]

        <# NEW ---------------------------------------------- #>
        $filePath = $folder.FullName + "\ControlUnit\MU_Config.TcGVL"
        $searchString = "HMICFGgszProgramVersion"
        $lineContainingVersion = Get-Content -Path $filePath | Where-Object { $_ -match $searchString }
        $versionRegex = "'(.*?)'"
        $swv = [regex]::Match($lineContainingVersion, $versionRegex).Groups[1].Value
        <# NEW ---------------------------------------------- #>

        # Create child element 'machine' and set attributes
        $machine = $xmlDocument.CreateElement("machine")
        $machine.SetAttribute("TYPE", $type)
        $machine.SetAttribute("SN", $sn)
        $machine.SetAttribute("SW_VERSION", $swv)
        
        #
        foreach ($property in $properties_csp_0) {
            $machine.SetAttribute($property.GetAttribute('name'), $property.InnerText)
        }

        #
        foreach ($property in $properties_csp_1) {
            $machine.SetAttribute($property.GetAttribute('name'), $property.InnerText)
        }

        #
        foreach ($property in $properties_csp_2) {
            $machine.SetAttribute($property.GetAttribute('name'), $property.InnerText)
        }
        
        #
        foreach ($property in $properties_csp_3) {
            $machine.SetAttribute($property.GetAttribute('name'), $property.InnerText)
        }

        #
        foreach ($property in $properties_csp_6) {
            $machine.SetAttribute($property.GetAttribute('name'), $property.InnerText)
        }

        # Add the 'machine' element to the XML document
        $repository.AppendChild($machine)
        $iterator ++
    }
    #
    $scriptDirectory = $PSScriptRoot
    $xmlPath = Join-Path -Path $scriptDirectory -ChildPath "repository_w1.xml"
    $xmlDocument.Save($xmlPath)
    WriteHostWithTimestamp "repository_w1.xml document saved to: $xmlPath"

}

# #####
function Create-Xml-W2 {
    param (
        [System.Array]$folders
    )

    WriteHostWithTimestamp "Creating xml w2..."

    # Create xml object
    $xmlDocument = New-Object System.Xml.XmlDocument
    $xmlDeclaration = $xmlDocument.CreateXmlDeclaration("1.0", "UTF-8", $null)
    $xmlDocument.AppendChild($xmlDeclaration)

    # Create and append root element "Repository"
    $repository = $xmlDocument.CreateElement("repository")
    $xmlDocument.AppendChild($repository)

    $iterator = 1

    # Create XML structure for machines and attributes
    foreach ($folder in $foundFolders) {
    
        WriteHostWithTimestamp "From $($folder.Name) [$iterator of $($foundFolders.Count)]"

        # Get folder information
        $str = $folder.Name.Split("_")
        $type = $str[0]
        $sn = $str[1]

        <# NEW ---------------------------------------------- #>
        $filePath = $folder.FullName + "\ControlUnit\MU_Config.TcGVL"
        $searchString = "HMICFGgszProgramVersion"
        $lineContainingVersion = Get-Content -Path $filePath | Where-Object { $_ -match $searchString }
        $versionRegex = "'(.*?)'"
        $swv = [regex]::Match($lineContainingVersion, $versionRegex).Groups[1].Value
        <# NEW ---------------------------------------------- #>

        # Create the 'machine' element and set attributes
        $machine = $xmlDocument.CreateElement("machine")

        # Add the 'machine' element to the XML document
        $repository.AppendChild($machine)
        $machine.SetAttribute("TYPE", $type)
        $machine.SetAttribute("SN", $sn)
        $machine.SetAttribute("SW_VERSION", $swv)

        # Get and add properties from '*.csp' files
        $properties_csp_0 = Get-CodeSmith-ElementList -Folder $folder -File "0_MetaDataProject.csp" -Node "property"
        $properties_csp_1 = Get-CodeSmith-ElementList -Folder $folder -File "1_MachineConfiguration.csp" -Node "property"
        $properties_csp_2 = Get-CodeSmith-ElementList -Folder $folder -File "2_StationSelection.csp" -Node "property"
        $properties_csp_3 = Get-CodeSmith-ElementList -Folder $folder -File "3_StationConfiguration.csp" -Node "property"
        $properties_csp_6 = Get-CodeSmith-ElementList -Folder $folder -File "6_SafetyConfiguration.csp" -Node "property"

        #
        foreach ($_property in $properties_csp_0) {
            $property = $xmlDocument.CreateElement("property")
            $property.SetAttribute("name", $_property.GetAttribute('name'))
            $property.InnerText = $_property.InnerText
            $machine.AppendChild($property)
        }

        #
        foreach ($_property in $properties_csp_1) {
            $property = $xmlDocument.CreateElement("property")
            $property.SetAttribute("name", $_property.GetAttribute('name'))
            $property.InnerText = $_property.InnerText
            $machine.AppendChild($property)
        }

        #
        foreach ($_property in $properties_csp_2) {
            $property = $xmlDocument.CreateElement("property")
            $property.SetAttribute("name", $_property.GetAttribute('name'))
            $property.InnerText = $_property.InnerText
            $machine.AppendChild($property)
        }

        #
        foreach ($_property in $properties_csp_3) {
            $property = $xmlDocument.CreateElement("property")
            $property.SetAttribute("name", $_property.GetAttribute('name'))
            $property.InnerText = $_property.InnerText
            $machine.AppendChild($property)
        }

        #
        foreach ($_property in $properties_csp_6) {
            $property = $xmlDocument.CreateElement("property")
            $property.SetAttribute("name", $_property.GetAttribute('name'))
            $property.InnerText = $_property.InnerText
            $machine.AppendChild($property)
        }
        
        $iterator ++
    }
    #
    $scriptDirectory = $PSScriptRoot
    $xmlPath = Join-Path -Path $scriptDirectory -ChildPath "repository_w2.xml"
    $xmlDocument.Save($xmlPath)
    WriteHostWithTimestamp "repository_w2.xml document saved to: $xmlPath"
}
