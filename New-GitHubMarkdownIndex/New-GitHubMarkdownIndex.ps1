function New-GitHubMarkdownIndex {
    param(
        # The path of the file structure that will be mapped in markdown
        [string] $Path = 'C:\Temp\Events',
        # The GitHub uri that files will be linked to
        [string] $GitHubUri = 'https://github.com/jaapbrasser/events/tree/master',
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