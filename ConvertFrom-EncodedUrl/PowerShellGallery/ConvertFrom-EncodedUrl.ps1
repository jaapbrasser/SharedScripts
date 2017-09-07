<#PSScriptInfo

.VERSION 1.0.0

.GUID 58101b69-ce79-49ac-b675-890ad1932ba7

.AUTHOR Jaap Brasser

.COMPANYNAME PowerShell Community

.DESCRIPTION
This function can be used to extract Percent-Encoded information from urls and display that information and return that as a PowerShell custom object. This function is pipeline aware and urls can be piped directly into this function.

.COPYRIGHT 

.TAGS PowerShell Percent Encoding Obfuscation PowerShell Url Encoding Security

.LICENSEURI 

.PROJECTURI https://github.com/jaapbrasser/SharedScripts/tree/master/ConvertFrom-EncodedUrl

.ICONURI 

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS 

.EXTERNALSCRIPTDEPENDENCIES 

.RELEASENOTES


#>

function ConvertFrom-EncodedUrl {
<#
.SYNOPSIS
Converts an encoded Url to human readable format

.DESCRIPTION
This function can be used to extract Percent-Encoded information from urls and display that information and return that as a PowerShell custom object. This function is pipeline aware and urls can be piped directly into this function.

.PARAMETER Uri
The Uri that should be decoded

.NOTES
Name:        ConvertFrom-EncodedUrl
Author:      Jaap Brasser
DateCreated: 2017-09-06
DateUpdated: 2017-09-06
Version:     1.0.0
Blog:        http://www.jaapbrasser.com

.LINK
http://www.jaapbrasser.com

.EXAMPLE
ConvertFrom-EncodedUrl -Uri https://www.google.com/url?q=https%3A%2F%2F%77%77%77%2E%6A%61%61%70%62%72%61%73%73%65%72%2E%63%6F%6D

Output
------

Decoded                     Uri
-------                     ---
https://www.jaapbrasser.com https://www.google.com/url?q=https%3A%2F%2F%77%77%77%2E%6A%61%61%70%62%72%61%73%73%65%72%2E%63%6F%6D

Description
-----------
Converts the encoded url into human readable format and returns the output in a PowerShell custom object with two properties: Decoded and Uri

.EXAMPLE
'https://www.search.com/wr_clk?surl=%68%74%74%70%73%3A%2F%2F%77%77%77%2E%6A%61%61%70%62%72%61%73%73%65%72%2E%63%6F%6D',
'https://www.google.com/url?q=https%3A%2F%2F%77%77%77%2E%6A%61%61%70%62%72%61%73%73%65%72%2E%63%6F%6D' | ConvertFrom-EncodedUrl

Output
------

Decoded                     Uri
-------                     ---
https://www.jaapbrasser.com https://www.search.com/wr_clk?surl=%68%74%74%70%73%3A%2F%2F%77%77%77%2E%6A%61%61%70%62%72%61%73%73%65%72%2E%63%6F%6D
https://www.jaapbrasser.com https://www.google.com/url?q=https%3A%2F%2F%77%77%77%2E%6A%61%61%70%62%72%61%73%73%65%72%2E%63%6F%6D

Description
-----------
Takes input from the pipeline and converts the encoded urls into human readable format and returns the output in PowerShell custom objects with two properties: Decoded and Uri
#>


    param(
        [Parameter(Mandatory = $true,    
                   ValueFromPipeline = $true
        )]
        [string[]] $Uri
    )

    process {
        $Uri | ForEach-Object {
            New-Object -TypeName PSCustomObject -Property @{
                Uri     = $_
                Decoded = -join ($(if ($a=($_ -split '.*?q=(\w+)%3A.*$')[1]) {$a}),(-join [char[]](
                    ($_ -replace '.*?((%\w{2})+).*$','$1') -split '%' |
                    Where-Object {$_} | ForEach-Object {
                        [Convert]::ToInt32($_,16)
                    }
                )))
            }
        }
    }
}