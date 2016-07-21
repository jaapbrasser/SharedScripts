<#   
.SYNOPSIS   
	Script that retrieves disk information from a list of computer and outputs to csv
    
.DESCRIPTION 
	This script reads a list of servers or computer from a plaintext file and read the disk information
	using WMI. This information will be written to a comma-separated file containing the computer name,
	drive letter, total space, free space and free space percentage. The log file automatically
	generates a timestamp so this job can be scheduled as a task without overwriting the previous
	log file.
	
.PARAMETER Listpath
    The plaintext file containing 

.PARAMETER Logpath
    Optional parameter, if not filled in it will default to .\

.NOTES   
    Name: GetComputerDiskspace.ps1
    Author: Jaap Brasser
    DateCreated: 23-03-2012

.EXAMPLE   
	.\GetComputerDiskspace.ps1 computers.txt c:\logs\

Description 
-----------     
This will read the computer name in the plaintext file, computers.txt and output the logfile to
c:\logs\Available_Diskspace_"+$tempdate+".csv.
#>

#function GetComputerDiskspace {
	param
	(
		[string]$listpath,
		[string]$logpath
	)

	# Get the list of machines for this script if none is set exits script
	if (!($listpath)) {"No list of computers specified, exiting";return}
	$serverlist = @(get-content $listpath)

	# Checks for $logpath if does not exist defaults to .\
	if (!($logpath)) {$logpath = ".\"}

	# Gets date and reformats to be used in log filename, enabling automagic log creation
	$tempdate = (get-date).tostring("dd-MM-yyyy_HHmm.ss")
	$logfile = $logpath+"Available_Diskspace_"+$tempdate+".csv"

	# Encoding for output is set to utf8, otherwise excel will not open the .csv files correctly
	$exporttofile = "Servername,Drive Letter,Total Space(GB),Free Space(GB),Free Percentage" 
	$exporttofile | out-file $logfile -append -encoding utf8 

	# Main loop
	$count = $serverlist.count
	for ($j=0;$j -lt $count;$j++) {
		$tempvar = @()
		# Prepare variables and display progress of script
		write-output ($serverlist[$j],"*** Server",($j+1),"out of",$serverlist.count -join " ")

		# Loop only executed when ping is successful
		if (test-connection -computername $serverlist[$j] -count 1 -quiet) {
			[array]$tempvar = Get-WmiObject win32_logicaldisk -filter "drivetype = '3'" -computername $serverlist[$j] | Select systemname,deviceid,size,freespace
				for ($k=0;$k -lt $tempvar.count;$k++) {
					$tempoutput = $tempvar[$k]
					
					# Setup line to be written to file
					$freespace = "{0:N1}" -f ($tempoutput.freespace/$tempoutput.size*100)
					$exporttofile = $tempoutput.systemname+","+$tempoutput.deviceid+","+("{0:N1}" -f ($tempoutput.size/1GB))+","+("{0:N1}" -f ($tempoutput.freespace/1GB))+","+$freespace

					# Write to log, UTF8 encoding for .csv
					$exporttofile | out-file $logfile -append -encoding utf8 
				}
		}
	}
#}