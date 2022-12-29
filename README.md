## CGM Ping Checks

A fun project to check the availability status of various systems. If a system fails a configured amount of checks then it will be added to the list of systems to report on via email notification from an Office365 account.

### Required Setup

Passphrase for Office355 account `cgminput` must be stored in a file called "specpass.txt" in the same directory as the script. The passphrase is in LastPass, folder "COE IT CGM".

```powershell
#Store encrypted password for cgmsurvey@ucdavis.edu (User ID: cgminput) in secure file
Read-Host -AsSecureString | ConvertFrom-SecureString | Out-File .\specpass.txt
```
