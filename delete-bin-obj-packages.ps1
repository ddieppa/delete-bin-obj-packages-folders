function Remove-BinObjPackagesFolders {
    param (
        [Parameter(Mandatory = $true)]
        [string]$SolutionPath,
        [Parameter(Mandatory = $true)]
        [string[]]$FoldersToDelete,
        [string]$LogFile = "RemovalLog.txt"
    )

    if (-not (Test-Path $SolutionPath)) {
        Write-Error "The specified path does not exist. Please provide a valid solution path."
        return
    }

    $deletedFoldersCount = @{}
    $deletedFilesCount = @{}

    $filesToDelete =@(foreach($folderName in $FoldersToDelete) {
        Get-ChildItem -Path $SolutionPath -Recurse -Include $folderName -Directory -ErrorAction SilentlyContinue | 
        ForEach-Object { Get-ChildItem -Path $_.FullName -Recurse -File -ErrorAction SilentlyContinue } 
    })
    $totalFilesCount = $filesToDelete.Count
    $deletedFilesGlobalCount = 0

    foreach ($folderName in $FoldersToDelete) {
        $folders = Get-ChildItem -Path $SolutionPath -Recurse -Include $folderName -Directory -ErrorAction SilentlyContinue
        $deletedFoldersCount[$folderName] = 0
        $deletedFilesCount[$folderName] = 0
        
        foreach ($folder in $folders) {
            $files = Get-ChildItem -Path $folder.FullName -Recurse -File -ErrorAction SilentlyContinue
            
            $deletedFoldersCount[$folderName]++
            $deletedFilesCount[$folderName] += $files.Count

            foreach ($file in $files) {
                Write-Progress -Id 1 -Activity "Deleting $folderName folder in project: $($folder.Parent.FullName)" `
                    -Status "Deleting file $($file.Name)" `
                    -PercentComplete ((++$deletedFilesGlobalCount / $totalFilesCount)*100)
                $deletionTime = Get-Date -Format g
                Add-Content -Path $LogFile -Value "$deletionTime - Deleting file: $($file.FullName)"
                Remove-Item -Path $file.FullName -Force -ErrorAction Stop
            }

            $deletionTime = Get-Date -Format g
            Add-Content -Path $LogFile -Value "$deletionTime - Deleting folder: $($folder.FullName)"
            Remove-Item -Path $folder.FullName -Recurse -Force -ErrorAction Stop
        }

        Write-Progress -Id 1 -Activity "Deleted $folderName folders and their files" -Status "Completed" -Completed
    }

    $summary = "Deletion summary:"
    foreach ($folderName in $FoldersToDelete) {
        $summary += "`nDeleted $($deletedFoldersCount[$folderName]) $folderName folder(s), $($deletedFilesCount[$folderName]) file(s)."
    }
    Write-Host $summary
    Add-Content -Path $LogFile -Value "Summary - $summary"
}

$basePath = Read-Host -Prompt "Enter the base path of your .NET solution"

$folderTypes = @("bin", "obj", "packages")
Write-Host "`nSelect the types of directories to delete:"
for ($i = 1; $i -le $folderTypes.Length; $i++) {
    Write-Host "$i. $($folderTypes[$i-1])"
}

$selectedIndices = Read-Host -Prompt "`nEnter the numbers corresponding to your choices, separated by commas"
$selectedIndicesArray = $selectedIndices.Split(',') | Sort -Unique

$selectedFolders = @()
foreach ($index in $selectedIndicesArray) {
    if ($index.Trim() -in 1..$folderTypes.Length) {
        $selectedFolders += $folderTypes[$index.Trim() - 1]
    } else {
        Write-Host "Invalid entry: $index. Skipping..."
    }
}

if ($selectedFolders.Length -eq 0) {
    Write-Host "No valid folder types selected. Exiting..."
} else {
    Remove-BinObjPackagesFolders -SolutionPath $basePath -FoldersToDelete $selectedFolders
}
