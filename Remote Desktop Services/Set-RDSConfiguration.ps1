function Set-RDSConfiguration {
    param (
        [PSCustomObject]$rdsConfig,
        [PSCredential]$VMCredential
    )

    $scriptBlock = {
        param ($rdsConfig)

        Import-Module RemoteDesktop

        # Create RDS Session
        New-RDSessionDeployment -ConnectionBroker $rdsConfig.ConnectionBroker `
                                -WebAccessServer $rdsConfig.WebAccessServer `
                                -SessionHost $rdsConfig.SessionHost -Verbose

        # Add Licensing Server
        Add-RDServer -Server $rdsConfig.LicenseServer -Role RDS-LICENSING -ConnectionBroker $rdsConfig.ConnectionBroker
        Set-RDLicenseConfiguration -LicenseServer $rdsConfig.LicenseServer -Mode PerUser -Force -ConnectionBroker $rdsConfig.ConnectionBroker

        # Add Second RDS Server for Remote_App
        Add-RDServer -Server $rdsConfig.HostRemoteApp -Role RDS-RD-SERVER -ConnectionBroker $rdsConfig.ConnectionBroker

        # Add RDS Collections
        New-RDSessionCollection -CollectionName $rdsConfig.SessionCollectionName -SessionHost $rdsConfig.SessionHost `
                                -CollectionDescription "This Collection is for Desktop Sessions" `
                                -ConnectionBroker $rdsConfig.ConnectionBroker

        New-RDSessionCollection -CollectionName $rdsConfig.RemoteAppCollectionName -SessionHost $rdsConfig.HostRemoteApp `
                                -CollectionDescription "This Collection is for RemoteApps" `
                                -ConnectionBroker $rdsConfig.ConnectionBroker

        # Configure Session Collections
        Set-RDSessionCollectionConfiguration -CollectionName $rdsConfig.SessionCollectionName -UserGroup $rdsConfig.UserGroupSession
        Set-RDSessionCollectionConfiguration -CollectionName $rdsConfig.RemoteAppCollectionName -UserGroup $rdsConfig.UserGroupRemoteApp

        # Configure RD Gateway
        Add-RDServer -Server $rdsConfig.WebAccessServer -Role RDS-Gateway -ConnectionBroker $rdsConfig.ConnectionBroker `
                     -GatewayExternalFqdn $rdsConfig.GatewayExternalFqdn
    }

    # Assuming the Connection Broker is the VM where you want to run these commands
    $connectionBrokerVM = "$($rdsConfig.connectionBrokerVM)"
    Invoke-Command -VMName $connectionBrokerVM -Credential $VMCredential -ScriptBlock $scriptBlock -ArgumentList $rdsConfig
}
