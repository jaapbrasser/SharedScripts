function New-ZeroFile {
<#
.SYNOPSIS
Creates an empty, zeroed out file

.DESCRIPTION 
This function serves as a wrapper for fsutil, and can be used to create an empty file to reserve disk space

.PARAMETER Path
The path and file name of the zero file that will be created

.PARAMETER FileSize
Specifies the size, in bytes,  of the file, 1KB / 1MB / 1GB / 1TB notatation can be used

.PARAMETER Force
Overwrites an existing file if the specified path already exists

.PARAMETER OutputObject
Returns the created file object so that this function can be used in a pipeline

.NOTES
Name:        New-ZeroFile
Author:      Jaap Brasser
DateCreated: 2017-01-26
DateUpdated: 2017-09-30
Version:     1.1.0
Blog:        http://www.jaapbrasser.com

.LINK
http://www.jaapbrasser.com

.EXAMPLE
New-ZeroFile -Path c:\temp\j2.file -FileSize 500mb

Description
-----------
Creates a 500MB file in C:\Temp named jb.file

.EXAMPLE
New-ZeroFile -Path c:\temp\jb2.file,c:\temp\jb3.file -FileSize 1gb -Verbose

Description
-----------
Creates two 1gb files in the C:\Temp folder: jb2.file and jb3.file and displays verbose information

.EXAMPLE
'c:\temp\jb4.file','c:\temp\jb5.file' | New-ZeroFile -FileSize 10mb -OutputObject -Force

Description
-----------
Creates two 10mb files in the C:\Temp folder: jb3.file and jb4.file. Overwriting existing files if they are there and displaying the created fileinfo objects
#>


    [CmdletBinding()]
    param(
        [Parameter(
            Mandatory=$true,
            ValueFromPipeline=$true
        )]
            [string[]] $Path,
        [Parameter(
            Mandatory=$true
        )]
        [alias('Size','FS')]
            [long]    $FileSize,
            [switch]  $Force,
            [switch]  $OutputObject
    )
    
    process {
        foreach ($CurrentPath in $Path) {
            if ((Test-Path -LiteralPath $CurrentPath) -and $Force) {
                Write-Verbose "Overwriting existing file '$CurrentPath'"
                Remove-Item -LiteralPath $CurrentPath -Force
                $null = fsutil.exe file createnew ""$CurrentPath"" $FileSize
                
                # Output object if file has been created and output object switch is set    
                if ($OutputObject) {
                    Get-Item -LiteralPath $CurrentPath
                }
            } elseif (Test-Path -LiteralPath $CurrentPath) {
                Write-Warning "The file '$CurrentPath' already exists, no action taken "
            } else {
                Write-Verbose "Creating new file '$CurrentPath'"
                $null = fsutil.exe file createnew ""$CurrentPath"" $FileSize

                # Output object if file has been created and output object switch is set    
                if ($OutputObject) {
                    Get-Item -LiteralPath $CurrentPath
                }
            }
        }
    }
}