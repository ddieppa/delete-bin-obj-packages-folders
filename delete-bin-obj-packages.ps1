function Remove-BinObjPackagesFolders {
    param (
        [Parameter(Mandatory = $true)]
        [string]$SolutionPath,
        [string]$LogFile = "RemovalLog.txt"
    )

    if (-not (Test-Path $SolutionPath)) {
        Write-Error "The specified path does not exist. Please provide a valid solution path."
        return
    }

    $foldersToClean = @('bin', 'obj', 'packages')
    $deletedFoldersCount = @{}

    foreach ($folderName in $foldersToClean) {
        $folders = Get-ChildItem -Path $SolutionPath -Recurse -Include $folderName -Directory -Depth 2 -ErrorAction SilentlyContinue
        $deletedFoldersCount[$folderName] = 0

        foreach ($folder in $folders) {
            try {
                $files = Get-ChildItem -Path $folder.FullName -Recurse -File
                $fileCount = $files.Count
                $deletedFileCount = 0

                Write-Progress -Id 1 -Activity "Deleting $folderName folder in project: $($folder.Parent.FullName)" -Status "Deleting files..."

                foreach ($file in $files) {
                    Write-Progress -Id 2 -Activity "Deleting file..." -Status "File $deletedFileCount of $fileCount" -PercentComplete (($deletedFileCount / $fileCount) * 100)
                    Add-Content -Path $LogFile -Value "Deleting file: $($file.FullName)"
                    Remove-Item -Path $file.FullName -Force -ErrorAction Stop
                    $deletedFileCount++
                }

                if ($fileCount -eq $deletedFileCount) {
                    Add-Content -Path $LogFile -Value "Deleting folder: $($folder.FullName)"
                    Remove-Item -Path $folder.FullName -Recurse -Force -ErrorAction Stop
                    $deletedFoldersCount[$folderName]++
                }       

                Write-Progress -Id 1 -Activity "Deleting $folderName folder in project: $($folder.Parent.FullName)" -Completed
            }
            catch {
                $errorMsg = "Error encountered: $($_.Exception.Message)"
                Write-Host $errorMsg
                Add-Content -Path $LogFile -Value $errorMsg
            }
        }
    }

    $summary = "Deletion summary:"
    foreach ($folderName in $foldersToClean) {
        $summary += "`nDeleted $($deletedFoldersCount[$folderName]) $folderName folder(s)."
    }
    Write-Host $summary
    Add-Content -Path $LogFile -Value $summary
}

$basePath = Read-Host -Prompt "Enter the base path of your .NET solution"
Remove-BinObjPackagesFolders -SolutionPath $basePath
