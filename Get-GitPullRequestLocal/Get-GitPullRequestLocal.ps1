Function Get-GitPullRequestLocal {
<#
.SYNOPSIS
Helper function that creates folder, clones single branch based of a GitHub pull request uri

.EXAMPLE
Get-GitPullRequestLocal -Uri https://github.com/jaapbrasser/SharedScripts/pull/29

Will create a folder in C:\Temp named after the PR number, and clone the specific branch and display the git status
#>

    [cmdletbinding(SupportsShouldProcess)]
    param(
        [string] $Uri,
        [string] $Path = 'C:\Temp'
    )

    $Request = Invoke-WebRequest $Uri

    $Values = @{
        Folder = '$Path\PR{0}' -f ($Uri.Split('/')[-1])
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
    } catch {}
}