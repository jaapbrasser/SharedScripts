<#   
.SYNOPSIS   
	Script that compares group membership of source user to destination user, changes destination user group membership
    
.DESCRIPTION 
	This script compares the group membership of $SourceAccount and $DestinationAccount, based on the membership of the
	source account the destination account is also added to these groups. Script outputs actions taken to the prompt.
	The script can also run without any parameters then the script will prompt for both usernames. The GUI is intended
	to simplify this process and to give a better overview of the action the script intends to perform.
 
.PARAMETER SourceAccount
    User of which group membership is read

.PARAMETER DestinationAccount
    User of which group membership will be changed by comparing it to source user

.PARAMETER ComputerName
    The netbios name or FQDN of the domain controller which will be queried for the respective users

.NOTES   
    Name: Compare-ADuserAddGroupGUI.ps1
    Author: Jaap Brasser
    DateCreated: 2015-03-10
    Version: 1.1
	Blog: www.jaapbrasser.com

.EXAMPLE   
	.\Compare-ADuserAddGroupGUI.ps1 testuserabc123 testuserabc456

Description 
-----------     
This command will add&remove from groups testuserabc456 to match groups that testuserabc123 is a member of the user is
prompted by user interface to confirm these changes.

.EXAMPLE   
	.\Compare-ADuserAddGroupGUI.ps1

Description 
-----------     
Will use GUI to prompt for confirmation 
#>
param(
	$SourceAccount,
	$DestinationAccount,
    $ComputerName
)

# Load Visual Basic assembly
[void][System.Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic')

# Load Active Directory Module
Import-Module ActiveDirectory

# Create hashtable for splatting in the Get-ADUser cmdlet
$ADUserSplat = @{
    Property = 'memberof'
}

# Checks if both accounts are provided as an argument, otherwise prompts for input
if (-not $SourceAccount) { $SourceAccount = [Microsoft.VisualBasic.Interaction]::InputBox("Enter the name of the account to read the groups from...", "Source Account", "") }
if (-not $DestinationAccount) { $DestinationAccount = [Microsoft.VisualBasic.Interaction]::InputBox("Enter the name of the account to set the groups to...", "Destination Account", "") }
if ($ComputerName) {$ADUserSplat.Server = $ComputerName}

# Retrieves the group membership for both accounts, if account is not found or error is generated the object is set to $null
try { $sourcemember = get-aduser -filter {samaccountname -eq $SourceAccount} @ADUserSplat | select memberof }
catch {	$sourcemember = $null}
try { $destmember = get-aduser -filter {samaccountname -eq $DestinationAccount} @ADUserSplat | select memberof }
catch { $destmember = $null}

# Checks if accounts have group membership, if no group membership is found for either account script will exit
if ($sourcemember -eq $null) {[Microsoft.VisualBasic.Interaction]::MsgBox("Source user not found",0,"Exit Message");return}
if ($destmember -eq $null) {[Microsoft.VisualBasic.Interaction]::MsgBox("Destination user not found",0,"Exit Message");return}

# Checks for differences, if no differences are found script will prompt and exit
if (-not (compare-object $destmember.memberof $sourcemember.memberof)) {
	[Microsoft.VisualBasic.Interaction]::InputBox("No difference between $SourceAccount & $DestinationAccount groupmembership found. $DestinationAccount will not be added to any additional groups.",0,"Exit Message");return
}

# Prompt for adding user to groups, only prompt when there are changes
if (compare-object $destmember.memberof $sourcemember.memberof | where-object {$_.sideindicator -eq '=>'}) {
	$ConfirmAdd = [Microsoft.VisualBasic.Interaction]::MsgBox("Do you want to add `'$($DestinationAccount)`' to the following groups:`n`n$((compare-object $destmember.memberof $sourcemember.memberof | 
	where-object {$_.sideindicator -eq '=>'} | select -expand inputobject | foreach {([regex]::split($_,'^CN=|,.+$'))[1]}) -join "`n")",4,"Please confirm the following action")
}

# Prompt for removing user from groups, only prompt when there are changes
if (compare-object $destmember.memberof $sourcemember.memberof | where-object {$_.sideindicator -eq '<='}) {
	$ConfirmRemove = [Microsoft.VisualBasic.Interaction]::MsgBox("Do you want to remove `'$($DestinationAccount)`' from the following groups:`n`n$((compare-object $destmember.memberof $sourcemember.memberof | 
	where-object {$_.sideindicator -eq '<='} | select -expand inputobject | foreach {([regex]::split($_,'^CN=|,.+$'))[1]}) -join "`n")",4,"Please confirm the following action")
}

# If the user confirmed adding the groups to the account, the user will be added to the groups
if ($ConfirmAdd -eq "Yes") {
	compare-object $destmember.memberof $sourcemember.memberof | where-object {$_.sideindicator -eq '=>'} | 
	select -expand inputobject | foreach {add-adgroupmember "$_" $DestinationAccount}
}

# If the user confirmed removing any groups not present on the source account, the user will be removed from the groups
if ($ConfirmRemove -eq "Yes") {
	compare-object $destmember.memberof $sourcemember.memberof | where-object {$_.sideindicator -eq '<='} | 
	select -expand inputobject | foreach {remove-adgroupmember "$_" $DestinationAccount -Confirm:$false}
}

# Prompt after executing script
[void][Microsoft.VisualBasic.Interaction]::MsgBox("Script successfully executed",0,"Exit Message")
exit