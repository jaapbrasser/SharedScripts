(netsh wlan show profile) -match ' : ' | ForEach-Object {
    $Hash = [ordered]@{
        WifiName = ($_ -split '\:',2)[1].Trim()
    }
    $Hash.Password = (-join ((netsh wlan show profile "$($Hash.WifiName)" key=clear) -match 'key c')) -replace '\s*Key Content\s+: '

    [pscustomobject]$Hash
}