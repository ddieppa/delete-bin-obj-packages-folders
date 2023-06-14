# CleanUp Folders PowerShell Script

This README file provides a guide for using the `CleanUp Folders PowerShell Script`, a simple and effective way to delete unwanted folders such as `bin`, `obj`, and `packages` from a specified directory. The script takes user input to choose the folders to be deleted and creates a log file to track the process. This guide includes instructions for running the script using the `CleanUpFolders.bat` file on Windows and the actual script file named `delete_folders.ps1`.

## Prerequisites

To run this script, you will need:

- PowerShell 3.0 or higher installed on your system.
- The script assumes that you have a working .NET solution with `bin`, `obj`, and `packages` folders, and you have the necessary permissions to delete files and folders.

## Usage

### Option 1: Using the CleanUpFolders.bat file

1. Navigate to the folder where the `delete_folders.ps1` and `CleanUpFolders.bat` files are located.

2. Double-click the `CleanUpFolders.bat` file to run the script.

3. A new PowerShell window will open, and you will be prompted to enter the base path of your .NET solution. Enter the path and press Enter.

```powershell
Enter the base path of your .NET solution: [Path_to_your_solution_folder]
```

4. The script will display a list of folder types to delete: `bin`, `obj`, and `packages`. Enter the numbers corresponding to your choices, separated by commas.

```powershell
Select the types of directories to delete:[1.bin, 2.obj, 3.packages]
Enter the numbers corresponding to your choices, separated by commas: 1,2
```

**Note:** If you press Enter without selecting any folder, the script will default to deleting both `bin` and `obj` folders.

5. Follow steps 5 to 6 from the "Option 2: Using PowerShell directly" section below.

### Option 2: Using PowerShell directly

1. Open **PowerShell** in the folder where the `delete_folders.ps1` script is located.

2. To run the script, type the following command:

```powershell
.\delete_folders.ps1
```

3. Follow steps 3 to 6 from the "Option 1: Using the CleanUpFolders.bat file" section above.

## Log File

The `RemovalLog.txt` file is created and updated during the script execution. It contains the following details:

- Timestamps for when files and folders were deleted.
- The name of the deleted files and folders.
- Summary of the total number of deleted folders and files for each folder type.

## Troubleshooting

- If the script shows an error message saying "The specified path does not exist," make sure you provided a valid solution path and had the necessary permissions.
- If no folders are deleted, check that you correctly entered the numbers corresponding to your choices as shown in the Usage section.

## Conclusion

You have now successfully run the `CleanUp Folders PowerShell Script` using either the `CleanUpFolders.bat` file or the PowerShell terminal directly. This is a convenient and straightforward way to keep your .NET solution tidy and clean by removing unwanted `bin`, `obj`, and `packages` folders. Feel free to customize the script to suit your needs.