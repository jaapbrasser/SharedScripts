function Set-CredInClip {
<#   
.SYNOPSIS
Function to temporarily store encrypted credentials in the clipboard 
    
.DESCRIPTION
This function provides the functionality to to temporarily store encrypted credentials in the clipboard. These encrypted credentials can be manually picked out of the clipboard and converted into a PSCredential object or be directly used for any form of authentication. The Get-CredInClip function can retrieve the information from the clipboard. It should be noted that the data that is stored in the clipboard when this function runs will be gone.

.PARAMETER UserName
The username that will be stored in the clipboard

.PARAMETER Password
The password that will be stored in the clipboard

.PARAMETER Credential
The PowerShell credential object that will be  be stored in the clipboard

.NOTES
Name: Set-CredInClip
Author: Jaap Brasser
DateUpdated: 2015-06-25
Version: 1.0
Blog: https://www.jaapbrasser.com

.LINK
https://www.jaapbrasser.com

.EXAMPLE
. .\CredInClip.ps1
    
Description 
-----------
This command dot sources the script to ensure the Get-CredInClip and Set-CredInClip functions are available in your current PowerShell session

.EXAMPLE
Set-CredInClip -Credential $Credential
    
Description 
-----------
Sets the credentials stored in $Credential to the clipboard

.EXAMPLE
Set-CredInClip -UserName jaapbrasser -Password (ConvertTo-SecureString "PlainTextPassword" -AsPlainText -Force)
    
Description 
-----------
Sets the credentials for UserName jaapbrasser and secure password 'PlainTextPassword' to the clipboard
#>
    [cmdletbinding()]
    param(
        [Parameter(ParameterSetName = "Credentials",
			Mandatory = $true,
			Position = 0)]
		[System.Management.Automation.PSCredential]
		$Credential,
        [Parameter(ParameterSetName = "UserPass",
			Mandatory = $true,
			Position = 0)]
		[string]
		$UserName,
        [Parameter(ParameterSetName = "UserPass",
			Mandatory = $true,
			Position = 1)]
		[SecureString]
		$Password
    )

    begin {
        [void][System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") 
    }

    process {
        [string]$OutToClip = 'JaapBrasser'*15
        if ($MyInvocation.BoundParameters.ContainsKey('Credential')) {
            $OutToClip += "`r`n$($Credential.UserName)`r`n"
            $OutToClip += $Credential.GetNetworkCredential().SecurePassword | ConvertFrom-SecureString
        } elseif ($MyInvocation.BoundParameters.ContainsKey('UserName')) {
            $PasswordString = $Password | ConvertFrom-SecureString
            $OutToClip += "`r`n$UserName`r`n$PasswordString"
        }
        [System.Windows.Forms.Clipboard]::SetText($OutToClip)
    }

    end {
        
    }
}

function Get-CredInClip {
<#   
.SYNOPSIS
Function to retrieve stored encrypted credentials in the clipboard 
    
.DESCRIPTION
This function provides the functionality to to retrieve temporarily store encrypted credentials in the clipboard. These credentials should have been stored by the Set-CredInClip function that is included in this package. This function returns a PowerShell credentials object if credentials are found in the clipboard. The Wait parameter can specify a delay, during this time the script polls every 100ms to verify if credentials are stored in the clipboard.

.PARAMETER Wait
The delay for which the script will wait for credentials to be stored in the clipboard

.NOTES
Name: Get-CredInClip
Author: Jaap Brasser
DateUpdated: 2015-06-25
Version: 1.0
Blog: http://www.jaapbrasser.com

.LINK
http://www.jaapbrasser.com

.EXAMPLE
. .\CredInClip.ps1
    
Description 
-----------
This command dot sources the script to ensure the Get-CredInClip and Set-CredInClip functions are available in your current PowerShell session

.EXAMPLE
Get-CredInClip
    
Description 
-----------
Function checks once if credentials are found, if credentials are found a PSCredential object is output. Otherwise there is no output.

.EXAMPLE
Get-CredInClip -Wait 120
    
Description 
-----------
Function polls every 100ms to verify if credentials are stored in the clipboard, if no credentials are found before 120 seconds are up the function will stop.
#>
    [cmdletbinding()]
    [OutputType([System.Management.Automation.PSCredential])]
    param(
        [int]
        $Wait
    )

    begin {
        [void][System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
        $StartTime = Get-Date
    }

    process {
        do {
            $ClipText = [System.Windows.Forms.Clipboard]::GetText() -split '\r\n'
            if (((Get-Date)-$StartTime).TotalSeconds -ge $Wait) {
                $TimeUp = $true
            }
            if ($ClipText[0] -ceq 'JaapBrasser'*15) {
                $CredInClip = $true
            }
            Start-Sleep -Milliseconds 100
        } until (($TimeUp) -or ($CredInClip))
        if ($CredInClip) {
            $User = $ClipText[1]
            $SecurePW = $ClipText[2] | ConvertTo-SecureString        
            New-Object System.Management.Automation.PSCredential($ClipText[1],$SecurePW)
        }
    }

    end {

    }
}
