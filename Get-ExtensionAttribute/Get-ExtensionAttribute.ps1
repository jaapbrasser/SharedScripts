function Get-ExtensionAttribute {
<#
.Synopsis
Retrieves extension attributes from files or folder

.DESCRIPTION
Uses the dynamically generated parameter -ExtensionAttribute to select one or multiple extension attributes and display the attribute(s) along with the FullName attribute

.NOTES   
Name: Get-ExtensionAttribute.ps1
Author: Jaap Brasser
Version: 1.0
DateCreated: 2015-03-30
DateUpdated: 2015-03-30
Blog: http://www.jaapbrasser.com

.LINK
http://www.jaapbrasser.com

.PARAMETER FullName
The path to the file or folder of which the attributes should be retrieved. Can take input from pipeline and multiple values are accepted.

.PARAMETER ExtensionAttribute
Additional values to be loaded from the registry. Can contain a string or an array of string that will be attempted to retrieve from the registry for each program entry

.EXAMPLE   
. .\Get-ExtensionAttribute.ps1
    
Description 
-----------     
This command dot sources the script to ensure the Get-ExtensionAttribute function is available in your current PowerShell session

.EXAMPLE
Get-ExtensionAttribute -FullName C:\Music -ExtensionAttribute Size,Length,Bitrate

Description
-----------
Retrieves the Size,Length,Bitrate and FullName of the contents of the C:\Music folder, non recursively

.EXAMPLE
Get-ExtensionAttribute -FullName C:\Music\Song2.mp3,C:\Music\Song.mp3 -ExtensionAttribute Size,Length,Bitrate

Description
-----------
Retrieves the Size,Length,Bitrate and FullName of Song.mp3 and Song2.mp3 in the C:\Music folder

.EXAMPLE
Get-ChildItem -Recurse C:\Video | Get-ExtensionAttribute -ExtensionAttribute Size,Length,Bitrate,Totalbitrate

Description
-----------
Uses the Get-ChildItem cmdlet to provide input to the Get-ExtensionAttribute function and retrieves selected attributes for the C:\Videos folder recursively

.EXAMPLE
Get-ChildItem -Recurse C:\Music | Select-Object FullName,Length,@{Name = 'Bitrate' ; Expression = { Get-ExtensionAttribute -FullName $_.FullName -ExtensionAttribute Bitrate | Select-Object -ExpandProperty Bitrate } }

Description
-----------
Combines the output from Get-ChildItem with the Get-ExtensionAttribute function, selecting the FullName and Length properties from Get-ChildItem with the ExtensionAttribute Bitrate
#>
    [CmdletBinding()]
    Param (
        [Parameter(ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true,
            Position=0)]
        [string[]]
            $FullName
    )
    DynamicParam
    {
        $Attributes = new-object System.Management.Automation.ParameterAttribute
        $Attributes.ParameterSetName = "__AllParameterSets"
        $Attributes.Mandatory = $false
        $AttributeCollection = New-Object -Type System.Collections.ObjectModel.Collection[System.Attribute]
        $AttributeCollection.Add($Attributes)
        $Values = @($Com=(New-Object -ComObject Shell.Application).NameSpace('C:\');1..400 | ForEach-Object {$com.GetDetailsOf($com.Items,$_)} | Where-Object {$_} | ForEach-Object {$_ -replace '\s'})
        $AttributeValues = New-Object System.Management.Automation.ValidateSetAttribute($Values)
        $AttributeCollection.Add($AttributeValues)
        $DynParam1 = New-Object -Type System.Management.Automation.RuntimeDefinedParameter("ExtensionAttribute", [string[]], $AttributeCollection)
        $ParamDictionary = New-Object -Type System.Management.Automation.RuntimeDefinedParameterDictionary
        $ParamDictionary.Add("ExtensionAttribute", $DynParam1)
        $ParamDictionary
    }

    begin {
        $ShellObject = New-Object -ComObject Shell.Application
        $DefaultName = $ShellObject.NameSpace('C:\')
        $ExtList = 0..400 | ForEach-Object {
            ($DefaultName.GetDetailsOf($DefaultName.Items,$_)).ToUpper().Replace(' ','')
        }
    }

    process {
        foreach ($Object in $FullName) {
            # Check if there is a fullname attribute, in case pipeline from Get-ChildItem is used
            if ($Object.FullName) {
                $Object = $Object.FullName
            }

            # Check if the path is a single file or a folder
            if (-not (Test-Path -Path $Object -PathType Container)) {
                $CurrentNameSpace = $ShellObject.NameSpace($(Split-Path -Path $Object))
                $CurrentNameSpace.Items() | Where-Object {
                    $_.Path -eq $Object
                } | ForEach-Object {
                    $HashProperties = @{
                        FullName = $_.Path
                    }
                    foreach ($Attribute in $MyInvocation.BoundParameters.ExtensionAttribute) {
                        $HashProperties.$($Attribute) = $CurrentNameSpace.GetDetailsOf($_,$($ExtList.IndexOf($Attribute.ToUpper())))
                    }
                    New-Object -TypeName PSCustomObject -Property $HashProperties
                }
            } elseif (-not $input) {
                $CurrentNameSpace = $ShellObject.NameSpace($Object)
                $CurrentNameSpace.Items() | ForEach-Object {
                    $HashProperties = @{
                        FullName = $_.Path
                    }
                    foreach ($Attribute in $MyInvocation.BoundParameters.ExtensionAttribute) {
                        $HashProperties.$($Attribute) = $CurrentNameSpace.GetDetailsOf($_,$($ExtList.IndexOf($Attribute.ToUpper())))
                    }
                    New-Object -TypeName PSCustomObject -Property $HashProperties
                }
            }
        }
    }

    end {
        Remove-Variable -Force -Name DefaultName
        Remove-Variable -Force -Name CurrentNameSpace
        Remove-Variable -Force -Name ShellObject
    }
}