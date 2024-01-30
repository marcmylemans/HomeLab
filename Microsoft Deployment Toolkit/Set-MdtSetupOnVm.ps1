function Set-MdtSetupOnVm {
    param (
        [string]$VMName,
        [PSCredential]$Credential,
        [string]$MDTDeploymentShareFolder,
        [string]$MDTDeploymentShareName,
        [string]$WDSRemoteInstallFolder
    )

    $scriptBlock = {
        # Place the contents of your MDT setup script here
        # Replace direct references to file paths and variables 
        # with parameters as needed
        # Example: using parameters like $args[0], $args[1] inside the script block

        # Here you would adapt your existing MDT setup script to work within this context.
        # Make sure to refer to arguments as $args[0], $args[1], etc., where needed.
    }

    # Execute the script block in the VM using PowerShell Direct
    Invoke-Command -VMName $VMName -Credential $Credential -ScriptBlock $scriptBlock -ArgumentList $MDTDeploymentShareFolder, $MDTDeploymentShareName, $WDSRemoteInstallFolder
}

# Example usage
$vmCredential = Get-Credential -Message "Enter credentials for VM"
Set-MdtSetupOnVm -VMName "YourVMName" -Credential $vmCredential -MDTDeploymentShareFolder 'D:\DeploymentShare' -MDTDeploymentShareName 'DeploymentShare$' -WDSRemoteInstallFolder 'D:\RemoteInstall'
