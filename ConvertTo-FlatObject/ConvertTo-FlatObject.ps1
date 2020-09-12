function ConvertTo-FlatObject {
<#
.SYNOPSIS
Convert any object to a flat pscustomobject, so it can be used in flat formats such as csv
#>
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