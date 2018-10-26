Param(
    [Parameter(Mandatory=$true)]
    [Uri]
    $CoreUpdaterUrl,

    [Parameter(Mandatory=$true)]
    [ValidateScript({Test-Path $_ -PathType 'Container'})] 
    [String]
    $RetroArchPath 
)

$WorkingDir = ".\working"
If (-NOT (Test-Path $WorkingDir -PathType Container)) {
    Write-Output "Creating Working Directory $WorkingDir"
    New-Item $WorkingDir -ItemType Directory
} Else {
    Write-Output "Cleaning Working Directory"
    Remove-Item $WorkingDir\*.*
}

#Check cores directory exists
$CoresDir = "$RetroArchPath\cores"
If (-NOT (Test-Path $CoresDir -PathType Container)) {
    Write-Output "Unable to find cores directory ($CoresDir). Exiting!"
    exit
}

$Cores = Get-ChildItem -Path $CoresDir -File -Filter *.dll
#Check cores exist
If ($Cores.Length -eq 0) {
    Write-Output "No cores found in $CoresDir. Exiting!"
    exit
}

Write-Output "Found $($Cores.Length) cores to update"

#Pull data from core updater URL
$CoresRequestUrl = "$($CoreUpdaterUrl.Scheme)://$($CoreUpdaterUrl.Host)/"
$CoresRequestBody = @{ action = "get"; items = @{ href = $CoreUpdaterUrl.AbsolutePath; what = 1;}}

$CoresResult = Invoke-RestMethod -ContentType application/json -Method POST -Uri $CoreUpdaterUrl -Body $(ConvertTo-Json $CoresRequestBody)
$RemoteCores = $CoresResult.items.Where({$_.href.StartsWith($CoreUpdaterUrl.AbsolutePath) -and $_.href.EndsWith(".zip")})

Write-Output "Successfully fetched cores from $CoreUpdaterUrl"

foreach($Core in $Cores) {
    Write-Output "Updating $($Core.Name)"
    $RemoteCore = $RemoteCores.Where({$_.href.Contains($Core.Name)})

    $CoreZipFileName = "$($Core.Name).zip"
    if(-NOT $RemoteCore.href -match $CoreZipFileName) {
        Write-Output "Warning - Didn't find $CoreZipFileName in $($RemoteCore.href). Did libretro change file naming scheme? Skipping Core"
        continue
    }

    $CoreZipUrl = "$($CoreUpdaterUrl.Scheme)://$($CoreUpdaterUrl.Host)$($RemoteCore.href)"
    Write-Output "Downloading Core from $CoreZipUrl"
    Invoke-WebRequest $CoreZipUrl -Method Get -OutFile "$WorkingDir\$CoreZipFileName"
    Write-Output "Unzipping to $WorkingDir"
    Expand-Archive "$WorkingDir\$CoreZipFileName" -DestinationPath $WorkingDir
    Write-Output "Moving $WorkingDir\$($Core.Name) to $CoresDir"
    Move-Item -Path "$WorkingDir\$($Core.Name)" -Destination $CoresDir -Force
    Write-Output "Finished updating $($Core.Name)"
}
Write-Output "Deleting Working Directory $WorkingDir"
Remove-Item $WorkingDir -Recurse
