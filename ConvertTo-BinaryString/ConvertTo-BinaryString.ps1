function ConvertTo-BinaryString {
<#
    .SYNOPSIS
    Function to parse an array of binary strings to characters

    .EXAMPLE
    ConvertTo-BinaryString -String 'https://jaapbrasser.com'

    Take a string, converts it to a binary string and returns it

    .EXAMPLE
    ConvertTo-BinaryString 'https://jaapbrasser.com' -ReturnArray

    Take a string, converts it to a binary string and returns it as an array
#>
    param(
        [string] $String,
        [switch] $ReturnArray
    )
    $Output = [int32[]]$String.tochararray() | ForEach-Object {[convert]::ToString($_,2).PadRight(8,0)}

    if ($ReturnArray) {
        return $Output
    } else {
        return ($Output -join ' ')
    }
}