function ConvertFrom-BinaryString {
<#
    .SYNOPSIS
    Function to parse an array of binary strings to characters

    .EXAMPLE
    ConvertFrom-BinaryString -String 1101010, 1100001, 1100001, 1110000, 1100010, 1110010, 1100001, 1110011, 1110011, 1100101, 1110010

    Output jaapbrasser

    .EXAMPLE
    $mystring = 'https://jaapbrasser.com'
    $mybinaryarray = [int32[]]$mystring.tochararray() | % {[convert]::ToString($_,2)}
    ConvertFrom-BinaryString -String $mybinaryarray

    Take a string, convert it to int32 followed by conversion to an array base 2, binary strings. Then use ConvertFrom-BinaryString to convert it back

    .EXAMPLE
    ConvertFrom-BinaryString -String 11000101, 10000001, 01100001, 01110011, 01101001, 01100011, 01100101, 00100000, 01110000, 01101111, 01111010, 01100100, 01110010, 01100001, 01110111, 01101001, 01100001, 01101010, 11000100, 10000101, 00100000, 01110111, 01101001, 01101100, 01101011, 01101001

    Output the content of this array of binary string to characters
#>
    param(
        [string[]] $String
    )
    $Output = $String | ForEach-Object {
        [char][convert]::ToInt32($_,2)
    }

    return (-join $Output)
}