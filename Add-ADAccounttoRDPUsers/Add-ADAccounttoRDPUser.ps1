function Resolve-SamAccount {
<#
.SYNOPSIS
    Helper function that resolves SAMAccount
#>
    param(
        [string]
            $SamAccount
    )
    
    process {
        try
        {
            $ADResolve = ([adsisearcher]"(samaccountname=$Trustee)").findone().properties['samaccountname']
        }
        catch
        {
            $ADResolve = $null
        }

        if (!$ADResolve) {
            Write-Warning "User `'$SamAccount`' not found in AD, please input correct SAM Account"
        }
        $ADResolve
    }
}

function Add-ADAccounttoRDPUser {
<#
.SYNOPSIS   
Script to add an AD User or group to the Remote Desktop Users group
    
.DESCRIPTION 
The script can use either a plaintext file or a computer name as input and will add the trustee (user or group) to the Remote Desktop Users group on the computer
	
.PARAMETER InputFile
A path that contains a plaintext file with computer names

.PARAMETER Computer
This parameter can be used instead of the InputFile parameter to specify a single computer or a series of computers using a comma-separated format
	
.PARAMETER Trustee
The SamAccount name of an AD User or AD Group that is to be added to the Remote Desktop Users group

.NOTES   
Name       : Add-ADAccounttoRDPUsers.ps1
Author     : Jaap Brasser
Version    : 1.0.0
DateCreated: 2016-07-28
DateUpdated: 2016-07-28

.LINK
http://www.jaapbrasser.com

.EXAMPLE   
.\Add-ADAccounttoRDPUsers.ps1 -Computer Server01 -Trustee JaapBrasser

Description:
Will add the the JaapBrasser account to the Remote Desktop Users group on Server01

.EXAMPLE   
.\Add-ADAccounttoRDPUsers.ps1 -Computer 'Server01,Server02' -Trustee Contoso\HRManagers

Description:
Will add the HRManagers group in the contoso domain as a member of Remote Desktop Users group on Server01 and Server02

.EXAMPLE   
.\Add-ADAccounttoRDPUsers.ps1 -InputFile C:\ListofComputers.txt -Trustee User01

Description:
Will add the User01 account to the Remote Desktop Users group on all servers and computernames listed in the ListofComputers file
#>
    param(
        [Parameter(ParameterSetName= 'InputFile',
                   Mandatory       = $true
        )]
        [string]
            $InputFile,
        [Parameter(ParameterSetName= 'Computer',
                   Mandatory       = $true
        )]
            $Computer,
        [Parameter(Mandatory=$true)]
        [string]
            $Trustee
    )


    if ($Trustee -notmatch '\\') {
        $ADResolved = (Resolve-SamAccount -SamAccount $Trustee)
        $Trustee = 'WinNT://',"$env:userdomain",'/',$ADResolved -join ''
    } else {
        $ADResolved = ($Trustee -split '\\')[1]
        $DomainResolved = ($Trustee -split '\\')[0]
        $Trustee = 'WinNT://',$DomainResolved,'/',$ADResolved -join ''
    }

    if (!$InputFile) {
	    [string[]]$Computer = $Computer.Split(',')
	    $Computer | ForEach-Object {
		    Write-Verbose "Adding '$ADResolved' to Remote Desktop Users group on '$_'"
		    try {
			    ([ADSI]"WinNT://$_/Remote Desktop Users,group").add($Trustee)
			    Write-Verbose "Successfully completed command for '$ADResolved' on '$_'"
		    } catch {
			    Write-Warning $_
		    }	
	    }
    } else {
	    if (!(Test-Path -Path $InputFile)) {
		    Write-Warning 'Input file not found, please enter correct path'
	    }
	    Get-Content -Path $InputFile | ForEach-Object {
		    Write-Verbose "Adding '$ADResolved' to Remote Desktop Users group on '$_'"
		    try {
			    ([ADSI]"WinNT://$_/Remote Desktop Users,group").add($Trustee)
			    Write-Verbose 'Successfully completed command'
		    } catch {
			    Write-Warning $_
		    }        
	    }
    }
}