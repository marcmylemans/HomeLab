function Join-Domain {
    param (
        [PSCustomObject]$config,
        [PSCredential]$domainCredential
    )

    $domainName = $config.DomainName
    $dcName = $config.DomainController


    foreach ($vmConfig in $config.VMs) {
        if ($vmConfig.Name -ne $dcName) {
            $VMFullName = "$($vmConfig.Name)"
            Write-Host "Joining $VMFullName to the domain $domainName"

            $scriptBlock = {
                param ($domain, $credential)
                Add-Computer -DomainName $domain -Credential $credential -Force -Restart
            }

            Invoke-Command -VMName $VMFullName -Credential $domainCredential -ScriptBlock $scriptBlock -ArgumentList $domainName, $domainCredential
        }
    }
}
