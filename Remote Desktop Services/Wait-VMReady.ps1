function Wait-VMReady {
    param (
        [string]$VMName,
        [PSCredential]$VMCredential,
        [int]$TimeoutSeconds = 300
    )

    $startTime = Get-Date
    $isAccessible = $false

    Write-Host "Waiting for VM $VMName to become accessible..."

    while ((Get-Date) -lt $startTime.AddSeconds($TimeoutSeconds)) {
        try {
            # Attempt a simple PowerShell Direct command
            $null = Invoke-Command -VMName $VMName -Credential $VMCredential -ScriptBlock { $true } -ErrorAction Stop
            $isAccessible = $true
            Write-Host "VM $VMName is accessible."
            break
        } catch {
            # Wait for a short interval before retrying
            Start-Sleep -Seconds 10
        }
    }

    if (-not $isAccessible) {
        Write-Host "Timeout reached. VM $VMName is still not accessible."
    }

    return $isAccessible
}
