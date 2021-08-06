$env:AZURE_DEVOPS_EXT_PAT = $env:SYSTEM_ACCESSTOKEN
$commitId = ${env:RELEASE_ARTIFACTS_*_SOURCEVERSION}
$repoId = ${env:RELEASE_ARTIFACTS_*_REPOSITORY_ID}
$project = ${env:System_TeamProject}
$project = $project -replace ' ','%20'
$urldevops = ${env:System_CollectionUri}
$urldevops = $urldevops -replace 'vsrm.',''


$pullRequestsUri = "$urldevops" + "$project/_apis/git/repositories/" + $repoId + "/pullrequests?searchCriteria.status=active&api-version=5.1"


$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f "", "$env:SYSTEM_ACCESSTOKEN")))

$pullRequests = Invoke-RestMethod -Uri $pullRequestsUri -Method GET -ContentType "application/json" -Headers @{Authorization = "Basic $base64AuthInfo" }

foreach ($value in $pullRequests.value) {
    if ($value.lastMergeCommit.commitId -eq $commitId) {
        $pullRequestId = $value.pullRequestId
    }
}

        
$output = az repos pr update --id $pullRequestId --organization $env:System_CollectionUri --status "completed" | ConvertFrom-Json
if (!$pullRequestId){
    Write-Host "Pull Request ja completado"
    return
}

if (!$output) {
    Write-Error "Error"
    return
}else{
    Write-Host $output
}