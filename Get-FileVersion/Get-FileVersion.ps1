<#   
.SYNOPSIS   
	Script to check files on a range of machines listed in $serverlist. Exports to csv.
    
.DESCRIPTION 
	Script to check files on a range of machines listed in $serverlist. The script checks filesize, date modified
	and version of the file and writes this to a comma separated value.
	
.PARAMETER InputFile 
	The plaintext file containing the hostname or full dns names of the computers that should be queried

.PARAMETER LogFilePath
	The path where the log file is generated. This should be a folder as the file name is automatically generated
	
.PARAMETER PathofFile
	This parameter specifies the specific file for which the information is required. By default this is set to
	netbt.sys. An example of a correct input for this parameter would be: "\c$\WINDOWS\system32\drivers\netbt.sys"

.NOTES   
    Name: Get-FileVersion.ps1
    Author: Jaap Brasser
    DateCreated: 19-06-2012

.LINK
	http://www.jaapbrasser.com
	
.EXAMPLE   
	Get-FileVersion.ps1 -InputFile C:\ListofServers.txt -LogFilePath C:\Log

	Description 
	-----------     
	The script will query the systems in the C:\ListofServers.txt file details of all the services. The collected results
	will be written to a comma separated file named 'Autolog_GetFileVersion_dd-MM-yyyy_HHmm.ss.csv'. If the file
	already exists it will be overwritten. Since -PathofFile is not specified the script will default to
#>
#Set variables for script
param(
	$inputfile,
	$logfilepath,
	$pathoffile = "\c$\WINDOWS\system32\drivers\netbt.sys"
)

# Check parameters
If (!($inputfile)) {Write-Warning "InputFile not specified, please provide this parameter";return}
If (!($logfilepath)) {Write-Warning "LogFilePath not specified, please provide this parameter";return}
If (!(Test-Path $inputfile)) {Write-Warning "Inputfile not found, exiting";return}
If (!(Test-Path $logfilepath)) {Write-Warning "Logfile path not found, exiting";return}

# Get server names from file
$serverlist = @(get-content $inputfile)

# Gets date and reformats to be used in log filename, enabling automagic log creation
$tempdate = (get-date).tostring("dd-MM-yyyy_HHmm.ss")
$logfile = $logfilepath+"\Autolog_GetFileVersion_"+$tempdate+".csv"

# Encoding for output is set to utf8, otherwise excel will not open the .csv files correctly
$exporttofile = "Servername,Filename,Filesize,File Version,Product Version,Last Modified" 
$exporttofile | out-file $logfile -append -encoding utf8 


for ($j=0;$j -lt $serverlist.count;$j++) {

	#Prepare variables and display progress of script
	$i = $j + 1
	$display = $serverlist[$j]+" *** Server "+$i+" out of "+$serverlist.count
	$display
	$testping = test-connection -computername $serverlist[$j] -count 1 -quiet

	# Loop only executed when ping is successful
	if ($testping) {

	#Set temporary variable and get file properties
		$tempfilepath = "\\"+$serverlist[$j]+$PathofFile
		$tempvar = get-item $tempfilepath -Force

		#Prepare variables
		$tempserver = $serverlist[$j]
		$tempversion = $tempvar.versioninfo
			
		#Add information to array that will be written to file at end of script
		$exporttofile = $tempserver+","+$tempvar.name+","+$tempvar.length+","+$tempversion.fileversion+","+$tempversion.productversion+","+$tempvar.lastwritetime
		$exporttofile | out-file $logfile -append -encoding utf8 
	}
}