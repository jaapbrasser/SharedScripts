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
        [switch] $NoCode
    )

    $Request = Invoke-WebRequest $Uri

    $Values = @{
        Folder = '{0}\PR{1}' -f $Path, (($Uri -replace '\/$').Split('/')[-1])
        GitHubUri = 'https://github.com/{0}' -f $Request.Links.Where{$_.class -eq 'no-underline'}[1].title.split(':')[0]
        Branch = $Request.Links.Where{$_.class -eq 'no-underline'}[1].title.split(':')[1]
    }

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
} catch {}
}
