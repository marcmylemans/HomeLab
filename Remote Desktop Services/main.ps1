<#
    .SYNOPSIS
        Automated setup of Hyper-V VMs and Remote Desktop Services Configuration.
    .DESCRIPTION
        This script automates the creation and configuration of Hyper-V VMs based on a provided JSON configuration file. 
        It also sets up a Remote Desktop Services environment on these VMs. Requires separate function scripts and a config.json file.
    .NOTES
        Version:        1.0.0
        Author:         Marc Mylemans
        Creation Date:  13/01/2024
        Purpose/Change: Initial script development for automated VM and RDS setup.
    .EXAMPLE
        .\rds_lab.ps1
#>

#-----------------------------Error Action-------------------------------
$ErrorActionPreference = 'silentlycontinue'

#-----------------------------Variables----------------------------------
$scriptPath = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
$functionFiles = @("Setup-DomainController.ps1", "Wait-VMReady.ps1", "Join-Domain.ps1", "Rename-VM.ps1", "Set-RDSConfiguration.ps1", "New-VMFromTemplate.ps1", "Configure-VMNetwork.ps1", "Set-VMStaticIP.ps1")
$configFilePath = Join-Path -Path $scriptPath -ChildPath "config.json"

#-----------------------------Check Script Prerequisites-----------------

# Check if all function files exist
foreach ($file in $functionFiles) {
    $fullPath = Join-Path -Path $scriptPath -ChildPath $file
    if (-not (Test-Path -Path $fullPath)) {
        Write-Error "Required script file not found: $fullPath"
        exit
    }
}

# Dot Source the Functions
foreach ($file in $functionFiles) {
    . (Join-Path -Path $scriptPath -ChildPath $file)
}

# Check if config file exists
if (-not (Test-Path -Path $configFilePath)) {
    Write-Error "Configuration file not found: $configFilePath"
    exit
}

# Load Config from JSON File
$config = Get-Content $configFilePath | ConvertFrom-Json

#-----------------------------Main Script Logic--------------------------

# Create admin credentials from JSON config
$adminUsername = $config.AdminUsername
$adminPassword = ConvertTo-SecureString $config.AdminPassword -AsPlainText -Force
$adminCredential = New-Object System.Management.Automation.PSCredential ($adminUsername, $adminPassword)

# Create domainadmin credentials from JSON config
$domainadminUsername = "homelab\administrator"
$adminPassword = ConvertTo-SecureString $config.AdminPassword -AsPlainText -Force
$domainadminCredential = New-Object System.Management.Automation.PSCredential ($domainadminUsername, $adminPassword)

# VM Creation for All VMs
# VM Creation and Configuration for All VMs
$domainName = $config.DomainName
foreach ($vmConfig in $config.VMs) {
    $VMFullName = "$($vmConfig.Name)"
    New-VMFromTemplate -VMName $VMFullName -TemplateVHDXPath $config.TemplateVHDXPath -VMStoragePath $config.VMStoragePath -VMRAM "1GB" -VMProcessor 2
    Start-VM -Name $VMFullName

    # Wait for VM to become accessible
    if (-not (Wait-VMReady -VMName $VMFullName -VMCredential $adminCredential)) {
        Write-Host "Unable to configure $VMFullName, VM not accessible."
        continue
    }

    
    Configure-VMNetwork -VMName $VMFullName -VMSwitch $config.VMSwitch -VMCredential $adminCredential
    Set-VMStaticIP -VMName $VMFullName -IP $vmConfig.IP -SubnetMask $config.SubnetMask -Gateway $config.Gateway -DNS $config.DNS -VMCredential $adminCredential
    
    # Rename VM if necessary
    $expectedVMName = "$($vmConfig.Name)"
    Rename-VM -VMName $VMFullName -NewName $expectedVMName -VMCredential $adminCredential

}




# Setup Domain Controller
# Wait for VM to become accessible
    if (-not (Wait-VMReady -VMName $config.DomainController -VMCredential $adminCredential)) {
        Write-Host "Unable to configure $VMFullName, VM not accessible."
        continue
    }
Setup-DomainController -domainController $config.DomainController -domainName $config.DomainName -vmCredential $adminCredential

Start-Sleep -Seconds 180

Join-Domain -config $config -domainCredential $adminCredential


# Remote Desktop Services Configuration
$rdsConfig = $config.RDS
Set-RDSConfiguration -rdsConfig $rdsConfig -domainCredential $domainadminCredential
