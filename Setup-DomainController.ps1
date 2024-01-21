function Setup-DomainController {
    param (
        [PSCustomObject]$domainController,
        [string]$domainName,
        [PSCredential]$vmCredential
    )


    # Install AD DS Role and Promote to Domain Controller
    $scriptBlock = {
        Install-WindowsFeature AD-Domain-Services -IncludeManagementTools
        Import-Module ADDSDeployment
        Install-ADDSForest -DomainName $using:domainName -InstallDns -SafeModeAdministratorPassword $using:vmCredential.Password -Force -Confirm:$false
    }

    # Run the script block inside the VM using PowerShell Direct
    Invoke-Command -VMName $domainController -Credential $vmCredential -ScriptBlock $scriptBlock
}

# Example call to the function (use appropriate parameters)
# $adminCredential = Get-Credential -Message "Enter domain admin credentials"
# Setup-DomainController -domainController $config.DomainController -domainName $config.DomainName -vmCredential $adminCredential