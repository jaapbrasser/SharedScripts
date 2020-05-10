<#
.SYNOPSIS
Checks if home folder still has an enabled AD account and list size of the folder

.DESCRIPTION
This script queries AD with the name of the home folder. If this query does not result in an account or a disabled account the script will list the folder size with the folder path and error message. The script will output an array of PSObject which can be piped into various Format-* and Export-* Cmdlets.

.PARAMETER HomeFolderPath
This parameter determines which folder should be scanned. A list of all folders will be checked for matching samaccountnames in Active Directory. Any folders that do not have a name that matches a samaccount in AD or that match a disabled account are listed.

.PARAMETER ExcludePath
This parameter determines which folders should be excluded from scanning or moving. This is particularly useful in combination with move item to ensure certain folders are never moved or included in results. This parameter takes fullpath names and can be an array of fullpath names to be excluded.

.PARAMETER SearchBase
This parameter determines what the SearchBase for the AD query is, the LDAP path for an OU should be specified here. This can be used to limit the AD Query to a sub tree within Active Directory

.PARAMETER FolderSize
This parameter determines if the folder size should be retrieved for orphaned home folders. Not specifying this parameter will significantly increase speed of execution.

.PARAMETER MoveFolderPath
Specifying this parameter will move all orphaned folders to the specified folder.

.PARAMETER MoveDisabled
This switch parameter works in combination with the MoveFolderPath parameter, it will also move the homefolders of disabled accounts.

.PARAMETER DisplayAll
This switch parameters will force the script to also display enabled active directory accounts, can be used in combination with -FolderSize parameter.

.PARAMETER UseRobocopy
Setting this switch parameter will enable moving of home folders using Robocopy instead of Move-Item. This can be useful to prevent 'Path is too long' errors

.PARAMETER RegExExclude
Setting this switch parameter will handle the strings in the ExcludePath parameter as regular expressions that will be matched against the FullName property of the scanned folders

.PARAMETER CheckHomeDirectory
Setting this switch parameter will check the full path of the folder against the HomeDirectory attribute of an ADObject, when using this switch make sure that the correct shared folder or DFS path is used, otherwise output can be unreliable

.PARAMETER LastLogonDate
Switch parameter that will look at the most recent file change in the root folder and report this back

.NOTES   
Name: Get-OrphanHomeFolder.ps1
Author: Jaap Brasser
Version: 2.0
DateCreated: 2012-10-19
DateUpdated: 2020-05-10
Blog: http://www.jaapbrasser.com

.LINK
http://www.jaapbrasser.com

.EXAMPLE   
.\Get-OrphanHomeFolder.ps1 -HomeFolderPath \\Server01\Home -FolderSize

Description:
Will list all the folders in the \\Server01\Home path. For each of these folders it will query AD using the foldername, if the query does not return an AD account or a disabled AD account an error will be logged and the size of the folder will be reported

.EXAMPLE   
.\Get-OrphanHomeFolder.ps1 -HomeFolderPath \\Server01\Home -FolderSize -DisplayAll

Description:
Will list all the folders in the \\Server01\Home path. For each of these folders it will query AD using the foldername, regardless of the AD results folder size will be returned

.EXAMPLE   
.\Get-OrphanHomeFolder.ps1 -HomeFolderPath \\Server01\Home -SearchBase 'LDAP://OU=YourOU,DC=jaapbrasser,DC=com'

Description:
Will list all the folders in the \\Server01\Home path. For each of these folders it will query AD, only in the YourOU Organizational Unit of the JaapBrasser domain, using the foldername

.EXAMPLE   
.\Get-OrphanHomeFolder.ps1 -HomeFolderPath \\Server02\Fileshare\Home | Format-Table -AutoSize

Description:
Will list all the folders in the \\Server02\Fileshare\Home. Will wait until all folders are processed before piping the input into the Format-Table Cmdlet and displaying the results in the console.

.EXAMPLE   
.\Get-OrphanHomeFolder.ps1 -HomeFolderPath \\Server02\Fileshare\Home -MoveFolderPath \\Server03\Fileshare\MovedHomeFolders

Description:
Will list all the folders in the \\Server02\Fileshare\Home folder and will move orphaned folders to \\Server03\Fileshare\MovedHomeFolders while displaying results to console.

.EXAMPLE   
.\Get-OrphanHomeFolder.ps1 -HomeFolderPath \\Server02\Fileshare\Home -MoveFolderPath \\Server03\Fileshare\MovedHomeFolders -MoveDisabled

Description:
Will list all the folders in the \\Server02\Fileshare\Home folder and will move orphaned folders and folders that have disabled users accounts to \\Server03\Fileshare\MovedHomeFolders while displaying results to console.

.EXAMPLE   
.\Get-OrphanHomeFolder.ps1 -HomeFolderPath \\Server02\Fileshare\Home -MoveFolderPath \\Server03\Fileshare\MovedHomeFolders -ExcludePath \\Server02\Fileshare\Home\JBrasser,\\\\Server02\Fileshare\Home\MShajin -UseRobocopy

Description:
Will list all the folders in the \\Server02\Fileshare\Home folder and will move orphaned folders using robocopy, excluding JBrasser and MShajin, to \\Server03\Fileshare\MovedHomeFolders while displaying results to console

.EXAMPLE   
.\Get-OrphanHomeFolder.ps1 -HomeFolderPath \\Server02\Fileshare\Home -MoveFolderPath \\Server03\Fileshare\MovedHomeFolders -ExcludePath '\.v2$' -RegExExclude

Description:
Will list all the folders in the \\Server02\Fileshare\Home folder and will move orphaned folders using robocopy, excluding folders that end with .v2

.EXAMPLE   
.\Get-OrphanHomeFolder.ps1 -HomeFolderPath \\dfs\share\userfolders\ -CheckHomeDirectory

Description:
Will list all the folders in the \\Server02\Fileshare\Home folder and check against the homedirectory attribute of the AD objects
#>
param(
    [Parameter(Mandatory=$true)]
    $HomeFolderPath,
    $MoveFolderPath,
    $SearchBase,
    [string[]]$ExcludePath,
    [switch]$FolderSize,
    [switch]$MoveDisabled,
    [switch]$DisplayAll,
    [switch]$UseRobocopy,
    [switch]$RegExExclude,
    [switch]$CheckHomeDirectory,
    [switch]$LastLogonDate
)
# Check if HomeFolderPath is found, exit with warning message if path is incorrect
if (!(Test-Path -LiteralPath $HomeFolderPath)){
    Write-Warning "HomeFolderPath not found: $HomeFolderPath"
    exit
}

# Check if MoveFolderPath is found, exit with warning message if path is incorrect
if ($MoveFolderPath) {
    if (!(Test-Path -LiteralPath $MoveFolderPath)){
        Write-Warning "MoveFolderPath not found: $MoveFolderPath"
        exit
    }
}

# Main loop, for each folder found under home folder path AD is queried to find a matching samaccountname
$ListOfFolders = Get-ChildItem -LiteralPath "$HomeFolderPath" -Force | Where-Object {$_.PSIsContainer}

# Exclude folders if the ExcludePath parameter is given
if ($ExcludePath) {
    $ExcludePath | ForEach-Object {
        $CurrentExcludePath = $_
        if ($RegExExclude) {
            $ListOfFolders = $ListOfFolders | Where-Object {$_.FullName -notmatch $CurrentExcludePath}
        } else {
            $ListOfFolders = $ListOfFolders | Where-Object {$_.FullName -ne $CurrentExcludePath}
        }
    }
}

$ListOfFolders | ForEach-Object {
    $CurrentPath = Split-Path -Path $_ -Leaf

    # Construct AD Searcher, add SearchRoot attribute if SearchBase parameter is specified
    $ADSearcher = New-Object DirectoryServices.DirectorySearcher -Property @{
        Filter = "(samaccountname=$CurrentPath)"
    }
    if ($SearchBase) {
        $ADSearcher.SearchRoot = [adsi]$SearchBase
    }

    # Use the FullName path to look for a homedirectory attribute and replace the backslash by the \5C LDAP escape character
    if ($CheckHomeDirectory) {
        $ADSearcher.Filter = "(homedirectory=$($_.FullName -replace '\\','\5C')*)"
    }

    # Execute AD Query and store in $ADResult
    $ADResult = $ADSearcher.Findone()
    
    # If no matching samaccountname is found this code is executed and displayed
    if (!($ADResult)) {
        $HashProps = @{
            'Error' = 'Account does not exist and has a home folder'
            'FullPath' = $_.FullName
        }
        if ($FolderSize) {
            $HashProps.SizeinBytes = [long](Get-ChildItem -LiteralPath $_.Fullname -Recurse -Force -ErrorAction SilentlyContinue |
                Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue | Select-Object -Exp Sum)
            $HashProps.SizeinMegaBytes = "{0:n2}" -f ($HashProps.SizeinBytes/1MB)
        }

        if ($LastLogonDate) {
            $HashProps.LastLogonDate = Get-ChildItem -LiteralPath $_.Fullname -Force -ErrorAction SilentlyContinue |
                Where-Object {-not $_.PSISContainer} | Sort-Object -Property LastWriteTime | Select-Object -Last 1 -ExpandProperty LastWriteTime
        }
        
        if ($MoveFolderPath) {
            $HashProps.DestinationFullPath = Join-Path -Path $MoveFolderPath -ChildPath (Split-Path -Path $_.FullName -Leaf)
            if ($UseRobocopy) {
                robocopy $($HashProps.FullPath) $($HashProps.DestinationFullPath) /E /MOVE /R:2 /W:1 /XJD /XJF | Out-Null
            } else {
                Move-Item -LiteralPath $HashProps.FullPath -Destination $HashProps.DestinationFullPath -Force
            }
        }

        if ()

        # Output the object
        New-Object -TypeName PSCustomObject -Property $HashProps
    
    # If samaccountname is found but the account is disabled this information is displayed
    } elseif (([boolean]((-join $ADResult.Properties.useraccountcontrol) -band 2))) {
        $HashProps = @{
            'Error' = 'Account is disabled and has a home folder'
            'FullPath' = $_.FullName
        }
        if ($FolderSize) {
            $HashProps.SizeinBytes = [long](Get-ChildItem -LiteralPath $_.Fullname -Recurse -Force -ErrorAction SilentlyContinue |
                Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue | Select-Object -Exp Sum)
            $HashProps.SizeinMegaBytes = "{0:n2}" -f ($HashProps.SizeinBytes/1MB)
        }

        if ($LastLogonDate) {
            $HashProps.LastLogonDate = Get-ChildItem -LiteralPath $_.Fullname -Force -ErrorAction SilentlyContinue |
                Where-Object {-not $_.PSISContainer} | Sort-Object -Property LastWriteTime | Select-Object -Last 1 -ExpandProperty LastWriteTime
        }

        if ($MoveFolderPath -and $MoveDisabled) {
            $HashProps.DestinationFullPath = Join-Path -Path $MoveFolderPath -ChildPath (Split-Path -Path $_.FullName -Leaf)
            Move-Item -LiteralPath $HashProps.FullPath -Destination $HashProps.DestinationFullPath -Force
        }

        # Output the object
        New-Object -TypeName PSCustomObject -Property $HashProps

    # Folders that do have active user accounts are displayed if -DisplayAll switch is set
    } elseif ($ADResult -and $DisplayAll) {
        $HashProps = @{
            'Error' = $null
            'FullPath' = $_.FullName
        }
        if ($FolderSize) {
            $HashProps.SizeinBytes = [long](Get-ChildItem -LiteralPath $_.Fullname -Recurse -Force -ErrorAction SilentlyContinue |
                Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue | Select-Object -Exp Sum)
            $HashProps.SizeinMegaBytes = "{0:n2}" -f ($HashProps.SizeinBytes/1MB)
        }

        if ($LastLogonDate) {
            $HashProps.LastLogonDate = Get-ChildItem -LiteralPath $_.Fullname -Force -ErrorAction SilentlyContinue |
                Where-Object {-not $_.PSISContainer} | Sort-Object -Property LastWriteTime | Select-Object -Last 1 -ExpandProperty LastWriteTime
        }

        # Output the object
        New-Object -TypeName PSCustomObject -Property $HashProps
    }
}