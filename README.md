## CGM Ping Checks

A fun project to check the availabilty status of various system. If a system fails a configured amount of checks then it will be added to the list of systems to report on via email notification from an Office365 account.

### Required Setup

Passphrase for Office355 account must stored in a file called "specpass.txt" in the same directory as the script.

```powershell
#Store encrypted password in secure file
Read-Host -AsSecureString | ConvertFrom-SecureString | Out-File .\specpass.txt
```
