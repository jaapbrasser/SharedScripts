Function Search-Msdn {
<#
.Synopsis
Open a Search page on MSDN

.DESCRIPTION
This function takes a searchquery, either a single query or an array and culture value to query MSDN and opens a webpage in the default browser.

.NOTES   
Name: Search-Msdn
Author: Jaap Brasser
Version: 1.0
DateUpdated: 2013-06-23

.LINK
http://www.jaapbrasser.com

.PARAMETER SearchQuery
The string or array of string for which a query will be executed
	
.PARAMETER Culture
The culture for which the search query will be executed. Eg: en-US, de-DE, fr-FR

.EXAMPLE
Search-Msdn -SearchQuery Wscript -Culture de-DE

Description:
Will open a search page on Msdn in German searching for Wscript

.EXAMPLE
Search-Msdn Word.Application

Description:
Will open a search page on Msdn searching for Word.Application using the default culture of en-US
#>
    param(
        [Parameter(Mandatory=$true)]
            [string[]]$SearchQuery,
        [System.Globalization.Cultureinfo]$Culture = 'en-US'
    )
    foreach ($Query in $SearchQuery) {
        Start-Process -FilePath "http://social.msdn.microsoft.com/Search/$($Culture.Name)?query=$Query"
    }
}