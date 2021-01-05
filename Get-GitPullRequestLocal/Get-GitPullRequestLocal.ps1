Function Get-GitPullRequestLocal {
<#
.SYNOPSIS
Helper function that creates folder, clones single branch based of a GitHub pull request uri

.DESCRIPTION
This function is created to simplify working with pull requests. In order to get all the files on tbe local system in an organized method, I decided to group together these commands.

.EXAMPLE
Get-GitPullRequestLocal -Uri https://github.com/jaapbrasser/SharedScripts/pull/29

Will create a folder in C:\Temp named after the PR number, and clone the specific branch and display the git status
#>

    [cmdletbinding(SupportsShouldProcess)]
    param(
        # URI of the pull request
        [string] $Uri,
        # The path where the PRs will be cloned to, defaults to C:\Windows, should be specified on non-Windows systems
        [string] $Path = 'C:\Temp',
        # If this parameter is specified VScode will not automatically open after pulling in the PR
        [switch] $NoCode,
        # If this parameter explorer will be launched in current path
        [switch] $Explorer
    )

#add validation here or in param block

    $Request = Invoke-WebRequest $Uri
    $Values = [ordered]@{
        CurrentRepo = (($Uri -replace '\/$').Split('/')[4])
        CurrentPR = (($Uri -replace '\/$').Split('/')[-1])
    }

    $Values.Folder = '{0}\{1}_PR{2}' -f $Path, $Values.CurrentRepo, $Values.CurrentPR
    $Values.GitHubUri, $Values.Branch = $Request.Links.Where{
            $_.class -match 'no-underline'
        }[-1..-10].Where{
            $_.title -match $Values.CurrentRepo
        }[0].title.split(':')
    $Values.GitHubUri = 'https://github.com/{0}' -f $Values.GitHubUri

    Write-Verbose ($Values | Out-String)
    Write-Information -Message "mkdir -Path $($Values.Folder)"
    
    try {
        # Create folder and clone branch to folder
        mkdir -Path $Values.Folder -EA Stop
        Set-Location $Values.Folder
        Write-Information -Message "git clone --single-branch --branch $($Values.Branch) $($Values.GitHubUri)"
        git clone --single-branch --branch $Values.Branch $Values.GitHubUri

        Set-Location (Get-ChildItem).fullname
        
        # Retrieve status of the current branch
        git status

        # open VScode
        If (!$nocode) {
            code .
        }

        # Open explorer inn the current path, only works on Windows
        if ($Explorer) {
            explorer.exe .
        }
    } catch {}
}
