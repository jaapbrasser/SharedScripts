' If no argument is supplied then script is executed on local computer
set args = Wscript.Arguments
If Wscript.Arguments.Count = 0 Then
	strComputer = "." 
Else
	strComputer = args.item(0)
end if

'Query WMI
Set objWMIService = GetObject("winmgmts:\\" & strComputer & "\root\CIMV2") 
Set colItems = objWMIService.ExecQuery( _
    "SELECT * FROM Win32_PnPSignedDriver where deviceclass = 'net'") 
'Output to console
For Each objItem in colItems 
    Wscript.Echo "DeviceName: " & objItem.DeviceName
    Wscript.Echo "DriverProviderName: " & objItem.DriverProviderName
    Wscript.Echo "DriverVersion: " & objItem.DriverVersion
    Wscript.Echo "InfName: " & objItem.InfName
    Wscript.Echo "IsSigned: " & objItem.IsSigned
    Wscript.Echo "Signer: " & objItem.Signer
Next