<#   
.SYNOPSIS   
Script to delete or list old files in a folder
    
.DESCRIPTION 
Script to delete files older than x-days. The script is built to be used as a scheduled task, it automatically generates a logfile name based on the copy location and the current date/time. There are various levels of logging available and the script can also run in -listonly mode in which it only lists the files it would otherwise delete. There are two main routines, one to delete the files and a second routine that checks if there are any empty folders left that could be deleted.
	
.PARAMETER FolderPath 
The path that will be recusively scanned for old files.

.PARAMETER Fileage
Filter for age of file, entered in days. Use -1 for all files to be removed.
	
.PARAMETER LogFile
Specifies the full path and filename of the logfile. When the LogFile parameter is used in combination with -autolog only the path is required.

.PARAMETER AutoLog
Automatically generates filename at path specified in -logfile. If a filename is specified in the LogFile parameter and the AutoLog parameter is used only the path specified in LogFile is used. The file name is created with the following naming convention:
"Autolog_<FolderPath><dd-MM-yyyy_HHmm.ss>.log"

.PARAMETER ExcludePath
Specifies a path or multiple paths in quotes separated by commas. The Exclude parameter only accepts full paths, relative paths should not be used.

.PARAMETER IncludePath
Specifies a path or multiple paths in quotes separated by commas. The Exclude parameter only accepts full paths, relative paths should not be used. IncludePath is processed before ExcludePath.

.PARAMETER RegExPath
This switch affects both the IncludePath and ExcludePath parameters. Instead of matching against a path name a regular expression is used. For more information about regular expressions see the help file: Get-Help about_Regular_Expressions. The regular expression is only matched against the path of a file, so no file names can be excluded by utilizing ExcludePath.

.PARAMETER ExcludeFileExtension
Specifies an extension or multiple extensions in quotes, separated by commas. The extensions will be excluded from deletion. Asterisk can be used as a wildcard.

.PARAMETER IncludeFileExtension
Specifies an extension or multiple extensions in quotes, separated by commas. The extensions will be included in the deletion, all other extensions will implicitly be excluded. Asterisk can be used as a wildcard.

.PARAMETER KeepFile
Specifies the number of files that should be retained in each folder. This can be useful if a folder should be cleaned but x-number of files should always be retained, the script will look at the parameter specified, LastWriteTime,CreationTime

.PARAMETER EmailTo
Should be used in conjunction with the EmailFrom and EmailSmtpServer parameters, this parameter can take an email address or an array of email address to whom the logfile will be emailed.

.PARAMETER EmailFrom
Should be used in conjunction with the EmailTo and EmailSmtpServer parameters, this parameter can take an email address which is set as the email address in the from field.

.PARAMETER EmailSmtpServer
Should be used in conjunction with the EmailTo and EmailFrom parameters, this parameter takes the fully qualified domain name of your smtp server.

.PARAMETER EmailSmtpPort
Option email parameter, allows for setting a custom port, by omitting this the default, port 25 will be used

.PARAMETER EmailSubject
Option email parameter, allows for setting a different subject for the email containing the log file. The default formatting of the subject is 'deleteold.ps1 started at: $StartTime FolderPath: $FolderPath'

.PARAMETER EmailBody
Option email parameter, allows for setting a custom email body, default is to have an empty email body

.PARAMETER ExcludeDate
If the ExcludeDate parameter is specified the query is converted by the ConvertFrom-Query function. The output of that table is a hashtable that is splatted to the ConvertTo-DateObject function which returns an array of dates. All files that match a date in the returned array will be excluded from deletion.
Query examples:
Week:
'Week,sat,-1'
Will list all saturday until the LimitYear maximum is reached
'Week,wed,5'
Will list the last 5 wednesdays

Month:
'Month,first,4'
Will list the first day of the last four months
'Month,last,-1'
Will list the last day of until the LimitYear maximum is reached. If the current date is the last day of the month the current day is also listed.
'Month,30,3'
Will list the 30th of the last three months, if february is in the results it will be ignored because it does not have 30 days.
'Month,31,-1'
Will only list the 31st of the month, all months that have less than 31 days are excluded. Will list untli the LimitYear maximum has been reached.
'Month,15,4','Month,last,-1'
Will list the first day of the last four months and list the last day of until the LimitYear maximum is reached. If the current date is the last day of the month the current day is also listed.

Quarter:
'Quarter,first,-1'
Will list the first day of a quarter until the LimitYear maximum is reached
'Quarter,last,6'
Will list the last day of the past six quarters. If the current date is the last day of the quarter the current day is also listed.
'Quarter,91,5'
Will only list the 91st day of each quarter, in non-leap years this will be the last three quarters. In leap years the first quarter also has 91 days and will therefore be included in the results
'Quarter,92,-1'
Will only list the 92nd day of each quarter, so only display the 30th of september and 31st of december. The first two quarters of a year have less days and will not be listed. Will run until limityear maximum is reached

Year:
'Year,last,4'
Will list the 31st of december for the last 4 years
'Year,first,-1'
Will list the 1st of january until the Limityear maximum has been reached
'Year,15,-1'
Will list the 15 of january until the LimitYear maximum has been reached
'Year,366,5'
Will list only the 366st day, only the last day of the last 5 leap years

Specific Date:
'Date,2010-05-15'
Will list 15th of may 2010
'Date,2012/12/12'
Will list 12th of december 2012

Date Ranges:
'DateRange,2010-05-05,10'
Will list 10 dates, starting at the 5th of May 2010 continuing up until the 14th of May 2010

'LimitYear,2008'
Will place the limit of LimitYear to 2008, the default value of this parameter is 2010.

Any combination or queries is allowed by comma-separating the queries for example. Query elements Week/Month/Quarter/Year can not be used twice when combining queries. The Date value can be used multiple times:
'Week,Fri,10','Year,last,-1','LimitYear,1950'
Will list the last 10 fridays and the 31st of december for all years until the LimitYear is reached
'Week,Thu,4','Month,last,-1','Quarter,first,6','Year,last,10','LimitYear,2012','Date,1990-12-31','Date,1995-5-31'
Will list the last four Thursdays, the last day of the month until LimitYear maximum has been reached, the first day of the first 6 quarters and the 31st of december for the last 10 years and the two specific dates 1990-12-31 & 1995-5-31.

.PARAMETER ListOnly
Only lists, does not remove or modify files. This parameter can be used to establish which files would be deleted if the script is executed.

.PARAMETER VerboseLog
Logs all delete operations to log, default behaviour of the script is to log failed only.

.PARAMETER AppendLog
Appends to existing logfile, default behaviour of the script is to replace existing log files if the log file already exists. If log file does not exist log file will be created as it normally would.

.PARAMETER CreateTime
Deletes files based on CreationTime, the default behaviour of the script is to delete based on LastWriteTime.

.PARAMETER CompareCreateTimeLastModified
Deletes files based on CreationTime or LastWriteTime, depending which one was last modified. The most recent entry will be used in the comparison, this is especially useful for files that have a CreateTime date which is later than the LastModified date. This occurs when a file is copied to a new location.

.PARAMETER LastAccessTime
Deletes files based on LastAccessTime, the default behaviour of the script is to delete based on LastWriteTime.

.PARAMETER CleanFolders
If this switch is specified any empty folder will be removed. Default behaviour of this script is to only delete folders that contained old files.

.PARAMETER NoFolder
If this switch is specified only files will be deleted and the existing folder will be retained.

.PARAMETER ArchivedOnly
If this switch is specified only files that have the archive bit cleared (meaning backed up) will be purged.
.NOTES   
Name: deleteold.ps1
Author: Jaap Brasser
Version: 2.0.5
DateCreated: 2012-03-04
DateUpdated: 2016-04-12

.LINK
http://www.jaapbrasser.com

.EXAMPLE   
.\deleteold.ps1 -FolderPath H:\scripts -FileAge 100 -ListOnly -LogFile H:\log.log

Description:
Searches through the H:\scripts folder and writes a logfile containing files that were last modified 100 days ago and older.

.EXAMPLE
.\deleteold.ps1 -FolderPath H:\scripts -FileAge 30 -LogFile H:\log.log -VerboseLog

Description:
Searches through the H:\scripts folder and deletes files that were modified 30 days ago or before, writes all operations, success and failed, to a logfile on the H: drive.

.EXAMPLE
.\deleteold.ps1 -FolderPath C:\docs -FileAge 30 -LogFile H:\log.log -ExcludePath "C:\docs\finance\","C:\docs\hr\"

Description:
Searches through the C:\docs folder and deletes files, exluding the finance and hr folders in C:\docs.

.EXAMPLE
.\deleteold.ps1 -FolderPath C:\Folder -FileAge 30 -LogFile H:\log.log -IncludePath "C:\Folder\Docs\","C:\Folder\Users\" -ExcludePath "C:\docs\finance\","C:\docs\hr\"

Description:
Only check files in the C:\Folder\Docs\ and C:\Folder\Users\ Folders not any other folders in C:\Folders and explicitly exclude the Finance an HR folders in C:\Folder\Docs.

.EXAMPLE
.\deleteold.ps1 -FolderPath C:\Folder -FileAge 30 -LogFile H:\log.log -IncludePath "C:\Folder\Docs\","C:\Folder\Users\" -ExcludePath "C:\docs\finance\","C:\docs\hr\" -ExcludeDate 'Week,Fri,10','Year,last,-1','LimitYear,1950'

Description:
Only check files in the C:\Folder\Docs\ and C:\Folder\Users\ Folders not any other folders in C:\Folders and explicitly exclude the Finance an HR folders in C:\Folder\Docs. Also excludes files based on Date, excluding the last 10 fridays and the 31st of December for all years back until 1950

.EXAMPLE
.\deleteold.ps1 -FolderPath C:\Folder -FileAge 60 -LogFile H:\log.log -IncludePath .*images.* -RegExPath

Description:
Delete files older than 60 days and only delete files that contain 'images' in their path name.

.EXAMPLE
.\deleteold.ps1 -FolderPath C:\Folder -FileAge 45 -LastAccessTime -LogFile H:\log.log

Description:
Delete files that have not been access for more than 45 days.

.EXAMPLE
PowerShell.exe deleteold.ps1 -FolderPath 'H:\admin_jaap' -FileAge 10 -LogFile C:\log -AutoLog

Description:
Launches the script from batchfile or command prompt a filename is automatically generated since the -AutoLog parameter is used. Note the quotes '' that are used for the FolderPath parameter.

.EXAMPLE
.\deleteold.ps1 -FolderPath H:\SQL\BackUp -FileAge 10 -LogFile C:\log -AutoLog -KeepFile 5

Description:
Log filename is automatically generated since the -AutoLog parameter is used. All files older than ten files will be removed except when there are less than 5 files remaining, then the newest 5 files in each folder will remain.

.EXAMPLE
.\deleteold.ps1 -FolderPath C:\docs -FileAge 30 -logfile h:\log.log -CreateTime -NoFolder

Description:
Deletes all files that were created 30 days ago or before in the C:\docs folder. No folders are deleted.

.EXAMPLE
.\deleteold.ps1 -FolderPath C:\docs -FileAge 30 -logfile h:\log.log -CreateTime -CleanFolders

Description:
Deletes all files that were created 30 days ago or before in the C:\docs folder. Only folders that contained old files and are empty after the deletion of those files will be deleted.

.EXAMPLE
.\deleteold.ps1 -FolderPath C:\docs -FileAge 30 -logfile h:\log.log -CompareCreateTimeLastModified

Description:
Deletes all files that were not created or modified 30 days ago or before in the C:\docs folder.

.EXAMPLE
.\deleteold.ps1 -folderpath c:\users\jaapbrasser\desktop -fileage 10 -log c:\log.txt -autolog -verboselog -IncludeFileExtension '.xls*','.doc*'

Description:
Deletes files older than 10 days, only deletes files matching the .xls* and .doc* patterns eg: .doc and .docx files. Log file is stored in the root of the C-drive with an automatically generated name.

.EXAMPLE
.\deleteold.ps1 -folderpath c:\users\jaapbrasser\desktop -fileage 10 -log c:\log.txt -autolog -verboselog -ExcludeFileExtension .xls

Description:
Deletes files older than 10 days, excluding xls files. Log file is stored in the root of the C-drive with an automatically generated name.

.EXAMPLE
.\deleteold.ps1 -FolderPath C:\docs -FileAge 30 -LogFile h:\log.log -ExcludeDate 'Week,Thu,4','Month,last,-1','Quarter,first,6','Year,last,10','LimitYear,2012','Date,1990-12-31','Date,1995-5-31'

Description:
Deletes all files that were created 30 days ago or before in the C:\docs folder. With the exclusion of files last modified/created specified in the -ExcludeDate query.

.EXAMPLE   
.\deleteold.ps1 -FolderPath H:\scripts -FileAge 100 -ListOnly -LogFile H:\log.log -ExcludeDate 'DateRange,2005-05-16,8'

Description:
Searches through the H:\scripts folder and writes a logfile containing files that were last modified 100 days ago and older. Excluding files modified on the 16th of May 2005 and the following seven days.

.EXAMPLE
.\deleteold.ps1 -FolderPath C:\docs -ListOnly -FileAge 30 -LogFile h:\log.log -ExcludeDate 'Month,15,5','Month,16,5' -EmailTo jaapbrasser@corp.co -EmailFrom jaapbrasser@corp.co -EmailSmtpServer smtp.corp.co

Description:
Deletes all files that were created 30 days ago or before in the C:\docs folder. With the exclusion of files last modified/created on either the 15th or 16th of the last five months. After completion of the script the log file will be emailed to jaapbrasser@corp.co via the smtp.corp.co smtp server.
#>

#region Parameters
param(
    [string]   $FolderPath,
	[decimal]  $FileAge,
	[string]   $LogFile,
    [string[]] $ExcludePath,
    [string[]] $IncludePath,
	[string[]] $ExcludeFileExtension,
    [string[]] $IncludeFileExtension,
    [string[]] $ExcludeDate,
    [int]      $KeepFile,
    [string[]] $EmailTo,
    [string]   $EmailFrom,
    [string]   $EmailSmtpServer,
    [int]      $EmailSmtpPort,
    [string]   $EmailSubject,
    [string]   $EmailBody,
    [switch]   $ListOnly,
	[switch]   $VerboseLog,
	[switch]   $AutoLog,
    [switch]   $AppendLog,
	[switch]   $CreateTime,
    [switch]   $CompareCreateTimeLastModified,
    [switch]   $LastAccessTime,
    [switch]   $CleanFolders,
    [switch]   $NoFolder,
    [switch]   $ArchivedOnly,
    [switch]   $RegExPath
)
#endregion

#region Functions
# Function to convert the query provided in -ExcludeDate to a format that can be parsed by the ConvertTo-DateObject function
function ConvertFrom-DateQuery {
param (
    $Query
)
    try {
        $CsvQuery = Convertfrom-Csv -InputObject $Query -Delimiter ',' -Header 'Type','Day','Repeat'
        $ConvertCsvSuccess = $true
    } catch {
        Write-Warning 'Query is in incorrect format, please supply query in proper format'
        $ConvertCsvSuccess = $false
    }
    if ($ConvertCsvSuccess) {
        $Check=$HashOutput = @{}
        foreach ($Entry in $CsvQuery) {
            switch ($Entry.Type) {
                'week' {
                    # Convert named dates to correct format
                    switch ($Entry.Day)
                    {
                        # DayOfWeek starts count at 0, referring to the [datetime] property DayOfWeek
                        'sun' {
                            $HashOutput.DayOfWeek  = 0
                            $HashOutput.WeekRepeat = $Entry.Repeat -as [int]
                        }
                        'mon' {
                            $HashOutput.DayOfWeek  = 1
                            $HashOutput.WeekRepeat = $Entry.Repeat -as [int]
                        }
                        'tue' {
                            $HashOutput.DayOfWeek  = 2
                            $HashOutput.WeekRepeat = $Entry.Repeat -as [int]
                        }
                        'wed' {
                            $HashOutput.DayOfWeek  = 3
                            $HashOutput.WeekRepeat = $Entry.Repeat -as [int]
                        }
                        'thu' {
                            $HashOutput.DayOfWeek  = 4
                            $HashOutput.WeekRepeat = $Entry.Repeat -as [int]
                        }
                        'fri' {
                            $HashOutput.DayOfWeek  = 5
                            $HashOutput.WeekRepeat = $Entry.Repeat -as [int]
                        }
                        'sat' {
                            $HashOutput.DayOfWeek  = 6
                            $HashOutput.WeekRepeat = $Entry.Repeat -as [int]
                        }
                        Default {$Check.WeekSuccess = $false}
                    }
                }
                'month' {
                    # Convert named dates to correct format
                    switch ($Entry.Day)
                    {
                        # DayOfMonth starts count at 0, referring to the last day of the month with zero
                        'first' {
                            [array]$HashOutput.DayOfMonth  += 1
                            [array]$HashOutput.MonthRepeat += $Entry.Repeat -as [int]
                        }
                        'last' {
                            [array]$HashOutput.DayOfMonth  += 0
                            [array]$HashOutput.MonthRepeat += $Entry.Repeat -as [int]
                        }
                        {(1..31) -contains $_} {
                            [array]$HashOutput.DayOfMonth  += $Entry.Day
                            [array]$HashOutput.MonthRepeat += $Entry.Repeat -as [int]
                        }
                        Default {$Check.MonthSuccess = $false}
                    }
                }
                'quarter' {
                    # Count the number of times the quarter argument is used, used in final check of values
                    $QuarterCount++

                    # Convert named dates to correct format
                    switch ($Entry.Day)
                    {
                        # DayOfMonth starts count at 0, referring to the last day of the month with zero
                        'first' {
                            $HashOutput.DayOfQuarter   = 1
                            $HashOutput.QuarterRepeat  = $Entry.Repeat
                        }
                        'last' {
                            $HashOutput.DayOfQuarter   = 0
                            $HashOutput.QuarterRepeat  = $Entry.Repeat
                        }
                        {(1..92) -contains $_} {
                            $HashOutput.DayOfQuarter   = $Entry.Day
                            $HashOutput.QuarterRepeat  = $Entry.Repeat
                        }
                        Default {$Check.QuarterSuccess = $false}
                    }
                }
                'year' {
                    # Convert named dates to correct format
                    switch ($Entry.Day)
                    {
                        # DayOfMonth starts count at 0, referring to the last day of the month with zero
                        'first' {
                            $HashOutput.DayOfYear = 1
                            $HashOutput.DayOfYearRepeat = $Entry.Repeat
                        }
                        'last' {
                            $HashOutput.DayOfYear = 0
                            $HashOutput.DayOfYearRepeat = $Entry.Repeat
                        }
                        {(1..366) -contains $_} {
                            $HashOutput.DayOfYear       = $Entry.Day
                            $HashOutput.DayOfYearRepeat = $Entry.Repeat
                        }
                        Default {$Check.YearSuccess = $false}
                    }
                }
                'date' {
                    # Verify if the date is in the correct format
                    switch ($Entry.Day)
                    {
                        {try {[DateTime]"$($Entry.Day)"} catch{}} {
                            [array]$HashOutput.DateDay += $Entry.Day
                        }
                        Default {$Check.DateSuccess = $false}
                    }
                }

                'daterange' {
                    # Verify if the date is in the correct format
                    switch ($Entry.Day)
                    {
                        {try {[DateTime]"$($Entry.Day)"} catch{}} {
                            $HashOutput.DateRange       += $Entry.Day
                            $HashOutput.DateRangeRepeat += $Entry.Repeat
                        }
                        Default {$Check.DateRangeSuccess = $false}
                    }
                }

                'limityear' {
                    switch ($Entry.Day)
                    {
                        {(1000..2100) -contains $_} {
                            $HashOutput.LimitYear        = $Entry.Day
                        }
                        Default {$Check.LimitYearSuccess = $false}
                    }
                }
                Default {
                    $QueryContentCorrect = $false
                }
            }
        }
        $HashOutput
    }
}

# Function that outputs an array of date objects that can be used to exclude certain files from deletion
function ConvertTo-DateObject {
param(
    [validaterange(0,6)]
    $DayOfWeek,
    [int]$WeekRepeat=1,
    [validaterange(0,31)]
    $DayOfMonth,
    $MonthRepeat=1,
    [validaterange(0,92)]
    $DayOfQuarter,
    [int]$QuarterRepeat=1,
    [validaterange(0,366)]
    $DayOfYear,
    [int]$DayOfYearRepeat=1,
    $DateDay,
    $DateRange,
    [int]$DateRangeRepeat=1,
    [validaterange(1000,2100)]
    [int]$LimitYear = 2010
)
    # Define variable
    $CurrentDate = Get-Date

    if ($DayOfWeek -ne $null) {
        $CurrentWeekDayInt = $CurrentDate.DayOfWeek.value__

            # Loop runs for number of times specified in the WeekRepeat parameter
            for ($j = 0; $j -lt $WeekRepeat; $j++)
                { 
                    $CheckDate = $CurrentDate.Date.AddDays(-((7*$j)+$CurrentWeekDayInt-$DayOfWeek))

                    # Only display date if date is larger than current date, this is to exclude dates in the current week
                    if ($CheckDate -le $CurrentDate) {
                        $CheckDate
                    } else {
                        # Increase weekrepeat, to ensure the correct amount of repeats are executed when date returned is
                        # higher than current date
                        $WeekRepeat++
                    }
                }
            
            # Loop runs until $LimitYear parameter is exceeded
			if ($WeekRepeat -eq -1) {
                $j=0
                do {
                    $CheckDate = $CurrentDate.AddDays(-((7*$j)+$CurrentWeekDayInt-$DayOfWeek))
                    $j++

                    # Only display date if date is larger than current date, this is to exclude dates in the current week
                    if ($CheckDate -le $CurrentDate) {
                        $CheckDate
                    }
                } while ($LimitYear -le $CheckDate.Adddays(-7).Year)
            }
        }

    if (-not [string]::IsNullOrEmpty($DayOfMonth)) {
        for ($MonthCnt = 0; $MonthCnt -lt $DayOfMonth.Count; $MonthCnt++) {
            # Loop runs for number of times specified in the MonthRepeat parameter
            for ($j = 0; $j -lt $MonthRepeat[$MonthCnt]; $j++)
                { 
                    $CheckDate = $CurrentDate.Date.AddMonths(-$j).AddDays($DayOfMonth[$MonthCnt]-$CurrentDate.Day)

                    # Only display date if date is larger than current date, this is to exclude dates ahead of the current date and
                    # to list only output the possible dates. If a value of 29 or higher is specified as a DayOfMonth value
                    # only possible dates are listed.
                    if ($CheckDate -le $CurrentDate -and $(if ($DayOfMonth[$MonthCnt] -ne 0) {$CheckDate.Day -eq $DayOfMonth[$MonthCnt]} else {$true})) {
                        $CheckDate
                    } else {
                        # Increase MonthRepeat integer, to ensure the correct amount of repeats are executed when date returned is
                        # higher than current date
                        $MonthRepeat[$MonthCnt]++
                    }
                }
            
            # Loop runs until $LimitYear parameter is exceeded
		    if ($MonthRepeat[$MonthCnt] -eq -1) {
                $j=0
                do {
                    $CheckDate = $CurrentDate.Date.AddMonths(-$j).AddDays($DayOfMonth[$MonthCnt]-$CurrentDate.Day)
                    $j++

                    # Only display date if date is larger than current date, this is to exclude dates ahead of the current date and
                    # to list only output the possible dates. For example if a value of 29 or higher is specified as a DayOfMonth value
                    # only possible dates are listed.
                    if ($CheckDate -le $CurrentDate -and $(if ($DayOfMonth[$MonthCnt] -ne 0) {$CheckDate.Day -eq $DayOfMonth[$MonthCnt]} else {$true})) {
                        $CheckDate
                    }
                } while ($LimitYear -le $CheckDate.Adddays(-31).Year)
            }
        }
    }

    if ($DayOfQuarter -ne $null) {
        # Set quarter int to current quarter value $QuarterInt
        $QuarterInt = [int](($CurrentDate.Month+1)/3)
        $QuarterYearInt = $CurrentDate.Year
        $QuarterLoopCount = $QuarterRepeat
        $j = 0
        
        do {
            switch ($QuarterInt) {
                1 {
                    $CheckDate = ([DateTime]::ParseExact("$($QuarterYearInt)0101",'yyyyMMdd',$null)).AddDays($DayOfQuarter-1)
                    
                    # Check for number of days in the 1st quarter, this depends on leap years
                    $DaysInFeb = ([DateTime]::ParseExact("$($QuarterYearInt)0301",'yyyyMMdd',$null)).AddDays(-1).Day
                    $DaysInCurrentQuarter = 31+$DaysInFeb+31
                        
                    # If the number of days is larger that the total number of days in this quarter the quarter will be excluded
                    if ($DayOfQuarter -gt $DaysInCurrentQuarter) {
                        $CheckDate = $null
                    }

                    # This check is built-in to return the date last date of the current quarter, to ensure consistent results
                    # in case the command is executed on the last day of a quarter
                    if ($DayOfQuarter -eq 0) {
                        $CheckDate = [DateTime]::ParseExact("$($QuarterYearInt)0331",'yyyyMMdd',$null)
                    }

                    $QuarterInt = 4
                    $QuarterYearInt--
                }
                2 {
                    $CheckDate = ([DateTime]::ParseExact("$($QuarterYearInt)0401",'yyyyMMdd',$null)).AddDays($DayOfQuarter-1)
                        
                    # Check for number of days in the 2nd quarter
                    $DaysInCurrentQuarter = 30+31+30
                        
                    # If the number of days is larger that the total number of days in this quarter the quarter will be excluded
                    if ($DayOfQuarter -gt $DaysInCurrentQuarter) {
                        $CheckDate = $null
                    }

                    # This check is built-in to return the date last date of the current quarter, to ensure consistent results
                    # in case the command is executed on the last day of a quarter                       
                    if ($DayOfQuarter -eq 0) {
                        $CheckDate = [DateTime]::ParseExact("$($QuarterYearInt)0630",'yyyyMMdd',$null)
                    }
                        
                    $QuarterInt = 1
                }
                3 {
                    $CheckDate = ([DateTime]::ParseExact("$($QuarterYearInt)0701",'yyyyMMdd',$null)).AddDays($DayOfQuarter-1)
                        
                    # Check for number of days in the 3rd quarter
                    $DaysInCurrentQuarter = 31+31+30
                        
                    # If the number of days is larger that the total number of days in this quarter the quarter will be excluded
                    if ($DayOfQuarter -gt $DaysInCurrentQuarter) {
                        $CheckDate = $null
                    }
                        
                    # This check is built-in to return the date last date of the current quarter, to ensure consistent results
                    # in case the command is executed on the last day of a quarter                       
                    if ($DayOfQuarter -eq 0) {
                        $CheckDate = [DateTime]::ParseExact("$($QuarterYearInt)0930",'yyyyMMdd',$null)
                    }

                    $QuarterInt = 2
                }
                4 {
                    $CheckDate = ([DateTime]::ParseExact("$($QuarterYearInt)1001",'yyyyMMdd',$null)).AddDays($DayOfQuarter-1)
                        
                    # Check for number of days in the 4th quarter
                    $DaysInCurrentQuarter = 31+30+31
                        
                    # If the number of days is larger that the total number of days in this quarter the quarter will be excluded
                    if ($DayOfQuarter -gt $DaysInCurrentQuarter) {
                        $CheckDate = $null
                    }

                    # This check is built-in to return the date last date of the current quarter, to ensure consistent results
                    # in case the command is executed on the last day of a quarter                       
                    if ($DayOfQuarter -eq 0) {
                        $CheckDate = [DateTime]::ParseExact("$($QuarterYearInt)1231",'yyyyMMdd',$null)
                    }                        
                    $QuarterInt = 3
                }
            }

            # Only display date if date is larger than current date, and only execute check if $CheckDate is not equal to $null
            if ($CheckDate -le $CurrentDate -and $CheckDate -ne $null) {
                    
                # Only display the date if it is not further in the past than the limit year
                if ($CheckDate.Year -ge $LimitYear -and $QuarterRepeat -eq -1) {
                    $CheckDate
                }

                # If the repeat parameter is not set to -1 display results regardless of limit year                    
                if ($QuarterRepeat -ne -1) {
                    $CheckDate
                    $j++
                } else {
                    $QuarterLoopCount++
                }
            }
            # Added if statement to catch errors regarding 
        } while ($(if ($QuarterRepeat -eq -1) {$LimitYear -le $(if ($CheckDate) {$CheckDate.Year} else {9999})} 
                else {$j -lt $QuarterLoopCount}))
    }

    if ($DayOfYear -ne $null) {
        $YearLoopCount = $DayOfYearRepeat
        $YearInt = $CurrentDate.Year
        $j = 0

        # Mainloop containing the loop for selecting a day of a year
        do {
            $CheckDate = ([DateTime]::ParseExact("$($YearInt)0101",'yyyyMMdd',$null)).AddDays($DayOfYear-1)
            
            # If the last day of the year is specified, a year is added to get consistent results when the query is executed on last day of the year 
            if ($DayOfYear -eq 0) {
                $CheckDate = $CheckDate.AddYears(1)
            }
            
            # Set checkdate to null to allow for selection of last day of leap year
            if (($DayOfYear -eq 366) -and !([DateTime]::IsLeapYear($YearInt))) {
                $CheckDate = $null
            }

            # Only display date if date is larger than current date, and only execute check if $CheckDate is not equal to $null
            if ($CheckDate -le $CurrentDate -and $CheckDate -ne $null) {
                # Only display the date if it is not further in the past than the limit year
                if ($CheckDate.Year -ge $LimitYear -and $DayOfYearRepeat -eq -1) {
                    $CheckDate
                }

                # If the repeat parameter is not set to -1 display results regardless of limit year
                if ($DayOfYearRepeat -ne -1) {
                    $CheckDate
                    $j++
                } else {
                    $YearLoopCount++
                }
            }
            $YearInt--
        } while ($(if ($DayOfYearRepeat -eq -1) {$LimitYear -le $(if ($CheckDate) {$CheckDate.Year} else {9999})} 
                else {$j -lt $YearLoopCount}))
    }

    if ($DateDay -ne $null) {
        foreach ($Date in $DateDay) {
            try {
                $CheckDate     = [DateTime]::ParseExact($Date,'yyyy-MM-dd',$null)
            } catch {
                try {
                    $CheckDate = [DateTime]::ParseExact($Date,'yyyy\/MM\/dd',$null)
                } catch {}
            }
            
            if ($CheckDate -le $CurrentDate) {
                $CheckDate
            }
            $CheckDate=$null
        }
    }

    if ($DateRange -ne $null) {
        $CheckDate=$null
        try {
            $CheckDate     = [DateTime]::ParseExact($DateRange,'yyyy-MM-dd',$null)
        } catch {
            try {
                $CheckDate = [DateTime]::ParseExact($DateRange,'yyyy\/MM\/dd',$null)
            } catch {}
        }
        if ($CheckDate) {
            for ($k = 0; $k -lt $DateRangeRepeat; $k++) { 
                if ($CheckDate -le $CurrentDate) {
                    $CheckDate
                }
                $CheckDate = $CheckDate.AddDays(1)
            }
        }
    }
}
#endregion

# Check if correct parameters are used
if (-not $FolderPath) {Write-Warning 'Please specify the -FolderPath variable, this parameter is required. Use Get-Help .\deleteold.ps1 to display help.';exit}
if (-not $FileAge) {Write-Warning 'Please specify the -FileAge variable, this parameter is required. Use Get-Help .\deleteold.ps1 to display help.';exit}
if (-not $LogFile) {Write-Warning 'Please specify the -LogFile variable, this parameter is required. Use Get-Help .\deleteold.ps1 to display help.';exit}
if ($Autolog) {
    # Section that is triggered when the -autolog switch is active
	# Gets date and reformats to be used in log filename
	$TempDate = (get-date).ToString('dd-MM-yyyy_HHmm.ss')
	# Reformats $FolderPath so it can be used in the log filename
	$TempFolderPath = $FolderPath -replace '\\','_'
	$TempFolderPath = $TempFolderPath -replace ':',''
	$TempFolderPath = $TempFolderPath -replace ' ',''
	# Checks if the logfile is either pointing at a folder or a logfile and removes
	# Any trailing backslashes
	$TestLogPath = Test-Path $LogFile -PathType Container
	if (-not $TestLogPath) {
        $LogFile = Split-Path $LogFile -Erroraction SilentlyContinue
    }
	if ($LogFile.SubString($LogFile.Length-1,1) -eq '\') {
        $LogFile = $LogFile.SubString(0,$LogFile.Length-1)
    }
	# Combines the date and the path scanned into the log filename
	$LogFile = "$LogFile\Autolog_$TempFolderPath$TempDate.log"
}

#region Variables
# Sets up the variables
$Startdate = Get-Date
$LastWrite = $Startdate.AddDays(-$FileAge)
$StartTime = $Startdate.ToShortDateString()+', '+$Startdate.ToLongTimeString()
$Switches = "`r`n`t`t-FolderPath`r`n`t`t`t$FolderPath`r`n`t`t-FileAge $FileAge`r`n`t`t-LogFile`r`n`t`t`t$LogFile"
    # Populate the switches string with the switches and parameters that are set
    if ($IncludePath) {
	    $Switches += "`r`n`t`t-IncludePath"
	    for ($j=0;$j -lt $IncludePath.Count;$j++) {$Switches+= "`r`n`t`t`t";$Switches+= $IncludePath[$j]}
    }
    if ($ExcludePath) {
	    $Switches += "`r`n`t`t-ExcludePath"
	    for ($j=0;$j -lt $ExcludePath.Count;$j++) {$Switches+= "`r`n`t`t`t";$Switches+= $ExcludePath[$j]}
    }
    if ($IncludeFileExtension) {
	    $Switches += "`r`n`t`t-IncludeFileExtension"
	    for ($j=0;$j -lt $IncludeFileExtension.Count;$j++) {$Switches+= "`r`n`t`t`t";$Switches+= $IncludeFileExtension[$j]}
    }
    if ($ExcludeFileExtension) {
	    $Switches += "`r`n`t`t-ExcludeFileExtension"
	    for ($j=0;$j -lt $ExcludeFileExtension.Count;$j++) {$Switches+= "`r`n`t`t`t";$Switches+= $ExcludeFileExtension[$j]}
    }
    if ($KeepFile) {
	    $Switches += "`r`n`t`t-KeepFile $KeepFile"
    }
    if ($ExcludeDate) {
	    $Switches+= "`r`n`t`t-ExcludeDate"
        $ExcludeDate | ConvertFrom-Csv -Header:'Item1','Item2','Item3' -ErrorAction SilentlyContinue | ForEach-Object {
            $Switches += "`r`n`t`t`t"
            $Switches += ($_.Item1,$_.Item2,$_.Item3 -join ',').Trim(',')
        }	    
    }
    if ($EmailTo) {
	    $Switches += "`r`n`t`t-EmailTo"
	    for ($j=0;$j -lt $EmailTo.Count;$j++) {$Switches+= "`r`n`t`t`t";$Switches+= $EmailTo[$j]}
    }
    if ($EmailFrom) {
        $Switches += "`r`n`t`t-EmailFrom`r`n`t`t`t$EmailFrom"
    }
    if ($EmailSubject) {
        $Switches += "`r`n`t`t-EmailSubject`r`n`t`t`t$EmailSubject"
    }
    if ($EmailSmtpServer) {
        $Switches += "`r`n`t`t-EmailSmtpServer`r`n`t`t`t$EmailSmtpServer"
    }
    if ($EmailSmtpPort) {
        $Switches += "`r`n`t`t-EmailSmtpPort`r`n`t`t`t$EmailSmtpPort"
    }
    if ($ListOnly)       {$Switches+="`r`n`t`t-ListOnly"}
    if ($VerboseLog)     {$Switches+="`r`n`t`t-VerboseLog"}
    if ($Autolog)        {$Switches+="`r`n`t`t-AutoLog"}
    if ($Appendlog)      {$Switches+="`r`n`t`t-AppendLog"}
    if ($CreateTime)     {$Switches+="`r`n`t`t-CreateTime"}
    if ($LastAccessTime) {$Switches+="`r`n`t`t-LastAccessTime"}
    if ($CleanFolders)   {$Switches+="`r`n`t`t-CleanFolders"}
    if ($EmailBody)      {$Switches+="`r`n`t`t-EmailBody"}
    if ($NoFolder)       {$Switches+="`r`n`t`t-NoFolder"}
    if ($ArchivedOnly)   {$Switches+="`r`n`t`t-ArchivedOnly"}    if ($RegExPath)      {$Switches+="`r`n`t`t-RegExPath"}
    if ($CompareCreateTimeLastModified) {$Switches+="`r`n`t`t-CompareCreateTimeLastModified"}
    
[long]$FilesSize    = 0
[long]$FailedSize   = 0
[int]$FilesNumber   = 0
[int]$FilesFailed   = 0
[int]$FoldersNumber = 0
[int]$FoldersFailed = 0

# Sets up the email splat, displays a warning if not all variables have been correctly entered
if ($EmailTo -or $EmailFrom -or $EmailSmtpServer) {
    if (($EmailTo,$EmailFrom,$EmailSmtpServer) -contains '') {
        Write-Warning 'EmailTo EmailFrom and EmailSmtpServer parameters only work if all three parameters are used, no email sent...'
    } else {
        $EmailSplat = @{
            To          = $EmailTo
            From        = $EmailFrom
            SmtpServer  = $EmailSmtpServer
            Attachments = $LogFile
        }
        if ($EmailSubject) {
            $EmailSplat.Subject = $EmailSubject
        } else {
            $EmailSplat.Subject = "deleteold.ps1 started at: $StartTime FolderPath: $FolderPath"
        }
        if ($EmailBody) {
            $EmailSplat.Body    = $EmailBody
        }
        if ($EmailSmtpPort) {
            $EmailSplat.Port    = $EmailSmtpPort
        }
    }
}
#endregion

# Output text to console and write log header
Write-Output ('-'*79)
Write-Output "  Deleteold`t::`tScript to delete old files from folders"
Write-Output ('-'*79)
Write-Output "`n   Started  :   $StartTime`n   Folder   :`t$FolderPath`n   Switches :`t$Switches`n"
if ($ListOnly) {
    Write-Output "`t*** Running in Listonly mode, no files will be modified ***`n"
}
Write-Output ('-'*79)

# If AppendLog switch is present log will be appended, not replaced
if ($AppendLog) {
    ('-'*79) | Add-Content -LiteralPath $LogFile
} else {
    ('-'*79) | Set-Content -LiteralPath $LogFile
}

"  Deleteold`t::`tScript to delete old files from folders" | Add-Content -LiteralPath $LogFile
('-'*79) | Add-Content -LiteralPath $LogFile
' ' | Add-Content -LiteralPath $LogFile
"   Started  :   $StartTime" | Add-Content -LiteralPath $LogFile
' ' | Add-Content -LiteralPath $LogFile
"   Folder   :   $FolderPath" | Add-Content -LiteralPath $LogFile
' ' | Add-Content -LiteralPath $LogFile
"   Switches :   $Switches" | Add-Content -LiteralPath $LogFile
' ' | Add-Content -LiteralPath $LogFile
('-'*79) | Add-Content -LiteralPath $LogFile
' ' | Add-Content -LiteralPath $LogFile

# Define the properties to be selected for the array, if createtime switch is specified 
# CreationTime is added to the list of properties, this is to conserve memory space
$SelectProperty = @{'Property'='Fullname','Length','PSIsContainer'}
if ($CreateTime) {
	$SelectProperty.Property += 'CreationTime'
} elseif ($LastAccessTime) {
    $SelectProperty.Property += 'LastAccessTime'
} elseif ($CompareCreateTimeLastModified) {
    $SelectProperty.Property += @{
        name = 'CustomTime'
        expression = {if ($_.lastwritetime -ge $_.CreationTime){$_.LastWriteTime} else {$_.CreationTime}}
    }
} else {
	$SelectProperty.Property += 'LastWriteTime'
}
if ($ExcludeFileExtension -or $IncludeFileExtension) {
    $SelectProperty.Property += 'Extension'
}
if ($ArchivedOnly) {
    $SelectProperty.Property += 'Attributes'
}
# Get the complete list of files and save to array
Write-Output "`n   Retrieving list of files and folders from: $FolderPath"
$CheckError = $Error.Count
if ($FolderPath -match '\[|\]') {
    $null = New-PSDrive -Name TempDrive -PSProvider FileSystem -Root $FolderPath
    $FullArray = @(Get-ChildItem -LiteralPath TempDrive:\ -Recurse -ErrorAction SilentlyContinue -Force | Select-Object @SelectProperty)
} else {
    $FullArray = @(Get-ChildItem -LiteralPath $FolderPath -Recurse -ErrorAction SilentlyContinue -Force | Select-Object @SelectProperty)
}

# Split the complete list of items into a separate list containing only the files
$FileList   = @($FullArray | Where-Object {$_.PSIsContainer -eq $false})
$FolderList = @($FullArray | Where-Object {$_.PSIsContainer -eq $true})

# If the IncludePath parameter is included then this loop will run. This will clear out any path not specified in the
# include parameter. If the ExcludePath parameter is also specified
if ($IncludePath) {
    # If RegExpath has not been specified the script will escape all regular expressions from values specified
    if (!$RegExPath) {
        for ($j=0;$j -lt $IncludePath.Count;$j++) {
		    [array]$NewFileList   += @($FileList   | Where-Object {$_.FullName -match [RegEx]::Escape($IncludePath[$j])})
            [array]$NewFolderList += @($FolderList | Where-Object {$_.FullName -match [RegEx]::Escape($IncludePath[$j])})
        }
    } else {
    # Process the list of files when RegExPath has been specified
        for ($j=0;$j -lt $IncludePath.Count;$j++) {
		    [array]$NewFileList   += @($FileList   | Where-Object {$_.FullName -match $IncludePath[$j]})
            [array]$NewFolderList += @($FolderList | Where-Object {$_.FullName -match $IncludePath[$j]})
        }        
    }
    $FileList = $NewFileList
    $FolderList = $NewFolderList
    $NewFileList=$NewFolderList = $null
}

# If the ExcludePath parameter is included then this loop will run. This will clear out the 
# excluded paths for both the filelist.
if ($ExcludePath) {
    # If RegExpath has not been specified the script will escape all regular expressions from values specified
    if (!$RegExPath) {
        for ($j=0;$j -lt $ExcludePath.Count;$j++) {
            $FileList   = @($FileList   | Where-Object {$_.FullName -notmatch [RegEx]::Escape($ExcludePath[$j])})
            $FolderList = @($FolderList | Where-Object {$_.FullName -notmatch [RegEx]::Escape($ExcludePath[$j])})
	    }
    } else {
    # Process the list of files when RegExPath has been specified
        for ($j=0;$j -lt $ExcludePath.Count;$j++) {
		    $FileList =   @($FileList   | Where-Object {$_.FullName -notmatch $ExcludePath[$j]})
            $FolderList = @($FolderList | Where-Object {$_.FullName -notmatch $ExcludePath[$j]})
	    }
    }
}

# If the -IncludeFileExtension is specified all filenames matching the criteria specified
if ($IncludeFileExtension) {
    for ($j=0;$j -lt $IncludeFileExtension.Count;$j++) {
        # If no dot is present the dot will be added to the front of the string
        if ($IncludeFileExtension[$j].Substring(0,1) -ne '.') {$IncludeFileExtension[$j] = ".$($IncludeFileExtension[$j])"}
        [array]$NewFileList += @($FileList | Where-Object {$_.Extension -like $IncludeFileExtension[$j]})
    }
    $FileList = $NewFileList
    $NewFileList=$null
}

# If the -ExcludeFileExtension is specified all filenames matching the criteria specified
if ($ExcludeFileExtension) {
    for ($j=0;$j -lt $ExcludeFileExtension.Count;$j++) {
        # If no dot is present the dot will be added to the front of the string
        if ($ExcludeFileExtension[$j].Substring(0,1) -ne '.') {$ExcludeFileExtension[$j] = ".$($ExcludeFileExtension[$j])"}
        $FileList = @($FileList | Where-Object {$_.Extension -notlike $ExcludeFileExtension[$j]})
    }
}

# Catches errors during read stage and writes to log, mostly catches permissions errors. Placed after Exclude/Include portion
# of the script to ensure excluded paths are not generating errors.
$CheckError = $Error.Count - $CheckError
if ($CheckError -gt 0) {
	for ($j=0;$j -lt $CheckError;$j++) {
        # Verifies is the error does not match an excluded path, only errors not matching excluded paths will be written to the Log	
        if ($ExcludePath) {
            if (!$RegExPath) {
                if ($(for ($k=0;$k -lt $ExcludePath.Count;$k++) {$Error[$j].TargetObject -match [RegEx]::Escape($ExcludePath[$k].SubString(0,$ExcludePath[$k].Length-2))}) -notcontains $true) {
                    $TempErrorVar = "$($Error[$j].ToString()) ::: $($Error[$j].TargetObject)"
		            "`tFAILED ACCESS`t$TempErrorVar" | Add-Content -LiteralPath $LogFile
                }
            } else {
                if ($(for ($k=0;$k -lt $ExcludePath.Count;$k++) {$Error[$j].TargetObject -match $ExcludePath[$k]}) -notcontains $true) {
                    $TempErrorVar = "$($Error[$j].ToString()) ::: $($Error[$j].TargetObject)"
		            "`tFAILED ACCESS`t$TempErrorVar" | Add-Content -LiteralPath $LogFile
                }            
            }
	    } else {
            $TempErrorVar = "$($Error[$j].ToString()) ::: $($Error[$j].TargetObject)"
		    "`tFAILED ACCESS`t$TempErrorVar" | Add-Content -LiteralPath $LogFile
        }
    }
}

# Counter for prompt output
$AllFileCount = $FileList.Count

# If the -CreateTime switch has been used the script looks for file creation time rather than
# file modified/lastwrite time
if ($CreateTime) {
	$FileList = @($FileList | Where-Object {$_.CreationTime -le $LastWrite})
} elseif ($LastAccessTime) {
    $FileList = @($FileList | Where-Object {$_.LastAccessTime -le $LastWrite})
} elseif ($CompareCreateTimeLastModified) {
    $FileList = @($FileList | Where-Object {$_.CustomTime -le $LastWrite})
} else {
    $FileList = @($FileList | Where-Object {$_.LastWriteTime -le $LastWrite})
}

# If the ExcludeDate parameter is specified the query is converted by the ConvertFrom-Query function. The
# output of that table is a hashtable that is splatted to the ConvertTo-DateObject function which returns
# an array of dates. All files that match a date in the returned array will be excluded from deletion which
# allows for more specific exclusions.
if ($ExcludeDate) {
    $SplatDate = ConvertFrom-DateQuery $ExcludeDate
    $ExcludedDates = @(ConvertTo-DateObject @SplatDate | Select-Object -Unique | Sort-Object -Descending)
    if ($CreateTime) {
        $FileList = @($FileList | Where-Object {$ExcludedDates -notcontains $_.CreationTime.Date})
    } elseif ($LastAccessTime) {
        $FileList = @($FileList | Where-Object {$ExcludedDates -notcontains $_.LastAccessTime.Date})
    } elseif ($CompareCreateTimeLastModified) {
        $FileList = @($FileList | Where-Object {$ExcludedDates -notcontains $_.CustomTime.Date})
    } else {
        $FileList = @($FileList | Where-Object {$ExcludedDates -notcontains $_.LastWriteTime.Date})
    }
    [string]$DisplayExcludedDates = for ($j=0;$j -lt $ExcludedDates.Count;$j++) {
        if ($j -eq 0) {
            "`n   ExcludedDates: $($ExcludedDates[$j].ToString('yyyy-MM-dd'))"
        } else {
            $ExcludedDates[$j].ToString('yyyy-MM-dd')
        }
        # After every fifth date start on the next line
        if ((($j+1) % 6) -eq 0) {"`n`t`t "}
    }
    $DisplayExcludedDates
}

# If -KeepFile is specified this block will ensure that x-number of files will remain in the folder
if ($KeepFile) {
    $FileList | Select-Object -Property *,@{
        name       = 'ParentFolder'
        expression = {
            Split-Path -Path $_.FullName
        }
    } | Group-Object -Property ParentFolder | Where-Object {$_.Count -ge $KeepFile} | ForEach-Object {
        if ($CreateTime) {
            $FileList = @($_.Group | Sort-Object -Property CreationTime   | Select-Object -Last ($_.Count-$KeepFile))
        } elseif ($LastAccessTime) {
            $FileList = @($_.Group | Sort-Object -Property LastAccessTime | Select-Object -Last ($_.Count-$KeepFile))
        } elseif ($CompareCreateTimeLastModified) {
            $FileList = @($_.Group | Sort-Object -Property CustomTime     | Select-Object -Last ($_.Count-$KeepFile))
        } else {
            $FileList = @($_.Group | Sort-Object -Property LastWriteTime  | Select-Object -Last ($_.Count-$KeepFile))
        }
    }
}
# Defines the list of folders, either a complete list of all folders if -CleanFolders
# was specified or just the folders containing old files. The -NoFolder switch will ensure
# the folder structure is not modified and only files are deleted.
if ($CleanFolders) {
    # Uses the FolderList variable defined at the start of the script, including any exclusions/inclusions
} elseif ($NoFolder) {
    $FolderList = @()
} else {
    $FolderList = @($FileList | ForEach-Object {
        Split-Path -Path $_.FullName} |
        Select-Object -Unique | ForEach-Object {
        Get-Item -LiteralPath $_ -ErrorAction SilentlyContinue | Select-Object @SelectProperty
    })
}

# If -ArchivedOnly switch is set then eliminate any files that still have their archive bit set.
if ($ArchivedOnly)
{
    $FileList = @($FileList | Where-Object {$_.Attributes -notmatch 'Archive'})
}
# Clear original array containing files and folders and create array with list of older files
$FullArray = $null

# Write totals to console
Write-Output 	 "`n   Files`t: $AllFileCount`n   Folders`t: $($FolderList.Count) `n   Old files`t: $($FileList.Count)"

# Execute main functions of script
if (-not $ListOnly) {
    Write-Output "`n   Starting with removal of old files..."
} else {
    Write-Output "`n   Listing files..."
}

#region Delete Files
# This section determines in a loop which files are deleted. If a file fails to be deleted
# an error is logged and the error message is written to the log.
# $count is used to speed up the delete fileloop and will also be used for other large loops in the script
$Count = $FileList.Count
for ($j=0;$j -lt $Count;$j++) {
	$TempFile = $FileList[$j].FullName
	$TempSize = $FileList[$j].Length
	if (-not $ListOnly) {Remove-Item -LiteralPath $Tempfile -Force -ErrorAction SilentlyContinue}
	if (-not $?) {
		$TempErrorVar = "$($Error[0].ToString()) ::: $($Error[0].targetobject)"
		"`tFAILED FILE`t`t$TempErrorVar" | Add-Content -LiteralPath $LogFile
		$FilesFailed++
		$FailedSize+=$TempSize
	} else {
		if (-not $ListOnly) {
            $FilesNumber++
            $FilesSize+=$TempSize
            if ($VerboseLog) {
                switch ($true) {
                    {$CreateTime} {"`tDELETED FILE`t$($FileList[$j].CreationTime.ToString('yyyy-MM-dd hh:mm:ss'))`t$($FileList[$j].Length.ToString().PadLeft(15))`t$tempfile" | Add-Content -LiteralPath $LogFile}
                    {$LastAccessTime} {"`tDELETED FILE`t$($FileList[$j].LastAccessTime.ToString('yyyy-MM-dd hh:mm:ss'))`t$($FileList[$j].Length.ToString().PadLeft(15))`t$tempfile" | Add-Content -LiteralPath $LogFile}
                    {$CompareCreateTimeLastModified} {"`tDELETED FILE`t$($FileList[$j].CustomTime.ToString('yyyy-MM-dd hh:mm:ss'))`t$($FileList[$j].Length.ToString().PadLeft(15))`t$tempfile" | Add-Content -LiteralPath $LogFile}
                    Default {"`tDELETED FILE`t$($FileList[$j].LastWriteTime.ToString('yyyy-MM-dd hh:mm:ss'))`t$($FileList[$j].Length.ToString().PadLeft(15))`t$tempfile" | Add-Content -LiteralPath $LogFile}
                }
            }
        }
	}
	if($ListOnly) {
        if ($VerboseLog) {
            switch ($true) {
                {$CreateTime} {"`tLISTONLY`t$($FileList[$j].CreationTime.ToString('yyyy-MM-dd hh:mm:ss'))`t$($FileList[$j].Length.ToString().PadLeft(15))`t$tempfile" | Add-Content -LiteralPath $LogFile}
                {$LastAccessTime} {"`tLISTONLY`t$($FileList[$j].LastAccessTime.ToString('yyyy-MM-dd hh:mm:ss'))`t$($FileList[$j].Length.ToString().PadLeft(15))`t$tempfile" | Add-Content -LiteralPath $LogFile}
                {$CompareCreateTimeLastModified} {"`tLISTONLY`t$($FileList[$j].CustomTime.ToString('yyyy-MM-dd hh:mm:ss'))`t$($FileList[$j].Length.ToString().PadLeft(15))`t$tempfile" | Add-Content -LiteralPath $LogFile}
                Default {"`tLISTONLY`t$($FileList[$j].LastWriteTime.ToString('yyyy-MM-dd hh:mm:ss'))`t$($FileList[$j].Length.ToString().PadLeft(15))`t$tempfile" | Add-Content -LiteralPath $LogFile}
            }
        } else {
            "`tLISTONLY`t$TempFile" | Add-Content -LiteralPath $LogFile
        }
		$FilesNumber++
		$FilesSize+=$TempSize
	}
}
#endregion

if (-not $ListOnly) {
    Write-Output "   Finished deleting files`n"
} else {
    Write-Output "   Finished listing files`n"
}
if (-not $ListOnly) {
	Write-Output '   Check/remove empty folders started...'

#region Delete Folders
    # Checks whether folder is empty and uses temporary variables
    # Main loop goes through list of folders, only deleting the empty folders
    # The if(-not $tempfolder) is the verification whether the folder is empty
	$FolderList = @($FolderList | sort-object @{Expression={$_.FullName.Length}; Ascending=$false})
	$Count = $FolderList.Count
	for ($j=0;$j -lt $Count;$j++) {
		$TempFolder = Get-ChildItem -LiteralPath $FolderList[$j].FullName -ErrorAction SilentlyContinue -Force
		if (-not $TempFolder) {
		    $TempName = $FolderList[$j].FullName
		    Remove-Item -LiteralPath $TempName -Force -Recurse -ErrorAction SilentlyContinue
			if(-not $?) {
				$TempErrorVar = "$($Error[0].ToString()) ::: $($Error[0].targetobject)"
				"`tFAILED FOLDER`t$TempErrorVar" | Add-Content -LiteralPath $LogFile
				$FoldersFailed++
			} else {
				if ($VerboseLog) {
                    switch ($true) {
                        {$CreateTime} {"`tDELETED FOLDER`t$($FolderList[$j].CreationTime.ToString('yyyy-MM-dd hh:mm:ss'))`t`t`t$TempName" | Add-Content -LiteralPath $LogFile}
                        {$LastAccessTime} {"`tDELETED FOLDER`t$($FolderList[$j].LastAccessTime.ToString('yyyy-MM-dd hh:mm:ss'))`t`t`t$TempName" | Add-Content -LiteralPath $LogFile}
                        {$CompareCreateTimeLastModified} {"`tDELETED FOLDER`t$($FolderList[$j].CustomTime.ToString('yyyy-MM-dd hh:mm:ss'))`t`t`t$TempName" | Add-Content -LiteralPath $LogFile}
                        Default {"`tDELETED FOLDER`t$($FolderList[$j].LastWriteTime.ToString('yyyy-MM-dd hh:mm:ss'))`t`t`t$TempName" | Add-Content -LiteralPath $LogFile}
                    }
                }
				$FoldersNumber++
			}
		}
	}
#endregion

	Write-Output "   Empty folders deleted`n"
}

# Pre-format values for footer
$TimeTaken          = ((Get-Date) - $StartDate).ToString().SubString(0,8)
$FilesSize          = $FilesSize/1MB
[string]$FilesSize  = $FilesSize.ToString()
$FailedSize         = $FailedSize/1MB
[string]$FailedSize = $FailedSize.ToString()
$EndDate            = "$((Get-Date).ToShortDateString()), $((Get-Date).ToLongTimeString())"

# Write footer to log and output to console
Write-Output ($Footer = @"

$('-'*79)

   Files               : $FilesNumber
   Filesize(MB)        : $FilesSize
   Files Failed        : $FilesFailed
   Failedfile Size(MB) : $FailedSize
   Folders             : $FoldersNumber
   Folders Failed      : $FoldersFailed

   Finished Time       : $EndDate
   Total Time          : $TimeTaken

$('-'*79)
"@)

$Footer | Add-Content -LiteralPath $LogFile

# Section of script that emails the logfile if required parameters are specified.
if ($EmailSplat) {
    Send-MailMessage @EmailSplat
}

# Clean up variables at end of script
$FileList=$FolderList = $null