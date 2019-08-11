function ConvertTo-Base64GUIExample {
<#
.SYNOPSIS
Function to showcase some of the PowerShell GUI capabilities

.DESCRIPTION
This function contains various examples of using the GUI capabilities of both Windows PowerShell and PowerShell (Core). This is inteded to be used as a reference for those interested in building basic GUIs with PowerShell
#>

param(
    [string] $Title = 'Example Title...',
    [validateset('VB')]
    [string] $GUIType = 'VB'
)
    
    switch ($GUIType) {
        'VB'        {
            [System.Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic') | Out-Null
            [Microsoft.VisualBasic.Interaction]::InputBox("Let's convert this to base64", $Title, $null) | ForEach-Object {
                [Microsoft.VisualBasic.Interaction]::MsgBox([convert]::ToBase64String([char[]]$_),0,$Title)
            }
        }
        'Windows.Forms' {
            $Form = New-Object System.Windows.Forms.Form -Property @{
                Text = $Title
                Size = New-Object System.Drawing.Size(300,150)
                StartPosition = "CenterScreen"
                Topmost = $true
            }
            
            $FormText = New-Object System.Windows.Forms.Label -Property @{
                Location = New-Object System.Drawing.Size(10,20)
                Size = New-Object System.Drawing.Size(280,30)
                Text = "Let's convert this to base64"
            }

            $FormInput = New-Object System.Windows.Forms.TextBox -Property @{
                Location = New-Object System.Drawing.Size(10,50)
                Size = New-Object System.Drawing.Size(260,20)
            }

            $FormOKButton = New-Object System.Windows.Forms.Button -Property @{
                Location = New-Object System.Drawing.Size(130,75)
                Size = New-Object System.Drawing.Size(40,23)
                Text = "OK"
            }
            $FormOKButton.Add_Click({$Script:FormInputText=$FormInput.Text;$Form.Close()})
            
            $Form.Controls.Add($FormText)
            $Form.Controls.Add($FormInput)
            $Form.Controls.Add($FormOKButton)
            $Form.ShowDialog() | ForEach-Object {
                 [convert]::ToBase64String([char[]]$FormInputText)
            }
        }
        default     {
        }
    }
}