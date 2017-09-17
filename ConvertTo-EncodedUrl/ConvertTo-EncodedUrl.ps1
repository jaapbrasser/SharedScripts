function ConvertTo-EncodedUrl {
<#
.SYNOPSIS
Converts a Url to percent encoded Url

.DESCRIPTION
This function can be used to convert a Url to a Percent-Encoded Url of a specific provider. Currently the function supports encoding Urls to Google.com and Search.com

.PARAMETER Uri
The Uri that should be encoded

.PARAMETER Provider
The provider that should be use for the percent encoded url forwarding. Currently Google and Search are supported

.NOTES
Name:        ConvertTo-EncodedUrl
Author:      Jaap Brasser
DateCreated: 2017-09-10
DateUpdated: 2017-09-10
Version:     1.0.1
Blog:        http://www.jaapbrasser.com

.LINK
http://www.jaapbrasser.com

.EXAMPLE
ConvertTo-EncodedUrl -Uri https://www.jaapbrasser.com -Provider Search

Output
------

Encoded                                                                                                              Uri                        
-------                                                                                                              ---                        
https://www.search.com/wr_clk?surl=%68%74%74%70%73%3A%2F%2F%77%77%77%2E%6A%61%61%70%62%72%61%73%73%65%72%2E%63%6F%6D https://www.jaapbrasser.com


Description
-----------
Converts the url into percent encoded url and returns the output in a PowerShell custom object with two properties: Encoded and Uri

.EXAMPLE
'https://www.jaapbrasser.com','www.bing.com' | ConvertTo-EncodedUrl -Provider Google

Output
------

Encoded                                                                                              Uri                        
-------                                                                                              ---                        
https://www.google.com/url?q=https%3A%2F%2F%77%77%77%2E%6A%61%61%70%62%72%61%73%73%65%72%2E%63%6F%6D https://www.jaapbrasser.com
https://www.google.com/url?q=http%3A%2F%2F%77%77%77%2E%62%69%6E%67%2E%63%6F%6D                       www.bing.com               


Description
-----------
Takes input from the pipeline and converts the urls into percent encoded urls with Google as a provider. Returns the output in PowerShell custom objects with two properties: Decoded and Uri
#>


    param(
        [Parameter(Mandatory = $true,    
                   ValueFromPipeline = $true
        )]
        [string[]] $Uri,

        [Parameter(Mandatory = $true
        )]
        [validateset('Google','Search')]
        [string]   $Provider
    )

    process {
        foreach ($CurrentUri in $Uri) {
            New-Object -TypeName PSCustomObject -Property @{
                Uri     = $CurrentUri
                Encoded = switch ($Provider) {
                    'Google' {
                        $(if ($CurrentUri -match 'https') {
                            'https://www.google.com/url?q=https' +
                            (-join ([int[]](($CurrentUri -replace 'https').ToCharArray()) | ForEach-Object {'%{0:X}' -f $_}))

                        } elseif ($CurrentUri -match 'http') {
                            'https://www.google.com/url?q=http' +
                            (-join ([int[]](($CurrentUri -replace 'http').ToCharArray()) | ForEach-Object {'%{0:X}' -f $_}))
                        } else {
                            'https://www.google.com/url?q=http%3A%2F%2F' +
                            (-join ([int[]]($CurrentUri.ToCharArray()) | ForEach-Object {'%{0:X}' -f $_}))
                        })
                    }
                    'Search' {
                        'https://www.search.com/wr_clk?surl=' +
                        (-join ([int[]]($CurrentUri.ToCharArray()) | ForEach-Object {'%{0:X}' -f $_}))
                    }
                }
            }
        }
    }
}
