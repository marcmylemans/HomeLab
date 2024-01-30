function Rename-VM {
    param (
        [string]$VMName,
        [string]$NewName,
        [PSCredential]$VMCredential
    )

    Write-Host "Renaming VM $VMName to $NewName"

    $scriptBlock = {
        Rename-Computer -NewName $using:NewName -Restart
    }
    Invoke-Command -VMName $VMName -Credential $VMCredential -ScriptBlock $scriptBlock
}
