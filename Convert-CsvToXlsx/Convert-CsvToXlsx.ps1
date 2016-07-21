function Convert-CsvToXlsx {
<#   
.SYNOPSIS   
Function to convert csv to xlsx

.DESCRIPTION 
This script provides the ability to convert csv files to xlsx files via the pipe line or by specifying the file. This function works by using the Excel.Application object, specifically the SaveAs method to store the file in a different format.

.PARAMETER Path
This can be a single file, or the piped input from Get-ChildItem. The script will only attempt to convert files that have .csv as a file extension

.NOTES   
Name: Convert-CsvToXlsx
Author: Jaap Brasser
DateUpdated: 2015-06-11
Version: 1.0
Blog: http://www.jaapbrasser.com

.LINK
http://www.jaapbrasser.com

.EXAMPLE
. .\Convert-CsvToXlsx.ps1

Description
-----------
This command dot sources the script to ensure the Convert-CsvToXlsx function is available in your current PowerShell session

.EXAMPLE
Convert-CsvToXlsx -Path C:\Greatest.csv -Verbose

Description
-----------
Converts the file C:\Greatest.csv to C:\Greatest.xlsx while displaying verbose information

.EXAMPLE
Get-ChildItem C:\Temp -Recurse | Convert-CsvToXlsx -WhatIf

Description
-----------
Use Get-ChildItem to retrieve a list of csv files and pipe it into the Convert-CsvToXlsx function in order to convert all the csv files in the folder and sub-folders to xlsx. The WhatIf parameter prevents the script from taking any action and will only display which files would be converted.

.EXAMPLE
#>
    [cmdletbinding(SupportsShouldProcess)]
    param (
    	[Parameter(
			Mandatory,
			ValueFromPipeline,
			ValueFromPipelineByPropertyName,
			Position = 0
        )]
        $Path
    )

    begin {
        Write-Verbose "Starting $($MyInvocation.Mycommand)"
        $Excel = New-Object -ComObject "Excel.Application"
    }

    process {
        foreach ($CurrentPath in $Path) {
            if ($CurrentPath.GetType().Name -eq 'String') {
                $CurrentPath = Get-Item  -Path $CurrentPath -ErrorAction SilentlyContinue
            }
            Write-Verbose "Current object: $($CurrentPath.FullName)"
            if (($CurrentPath.Extension -eq '.csv') -and (-not $CurrentPath.PSIsContainer)) {
                if ($PSCmdlet.ShouldProcess($CurrentPath.FullName,'Converting csv to xlsx')) {
                    $Excel.workbooks.open($CurrentPath.FullName).SaveAs("$($CurrentPath.Directory)\$($CurrentPath.BaseName).xlsx",51)
                    New-Object -TypeName PSCustomObject -Property @{
                        FullName = $CurrentPath.FullName
                        NewName = "$($CurrentPath.Directory)\$($CurrentPath.BaseName).xlsx"
                    }
                }
            }
        }
    }

    end {
        $Excel.Quit()
        Write-Verbose "Ending $($MyInvocation.Mycommand)"
    }
}
Get-ChildItem C:\Temp\RotterdamIncident | Convert-CsvToXlsx -Verbose -WhatIf
Convert-CsvToXlsx -Path C:\Temp\RotterdamIncident\fap11.csv -Verbose -WhatIf