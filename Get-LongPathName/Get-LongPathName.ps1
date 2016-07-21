Function Get-LongPathName {
<#   
.SYNOPSIS   
	Function to get file and folder names with long paths.

.DESCRIPTION
    This function requires Robocopy to be installed. Robocopy is used to recursively search through
    a folder structure to find file or folder names that have more than a certain number of characters.
    The function returns an object with three properties: FullPath,Type and FullPath.

.PARAMETER FolderPath 
	The path or paths which will be scanned for long path names

.PARAMETER MaxDepth
    Specifies the maximum depth for files and folders in a folder structure

.NOTES   
    Name: Get-LongPathName.ps1
    Version: 1.1
    Author: Jaap Brasser
    DateCreated: 2012-10-05
    DateUpdated: 2013-08-28
    Site: http://www.jaapbrasser.com

.LINK
    http://www.jaapbrasser.com

.EXAMPLE
	Get-LongPathName -FolderPath 'C:\Program Files'
	
.EXAMPLE
	"c:\test","C:\Deeppathtest" | Get-LongPathName -FolderPath $_ -MaxDepth 200 | ft PathLength,Type,FullPath -AutoSize
#>
param(
    [CmdletBinding()]
    [Parameter(
    Position=0, 
    Mandatory=$true, 
    ValueFromPipeline=$true,
    ValueFromPipelineByPropertyName=$true)]
    [string[]]
        $FolderPath,
    [ValidateRange(10,248)]
	[int16]
		$MaxDepth=248
)

    begin {
        if (!(Test-Path -Path $(Join-Path $env:SystemRoot 'System32\robocopy.exe'))) {
            write-warning "Robocopy not found, please install robocopy"
            return
        }
    }

    process {
        foreach ($Path in $FolderPath) {
            $RoboOutput = robocopy.exe $Path c:\doesnotexist /l /e /b /np /fp /njh /njs /r:0 /w:0
 
            $RoboOutput | Where-Object {$_} |
            ForEach-Object {
                $CurrentPath = ($_ -split '\s')[-1]
                if ($CurrentPath.Length -gt $MaxDepth) {
                    New-Object -TypeName PSCustomObject -Property @{
                        FullPath = $CurrentPath
                        PathLength = $CurrentPath.Length
                        Type = if ($CurrentPath.SubString($CurrentPath.Length-1,1) -eq '\') {
                                   'Folder'
                               } else {
                                   'File'
                               }
                    }
                }
            }
        }
    }
}