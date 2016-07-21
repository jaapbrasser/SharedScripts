function Get-ZipFileProperties {
<#   
.SYNOPSIS   
Function to show detailed information about a zip archive

.DESCRIPTION 
This function provides the ability to display detailed information about a compressed archive. Information that this function retrieves are the number of files, folder, compression ratio, compressed size and uncompressed size.

.PARAMETER Path
This can be a single file name or an array of file names. This parameter supports the pipeline and can take input from other cmdlets such as Get-ChildItem

.NOTES   
Name: Get-ZipFileProperties
Author: Jaap Brasser
DateUpdated: 2015-10-06
Version: 1.0
Blog: http://www.jaapbrasser.com

.LINK
http://www.jaapbrasser.com

.EXAMPLE
. .\Get-ZipFileProperties.ps1

Description
-----------
This command dot sources the script to ensure the Get-ZipFileProperties function is available in your current PowerShell session

.EXAMPLE
Get-ChildItem -Filter *.zip | Get-ZipFileProperties

Description
-----------
Use Get-ChildItem to retrieve a list of zip files in the current folder and pipe it into the Get-ZipFileProperties function to retrieve information about these files

.EXAMPLE
Get-ZipFileProperties -Path C:\Users\JaapBrasser\Documents\Archive.zip

Description
-----------
The Get-ZipFileProperties function to retrieves information about Archive.zip
#>
    [cmdletbinding()]
    param (
        [Parameter(Mandatory=$true,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true,
            Position=0)]
        [Alias("FullName")]
        $Path
    )

    begin {
        try {
            Add-Type -Assembly 'System.IO.Compression.FileSystem'
        } catch {
            Write-Warning $_.exception.message
        }
    }

    process {
        foreach ($CurrentPath in $Path) {
            if ($CurrentPath.GetType().Name -eq 'FileInfo') {
                $CurrentPath = $CurrentPath.FullName
            }
            if (Test-Path -LiteralPath $CurrentPath) {
                try {
                    ([System.IO.Compression.ZipFile]::Open($CurrentPath,'Read')).Entries | ForEach-Object -Begin {
                        [long]$TotalFileSize = $null
                        [long]$TotalFiles = $null
                        [string[]]$ParentPath = $null
                        $TotalSize = (Get-Item -LiteralPath $CurrentPath).Length
                    } -Process {
                        $TotalFileSize += $_.Length
                        $TotalFiles++
                        $ParentPath += Split-Path $_.FullName
                    } -End {
                        New-Object -TypeName PSCustomObject -Property @{
                            FullName = $Path
                            CompressedSize = $TotalSize
                            Files = $TotalFiles
                            Folders = @($ParentPath | Select-Object -Unique).Count - 1
                            UnCompressedSize = $TotalFileSize
                            Ratio = "{0:P2}" -f ($TotalSize / $TotalFileSize)
                        }
                    }
                } catch {
                    Write-Warning "File '$CurrentPath' is corrupted or not an archive"
                }
            } else {
                Write-Warning "$CurrentPath, path not found"
            }
        }
    }

}