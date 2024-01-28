function Set-VMStaticIP {
    param (
        [string]$VMName,
        [string]$IP,
        [int]$SubnetMask,
        [string]$Gateway,
        [string]$DNS,
        [PSCredential]$VMCredential
    )

    $scriptBlock = {
        # Get the first active network adapter
        $adapter = Get-NetAdapter | Where-Object { $_.Status -eq 'Up' } | Select-Object -First 1

        if ($adapter) {
            $interfaceAlias = $adapter.Name
            New-NetIPAddress -InterfaceAlias $interfaceAlias -IPAddress $using:IP -PrefixLength $using:SubnetMask -DefaultGateway $using:Gateway
            Set-DnsClientServerAddress -InterfaceAlias $interfaceAlias -ServerAddresses $using:DNS
        } else {
            Write-Error "No active network interface found."
        }
    }

    Invoke-Command -VMName $VMName -Credential $VMCredential -ScriptBlock $scriptBlock
}

# Usage Example
# Set-VMStaticIP -VMName "YourVMName" -IP "192.168.1.100" -SubnetMask 24 -Gateway "192.168.1.1" -DNS "192.168.1.1" -VMCredential $adminCredential
