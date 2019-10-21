function New-GitHubMarkdownIndex {
<#
.SYNOPSIS
Function to generate an index to be used in markdown files

.DESCRIPTION
This function looks at a file structure and creates a tree representation in markdown. This can be used as an index for GitHub projects, options for specifying specific file formats are included in this function
#>
    [cmdletbinding(SupportsShouldProcess,DefaultParametersetName='Uri')]
    param(
        # The path of the file structure that will be mapped in markdown
        [string] $Path = 'C:\Temp\Events',
        # The GitHub full GitHub uri that files will be linked to
        [Parameter(ParameterSetName='Uri',Mandatory=$true)]
        [string] $GitHubUri = 'https://github.com/jaapbrasser/events/tree/master',
        # The GitHub Account that should be linked to
        [Parameter(ParameterSetName='AccRepo',Mandatory=$true)]
        [string] $GitHubAccount,
        # The GitHub repository that should be linked to
        [Parameter(ParameterSetName='AccRepo',Mandatory=$true)]
        [string] $GitHubRepo,
        # Included file types, specified by extension
        [string[]] $IncludeExtensions = @('.md','pdf'),
        # Whether to use clip.exe or to output to console
        [switch] $NoClipBoard
    )
    
    begin {
        $IncludeExtensions = $IncludeExtensions | ForEach-Object {
            if ($_ -notmatch '^\.') {
                ".$_"
            } else {
                $_
            }
        }
        
        if ($PSCmdlet.ParameterSetName -eq 'AccRepo') {
            $GitHubUri = 'https://github.com/{0}/{1}/tree/master' -f $GitHubAccount, $GitHubRepo
        }

        $BuildMarkDown = {
            Get-ChildItem -LiteralPath $Path | ForEach-Object {
                $GHPath = $_.FullName -replace [regex]::Escape($Path) -replace '\\','/' -replace '\s','%20'
                "* [$(Split-Path $_ -Leaf)]($GitHubUri$GHPath)"
                if ($_.PSIsContainer) {
                    $_ | Get-ChildItem -Recurse | ? {$_.PSIsContainer -or $_.Extension -in $IncludeExtensions} | ForEach-Object {
                        $Count = ($_.FullName -split '\\').Count-($Path.Split('\').Count+1)
                        $GHPath = $_.FullName -replace [regex]::Escape($Path) -replace '\\','/' -replace '\s','%20'
                        "$(" "*$Count*2)* [$(Split-Path $_ -Leaf)]($GitHubUri$GHPath)"
                    }
                }
            }
        }
    }
        
    process {
        if ($NoClipBoard) {
            $BuildMarkDown.Invoke()
        } else {
            $BuildMarkDown.Invoke() | clip.exe
        }
    }
}
