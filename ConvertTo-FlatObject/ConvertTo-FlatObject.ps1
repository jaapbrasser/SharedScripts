function ConvertTo-FlatObject {
    param(
        $sla
    )

    $sla.psobject.properties | ForEach-Object -Begin {
        $Hash = [ordered]@{}
    } -Process {
        if ($_.TypeNameOfValue -ne 'System.Object[]') {
            $Hash[$_.Name] = $_.Value
        } else {
            'hi'
            $CurrentProperty = $_
            $_.Value.psobject.properties | ForEach-Object {
                "$($CurrentProperty.Name)$($_.psobject.Name)"
                $Hash["$($CurrentProperty.Name)$($_.Name)"] = $_.Value
            }
        }
    } -End {
        [pscustomobject]$Hash
    }
}
ConvertTo-FlatObject -sla $sla