<#
    .SYNOPSIS
        Automated setup of Hyper-V VHD(X) from an ISO.
    .DESCRIPTION
        This script automates the creation of Hyper-V VHD(x) from an ISO file. 
        It also imports the Unattend.xml into the VHD(X).
    .NOTES
        Version:        1.0.0
        Author:         Marc Mylemans
        Creation Date:  09/05/2024
        Purpose/Change: Initial script development for automated vhd(x) templates. It uses the Convert-WindowsImage project https://github.com/x0nn/Convert-WindowsImage.
    .EXAMPLE
        .\main.ps1
#>

#-----------------------------Error Action-------------------------------
$ErrorActionPreference = 'silentlycontinue'

#-----------------------------Variables----------------------------------
$isoPath = "D:\ISO\SW_DVD9_Win_Server_STD_CORE_2022_2108.7_64Bit_English_DC_STD_MLF_X23-09508.ISO"
$vhdPath = "D:\HyperV\Templates\WindowsServer2022Template.vhdx"
$unattendPath = "C:\HomeLab-main\TemplateBuilder\Unattend.xml"
$Edition = "Windows Server 2022 Standard (Desktop Experience)"



#-----------------------------Check Script Prerequisites-----------------
$scriptPath = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
$functionFiles = @("Convert-WindowsImage.ps1")

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

#-----------------------------Main Script Logic--------------------------

# Convert ISO to VHD using Convert-WindowsImage.ps1

Convert-WindowsImage -SourcePath $isoPath -VHDFormat "VHDX" -DiskLayout "UEFI" -Edition $Edition  -VHDPath $vhdPath -SizeBytes 64GB -UnattendPath "$unattendPath" -Feature "NetFx3"
Write-Output "VHD creation and customization complete. VHD is located at $vhdPath"


