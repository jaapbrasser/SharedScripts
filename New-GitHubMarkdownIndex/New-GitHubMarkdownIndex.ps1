function New-GitHubMarkdownIndex {
    param(
        [string] $Path = 'C:\Temp\Events',
        [string] $GitHubUri = 'https://github.com/jaapbrasser/events/tree/master',
        [string[]] $IncludeExtensions = @('.md','pdf','.123','123','234','.234'),
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
                $_ | Get-ChildItem -Recurse | ? {$_.PSIsContainer -or $_.Extension -in $IncludeExtensions} | ForEach-Object {
                    $Count = ($_.FullName -split '\\').Count-($Path.Split('\').Count+1)
                    $GHPath = $_.FullName -replace [regex]::Escape($Path) -replace '\\','/' -replace '\s','%20'
                    "$(" "*$Count*2)* [$(Split-Path $_ -Leaf)]($GitHubUri$GHPath)"
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