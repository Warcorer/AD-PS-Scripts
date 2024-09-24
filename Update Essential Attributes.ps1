# Import the Active Directory module
Import-Module ActiveDirectory

function Update-ADUserAttributes {
    param (
        [Parameter(Mandatory=$true)]
        [string]$currentUsername,
        
        [Parameter(Mandatory=$true)]
        [string]$newGivenName,
        
        [Parameter(Mandatory=$true)]
        [string]$newSurname,
        
        [Parameter(Mandatory=$true)]
        [string]$newEmail,
        
        [Parameter(Mandatory=$true)]
        [string]$newSamAccountName,
        
        [switch]$Verbose,
        [switch]$Debug
    )

    # Automatically set the DisplayName to "GivenName Surname"
    $newDisplayName = "$newGivenName $newSurname"

    # Display the inputted information
    Write-Host "Current Username: $currentUsername"
    Write-Host "First Name: $newGivenName"
    Write-Host "Last Name: $newSurname"
    Write-Host "Display Name: $newDisplayName"
    Write-Host "Email Address: $newEmail"
    Write-Host "sAMAccountName: $newSamAccountName"
    Write-Host "UserPrincipalName: $newEmail"
    Write-Host "Proxy Address: smtp:$newEmail"

    # Confirm the information
    $confirmation = Read-Host "Is this information correct? (yes/no)"

    switch ($confirmation.ToLower()) {
        "yes" {
            try {
                # Rename the user and update the cn attribute
                $user = Get-ADUser -Identity $currentUsername -ErrorAction Stop
                Rename-ADObject -Identity $user.DistinguishedName -NewName $newSamAccountName -ErrorAction Stop

                # Update the user's attributes
                Set-ADUser -Identity $newSamAccountName -GivenName $newGivenName -Surname $newSurname -DisplayName $newDisplayName -EmailAddress $newEmail -UserPrincipalName $newEmail -Add @{ProxyAddresses="smtp:$newEmail"} -SamAccountName $newSamAccountName -Replace @{cn=$newSamAccountName} -ErrorAction Stop

                Write-Host "User's attributes have been updated successfully." -Verbose:$Verbose -Debug:$Debug

                # Optional: Log the changes
                $logMessage = "Updated username from $currentUsername to $newSamAccountName with new attributes: GivenName=$newGivenName, Surname=$newSurname, DisplayName=$newDisplayName, Email=$newEmail"
                Add-Content -Path "C:\Logs\ADUserUpdates.log" -Value $logMessage

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

# Prompt for the new attributes
$newGivenName = Read-Host "Enter the user's first name"
$newSurname = Read-Host "Enter the user's last name"
$newEmail = Read-Host "Enter the new email address (this will also be used for UserPrincipalName and ProxyAddress)"
$newSamAccountName = Read-Host "Enter the new sAMAccountName"

# Call the function to update the user's attributes
Update-ADUserAttributes -currentUsername $currentUsername -newGivenName $newGivenName -newSurname $newSurname -newEmail $newEmail -newSamAccountName $newSamAccountName -Verbose -Debug