function Test-ScheduledTaskFolder {
<#   
.SYNOPSIS   
Function tests for existance of a folder in scheduled tasks
    
.DESCRIPTION 
This script uses the Schedule.Service COM-object to query the local or a remote computer in order to test if a certain scheduled task folder exists
 
.PARAMETER Computername
The computer that will be queried by this script, local administrative permissions are required to query this information

.PARAMETER TaskFolder
This parameter specifies which folder should be queried, should be in the \Microsoft\

.NOTES   
Name: Test-ScheduledTaskFolder.ps1
Author: Jaap Brasser
DateCreated: 2015-03-30
DateUpdated: 2015-03-30
Version: 1.0
Site: http://www.jaapbrasser.com

.LINK
http://www.jaapbrasser.com
	
.EXAMPLE   
. .\Test-ScheduledTaskFolder.ps1

Description 
-----------     
This command dot sources the script to ensure the Test-ScheduledTaskFolder function is available in your current PowerShell session

.EXAMPLE   
Test-ScheduledTaskFolder -TaskFolder \Microsoft

Description 
-----------     
Tests if the \Microsoft folder exists on the local system

.EXAMPLE   
Test-ScheduledTaskFolder -ComputerName server01 -TaskFolder \Microsoft,\Microsoft\Windows\RAS

Description 
-----------     
Tests if the \Microsoft and \Microsoft\Windows\RAS folders exists on server01

.EXAMPLE   
'server01','server02' | Test-ScheduledTaskFolder -TaskFolder \CustomTaskFolder

Description 
-----------     
Uses pipeline to verify if the \CustomTaskFolder exists on server01 and server02
#>
    param(
	    [Parameter(ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true,
            Position=0)]
        [string[]]
            $ComputerName = $env:COMPUTERNAME,
        [string[]]
            $TaskFolder
    )

    begin {
        try {
	        $Schedule = New-Object -ComObject "Schedule.Service"
        } catch {
	        Write-Warning "Schedule.Service COM Object not found, this script requires this object"
        }
    }

    process {
        foreach ($Computer in $ComputerName) {
            try {
                $Schedule.Connect($Computer)
                foreach ($Folder in $TaskFolder) {
                    $HashProps = @{
                        TaskFolder = $Folder
                        Exists = $true
                        ComputerName = $Computer
                    }
                    try {
                        $null = $Schedule.GetFolder($Folder)
                    } catch {
                        $HashProps.Exists = $false
                    }
                    New-Object -TypeName PSCustomObject -Property $HashProps
                }
            } catch {
                Write-Warning "Could not connect to $Computer"
            }
        }
    }

    end {
        Remove-Variable -Name Schedule
    }
}