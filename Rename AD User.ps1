# Import the Active Directory module
Import-Module ActiveDirectory

function Rename-ADUser {
    param (
        [Parameter(Mandatory=$true)]
        [string]$currentUsername,
        
        [Parameter(Mandatory=$true)]
        [string]$newUsername,
        
        [switch]$Verbose,
        [switch]$Debug
    )

    # Display the inputted information
    Write-Host "Current Username: $currentUsername"
    Write-Host "New Username: $newUsername"

    # Confirm the information
    $confirmation = Read-Host "Is this information correct? (yes/no)"

    switch ($confirmation.ToLower()) {
        "yes" {
            try {
                # Rename the user
                $user = Get-ADUser -Identity $currentUsername -ErrorAction Stop
                Rename-ADObject -Identity $user.DistinguishedName -NewName $newUsername -ErrorAction Stop

                Write-Host "User has been renamed successfully." -Verbose:$Verbose -Debug:$Debug

                # Optional: Log the changes
                $logMessage = "Renamed user from $currentUsername to $newUsername"
                Add-Content -Path "C:\Logs\ADUserRenames.log" -Value $logMessage

            } catch {
                Write-Host "An error occurred: $_" -ForegroundColor Red
            }
        }
        "no" {
            Write-Host "Operation cancelled."
        }
        default {
            Write-Host "Invalid input. Operation cancelled."
        }
    }
}

# Prompt for the user's current username (sAMAccountName)
$currentUsername = Read-Host "Enter the current username"

# Prompt for the new username
$newUsername = Read-Host "Enter the new username"

# Call the function to rename the user
Rename-ADUser -currentUsername $currentUsername -newUsername $newUsername -Verbose -Debug