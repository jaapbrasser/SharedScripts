<#   
.SYNOPSIS   
Function to delete scheduled tasks

.DESCRIPTION 
This function provides the possibility to remove scheduled tasks either locally or remotely. It was written after I received a request from Wulfioso to be able to delete scheduled tasks. This script can either take output from my Get-ScheduledTask.ps1 through the pipeline or a ComputerName and Path to a task can be specified. This function supports the WhatIf and Confirm switch parameters.

.PARAMETER ComputerName
This parameter contains the computername from which a task should be deleted

.PARAMETER Path
This parameter specifies the path of task that should be deleted. This should be in the following format: '\Folder\SubFolder\TaskName'
    
.NOTES   
Name: Remove-ScheduledTask
Author: Jaap Brasser
DateUpdated: 2015-08-06
Version: 1.0
Blog: http://www.jaapbrasser.com

.LINK
http://www.jaapbrasser.com

.EXAMPLE
. .\Remove-ScheduledTask.ps1

Description
-----------
This command dot sources the script to ensure the Remove-ScheduledTask function is available in your current PowerShell session

.EXAMPLE
Remove-ScheduledTask -ComputerName JaapTest01 -Path '\Folder\YourTask'

Description
-----------
Will remove the YourTask task from the JaapTest01 system

.EXAMPLE
.\Get-ScheduledTask.ps1 | Where-Object {$_.State -eq 'Disabled'} | Remove-ScheduledTask -WhatIf

Description
-----------
Get-ScheduledTask will list all the disabled tasks on a system and the Remove-ScheduledTask function will list all the actions that could be taken

.EXAMPLE
.\Get-ScheduledTask.ps1 | Remove-ScheduledTask -Confirm

Description
-----------
Will go through all the tasks on the local system and ask for confirmation before removing any tasks.
#>
function Remove-ScheduledTask {
	[cmdletbinding(SupportsShouldProcess = $true)]
	param (
		[Parameter(Mandatory = $true,
				   ValueFromPipeline = $true,
				   ValueFromPipelineByPropertyName = $true,
				   Position = 0
        )]
        [string]
		$ComputerName,
		
		[Parameter(Mandatory = $true,
				   ValueFromPipeline = $true,
				   ValueFromPipelineByPropertyName = $true,
				   Position = 1
        )]
        [string]
		$Path
	)
	
	begin {
		try {
	        $Schedule = New-Object -ComObject 'Schedule.Service'
        } catch {
	        Write-Warning "Schedule.Service COM Object not found, this script requires this object"
	        return
        }
	}
	
	process	{
        try {
            $Schedule.Connect($ComputerName)
            $TaskFolder = $Schedule.GetFolder((Split-Path -Path $Path))
            if ($PSCmdlet.ShouldProcess($Path,'Deleting Task')) {
                $TaskFolder.DeleteTask((Split-Path -Path $Path -Leaf),0)
            }
        } catch {
            $_.exception.message
        }
	}
	
	end	{

	}
}