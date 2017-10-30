function Get-TopFileExtensionSize {
<#   
.SYNOPSIS
Function to retrieve the largest files of a specific extension
    
.DESCRIPTION
This function retrieves the largest files of a specific extension and list the top X
	
.PARAMETER Extension
Which extensions will be listed

.PARAMETER FolderPath
The path of a folder or volume that should be enumerated

.PARAMETER TopFile
The top number of files to be displayed for each extension

.NOTES   
Name:        Get-TopFileExtensionSize
Author:      Jaap Brasser
DateCreated: 2017-10-30
Version:     1.0.0
Blog:        http://www.jaapbrasser.com

.LINK
http://www.jaapbrasser.com

.EXAMPLE
Get-TopFileExtensionSize -Extension 'txt,xml,log' -TopFile 5 -FolderPath C:\
    
Description 
-----------

#>


    param(
        $Extension = '${P_FileExtensions}',
        $FolderPath = '${Rtv_DriveLetter}\',
        $TopFile = '${P_DisplayTopFileExt}'
    )

    $ErrorActionPreference = 'SilentlyContinue'

    $Extension.Split(',') | ForEach-Object {
        Get-ChildItem $FolderPath -Include "*$_" -Recurse -Force |
        Sort-Object -Property Length -Descending | 
        Select-Object -First $TopFile -Property @{
            Name       = 'SizeMB'
            Expression = {
                [math]::Round($_.Length/1MB, 2)
            }
        }, Name, FullName
    } | Format-Table -AutoSize
}