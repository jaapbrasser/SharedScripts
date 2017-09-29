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

.OTES   
Name:        New-ZeroFile
Author:      Jaap Brasser
DateCreated: 2017-01-26
DateUpdated: 2017-09-29
Version:     1.1.0
Blog:        http://www.jaapbrasser.com

.LINK
http://www.jaapbrasser.com

.EXAMPLE   
New-ZeroFile -Path c:\temp\jb2.file -FileSize 500mb

Description
-----------
Creates a 500MB file in C:\Temp named jb2.file
#>  

    param(
        [string] $Path,
        [alias('Size')]
        [long]   $FileSize,
        [switch] $Force
    )

    fsutil.exe file createnew ""$Path"" $FileSize
}