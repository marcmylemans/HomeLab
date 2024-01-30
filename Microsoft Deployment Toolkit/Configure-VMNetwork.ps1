function Configure-VMNetwork {
    param (
        [string]$VMName,
        [string]$VMSwitch,
        [PSCredential]$VMCredential
    )
    Connect-VMNetworkAdapter -VMName $VMName -SwitchName $VMSwitch
}
