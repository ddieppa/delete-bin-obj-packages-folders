# Function to test if the path valid
function Test-PathValid {
    param (
        [Parameter(Mandatory = $true)][string]$Path
    )

    if (-not (Test-Path -LiteralPath $Path)) {
        Write-Host "The specified path does not exist. Please provide a valid solution path."
        return $false
    }
    return $true
}

function Remove-FoldersAndFiles {
    param (
        [Parameter(Mandatory = $true)][string]$SolutionPath,
        [Parameter(Mandatory = $true)][string[]]$FoldersToDelete,
        [string]$LogFile = "RemovalLog.txt"
    )

    $folderSummary = @{}

    foreach ($folderName in $FoldersToDelete) {
        $folderSummary[$folderName] = @{
            'FolderCount' = 0
            'FileCount'   = 0
        }

        # Start timing
        $startTime = Get-Date

        # Retrieve all folders 
        $folders = Get-ChildItem -Path $SolutionPath -Recurse -Include $folderName -Directory -ErrorAction SilentlyContinue
        $folderSummary[$folderName]['FolderCount'] = $folders.Count

        foreach ($folder in $folders) {
            # Retrieve all files in the current folder
            $files = Get-ChildItem -Path $folder.FullName -Recurse -File -ErrorAction SilentlyContinue
            $folderSummary[$folderName]['FileCount'] += $files.Count
            $deletedFilesCount = 0

            # Delete each file in current folder
            foreach ($file in $files) {
                Remove-File -File $file -FolderName $folderName -LogFile $LogFile -DeletedFilesCount ([ref]$deletedFilesCount) -TotalFilesCount $files.Count
            }

            # Delete folder
            Remove-Folder -Folder $folder -LogFile $LogFile
        }

        # End timing and calculate elapsed time
        $endTime = Get-Date
        $elapsedTime = $endTime - $startTime
        $folderSummary[$folderName]['ElapsedTime'] = $elapsedTime.TotalSeconds
    }

    # Return the summary
    return $folderSummary
}


function Get-TotalFilesCount {
    param (
        [Parameter(Mandatory = $true)][string]$SolutionPath,
        [Parameter(Mandatory = $true)][string[]]$FoldersToDelete
    )
    
    $filesToDelete = @(foreach ($folderName in $FoldersToDelete) {
            Get-ChildItem -Path $SolutionPath -Recurse -Include $folderName -Directory -ErrorAction SilentlyContinue |
            ForEach-Object { Get-ChildItem -Path $_.FullName -Recurse -File -ErrorAction SilentlyContinue } 
        })

    return $filesToDelete.Count
}

function Remove-File {
    param (
        [Parameter(Mandatory = $true)][System.IO.FileInfo]$File,
        [Parameter(Mandatory = $true)][string]$FolderName,
        [Parameter(Mandatory = $true)][string]$LogFile,
        [Parameter()][ref]$DeletedFilesCount,
        [Parameter(Mandatory = $true)][int]$TotalFilesCount
    )

    # Write progress
    Write-Progress -Id 1 -Activity "Deleting $FolderName folder in project: $($File.DirectoryName)" -Status "Deleting file $($File.Name)" -PercentComplete ((++$DeletedFilesCount.Value / $TotalFilesCount) * 100)

    # Add logging of file deletion
    $deletionTime = Get-Date -Format g
    Add-Content -Path $LogFile -Value "$deletionTime - Deleting file: $($File.FullName)"

    # Delete file
    Remove-Item -Path $File.FullName -Force -ErrorAction Stop
}

function Remove-Folder {
    param (
        [Parameter(Mandatory = $true)][System.IO.DirectoryInfo]$Folder,
        [Parameter(Mandatory = $true)][string]$LogFile
    )
    
    # Add logging of folder deletion
    $deletionTime = Get-Date -Format g
    Add-Content -Path $LogFile -Value "$deletionTime - Deleting folder: $($Folder.FullName)"

    # Delete folder
    Remove-Item -Path $Folder.FullName -Recurse -Force -ErrorAction Stop
}

function Write-SummaryToLog {
    param (
        [Parameter(Mandatory = $true)][hashtable]$Summary,
        [Parameter(Mandatory = $true)][string]$LogFile,
        [Parameter(Mandatory = $true)][string]$SolutionPath
    )

    $summaryText = "`n========== Deletion Summary for $SolutionPath =========="
    
    # Write solution path to log file and console
    Add-Content -Path $LogFile -Value $summaryText
    Write-Host $summaryText

    foreach ($folderType in $Summary.Keys) {
        $summaryText = "`nDeleted $($Summary[$folderType]['FolderCount']) $folderType folder(s), $($Summary[$folderType]['FileCount']) file(s) in $($Summary[$folderType]['ElapsedTime']) seconds."
        
        # Write to log file
        Add-Content -Path $LogFile -Value $summaryText
        
        # Write to console
        Write-Host $summaryText
    }
}

function Write-StartOfDeletion {
    param (
        [Parameter(Mandatory = $true)][string[]]$FolderTypes,
        [Parameter(Mandatory = $true)][string]$LogFile,
        [Parameter(Mandatory = $true)][string]$SolutionPath
    )

    $folderTypesText = [string]::Join(", ", $FolderTypes)
    $startText = "`n========== Starting delete for $folderTypesText for $SolutionPath =========="

    # Write start message to log file and console
    Add-Content -Path $LogFile -Value $startText
    Write-Host $startText
}




# Input the solution directory path
$basePath = Read-Host -Prompt "Enter the base path of your .NET solution"

if (Test-PathValid -Path $basePath) {
    $folderTypes = @("bin", "obj", "packages")
    Write-Host "`nSelect the types of directories to delete:[1.bin, 2.obj, 3.packages]"
    # Get user's selected numbers
    $selectedIndices = Read-Host -Prompt "`nEnter the numbers corresponding to your choices, separated by commas"

    # If user just hit enter without entering any numbers, select bin and obj folders by default
    if ([string]::IsNullOrEmpty($selectedIndices)) {
        $selectedIndices = "1,2"
    }

    # Get unique numbers
    $selectedIndicesArray = $selectedIndices.Split(',') | Sort-Object -Unique
    $selectedFolders = @()

    foreach ($index in $selectedIndicesArray) {
        if ($index.Trim() -in 1..$folderTypes.Length) {
            $selectedFolders += $folderTypes[$index.Trim() - 1]
        }
    }

    if ($selectedFolders.Length -eq 0) {
        Write-Host "No valid folder types selected. Exiting..."
    }
    else {
        # Call function to write start of deletion
        $LogFile = "RemovalLog.txt"
        Write-StartOfDeletion -FolderTypes $selectedFolders -LogFile $LogFile -SolutionPath $basePath

        # Call function to remove the folders
        $summary = Remove-FoldersAndFiles -SolutionPath $basePath -FoldersToDelete $selectedFolders -LogFile $LogFile

        Write-SummaryToLog -Summary $summary -LogFile $LogFile -SolutionPath $basePath
    }
}
