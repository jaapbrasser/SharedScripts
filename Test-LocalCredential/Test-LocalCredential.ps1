<#
.Synopsis
Verify Local SAM store

.DESCRIPTION
This function takes a user name and a password as input and will verify if the combination is correct. The function returns a boolean based on the result. The script defaults to local user accounts, but a remote computername can be specified in the -ComputerName parameter.

.NOTES   
Name: Test-LocalCredential
Author: Jaap Brasser
Version: 1.0
DateUpdated: 2013-05-20

.PARAMETER UserName
The samaccountname of the Local Machine user account
	
.PARAMETER Password
The password of the Local Machine user account

.PARAMETER ComputerName
The computer on which the local credentials will be verified

.EXAMPLE
Test-LocalCredential -username jaapbrasser -password Secret01

Description:
Verifies if the username and password provided are correct on the local machine, returning either true or false based on the result
#>
function Test-LocalCredential {
    [CmdletBinding()]
    Param
    (
        [string]$UserName,
        [string]$ComputerName = $env:COMPUTERNAME,
        [string]$Password
    )
    if (!($UserName) -or !($Password)) {
        Write-Warning 'Test-LocalCredential: Please specify both user name and password'
    } else {
        Add-Type -AssemblyName System.DirectoryServices.AccountManagement
        $DS = New-Object System.DirectoryServices.AccountManagement.PrincipalContext('machine',$ComputerName)
        $DS.ValidateCredentials($UserName, $Password)
    }
}