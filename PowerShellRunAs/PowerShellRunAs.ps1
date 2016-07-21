<#   
.SYNOPSIS   
	Script to read and store the password value of a user credential as a securestring to/from file
    
.DESCRIPTION 
	Script with both both the ability to set and get. When the Set switch is specified the script will prompt for credentials
	and write the password to the file file specified. When the script is running with the Get switch the script will read the password
	from the file specified in the $filename variable and use the username specified in the $username variable. This essentially allows you
	to runas another identity without having to enter credentials.
 
.SWITCH Get
	This switch runs the script in get mode
	
.SWITCH Set
	This switch runs the script in set mode
	
.PARAMETER Username 
    The username to be written to file or to be used with the password that is extracted from the file.

.PARAMETER Filename
    Optional parameter, if not filled in it will default to $username.txt with backspaces removed

.NOTES   
    Name: PowerShellRunAs.ps1
    Author: Jaap Brasser
    DateCreated: 22-03-2012

.EXAMPLE   
	.\PowerShellRunAs.ps1 -get contoso\svc_remoterestart \\fileserver\share\file.pwd

Description 
-----------     
This command will get the password from file.pwd on the fileserver and use that in combination with contoso\svc_remoterestart
to return the $credentials variable which can be directly used in another script. See the next example as to how you can use
this script within another script.

.EXAMPLE   
	-credential (C:\Script\PowerShellRunAs.ps1 -get contoso\svc_remoterestart \\fileserver\share\file.pwd)

Description 
-----------     
This command will get the password from file.pwd on the fileserver and use that in combination with contoso\svc_remoterestart
to return the $credentials variable directly into -credential. This allows you to run as a different user and can be used in
certain scheduled tasks or scripts in which typing the command can be bothersome.

.EXAMPLE   
	-credential (PowerShellRunAs -get contoso\svc_remoterestart)

Description 
-----------     
This third example when you run the command as a function within your script. Because the filename was omitted the script will
try and look for a standard filename in this case .\contoso_svc_remoterestart.pwd. Other than that is functions the same as the 
previous two examples and allows you to directly use the credentials to run an application as a different identity.

.EXAMPLE   
	.\PowerShellRunAs.ps1 -set contoso\svc_remoterestart \\fileserver\share\file.pwd

Description 
-----------     
The last example shows how you can write the credentials to file. By running this a pop up will appear in which the password can
be entered. After clicking okay the password will be written to file as a PowerShell securestring.
#> 

#function PowerShellRunAs {
	param
	(
		[string]$username,
		[string]$filename,
		[switch]$get,
		[switch]$set
	)

	# Checks whether the correct values have been entered for this script to run, exits otherwise
	if (!($get) -and !($set)) {write-output "No get or set, exiting script";return}
	if (($get) -and ($set)) {write-output "Both get and set specified, exiting script";return}
	if (!($username)) {write-output "No username specified";return}
	if (!($filename)) {$filename = ($username -replace "\\", "_")+".pwd"}
	
	# Runs the get sequence of the script, exits function if $filename is not found. Outputs $credential which can be used
	# in combination with -credential
	if ($get)
	{
		if (!(test-path $filename)) {write-output "File not found $filename, exiting script";return}
		$password = Get-Content $filename | ConvertTo-SecureString 
		$credential = New-Object System.Management.Automation.PsCredential($username,$password)
		$credential
		return
	}

	# Runs the set sequence of the script where the password securestring is written to file
	# Erroractionpreference is set to suppress errors when user closes credentials input
	if ($set)
	{
		$erroractionpreference = 0
		$credential = Get-Credential -Credential $username 
		$credential.Password | ConvertFrom-SecureString | Set-Content $filename
		return
	}
#}