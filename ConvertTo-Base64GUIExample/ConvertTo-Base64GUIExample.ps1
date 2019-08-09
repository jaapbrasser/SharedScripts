[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic') | Out-Null
$InputBox = [Microsoft.VisualBasic.Interaction]::InputBox("Let's convert this to base64", "Sabrina's App", $null)
$InputBox = [convert]::ToBase64String([char[]]$InputBox)
[Microsoft.VisualBasic.Interaction]::MsgBox($InputBox,0,"Sabrina's App")