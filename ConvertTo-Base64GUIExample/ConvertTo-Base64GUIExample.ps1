function ConvertTo-Base64GUIExample {
<#
.SYNOPSIS
Function to showcase some of the PowerShell GUI capabilities

.DESCRIPTION
This function contains various examples of using the GUI capabilities of both Windows PowerShell and PowerShell (Core). This is inteded to be used as a reference for those interested in building basic GUIs with PowerShell
#>

param(
    [string] $Title,
    [validateset('VB')]
    [string] $GUIType = 'VB'
)
    
    if ('VB' -eq $GUIType) {
        [System.Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic') | Out-Null
        $InputBox = [Microsoft.VisualBasic.Interaction]::InputBox("Let's convert this to base64", $Title, $null)
        $InputBox = [convert]::ToBase64String([char[]]$InputBox)
        [Microsoft.VisualBasic.Interaction]::MsgBox($InputBox,0,$Title)
    }
}