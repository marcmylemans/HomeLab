function New-VMFromTemplate {
    param (
        [string]$VMName,
        [string]$TemplateVHDXPath,
        [string]$VMStoragePath,
        [string]$VMRAM = "1GB",
        [int]$VMProcessor = 2
    )
    # Constructing the path for the new VHDX
    $VMFolderPath = Join-Path -Path $VMStoragePath -ChildPath $VMName
    $NewVHDXPath = Join-Path -Path $VMFolderPath -ChildPath "$VMName.vhdx"


    # Ensure the VM folder exists
    if (-not (Test-Path -Path $VMFolderPath)) {
        New-Item -Path $VMFolderPath -ItemType Directory
    }

    # Copy the VHDX template to the new location
    if (Test-Path -Path $TemplateVHDXPath) {
        Copy-Item -Path $TemplateVHDXPath -Destination $NewVHDXPath
    } else {
        Write-Error "Template VHDX not found at path: $TemplateVHDXPath"
        return
    }

    $RAMInBytes = [System.Convert]::ToInt64((Invoke-Expression $VMRAM.Replace('GB', '*1GB').Replace('MB', '*1MB').Replace('KB', '*1KB')))

    New-VM -Name $VMName -MemoryStartupBytes $RAMInBytes -Path $VMFolderPath -Generation 2
    Set-VMProcessor -VMName $VMName -Count $VMProcessor
    Add-VMHardDiskDrive -VMName $VMName -Path $NewVHDXPath
}
