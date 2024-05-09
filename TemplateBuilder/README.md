# Automated Setup of Hyper-V VHD(X) from an ISO

This script automates the creation of Hyper-V VHD(X) from an ISO file. It also imports the Unattend.xml into the VHD(X).

## Description
The script provided here automates the process of converting a Windows Server ISO to a VHD(X) using the `Convert-WindowsImage.ps1` script. Additionally, it injects an `unattend.xml` file into the VHD(X) for automated setup.

## Notes
- **Version:** 1.0.0
- **Author:** Marc Mylemans
- **Creation Date:** 09/05/2024
- **Purpose/Change:** Initial script development for automated VHD(X) templates. It uses the Convert-WindowsImage project [Convert-WindowsImage](https://github.com/x0nn/Convert-WindowsImage).

## Example
To run the script, execute the following command in PowerShell:

```powershell
.\main.ps1
```

## Prerequisites
Ensure the following prerequisites are met before running the script:

PowerShell 5.1 or later
Windows Server ISO file
Convert-WindowsImage.ps1 script from Convert-WindowsImage
Valid unattend.xml file for automated setup

##  Variables
Adjust the following variables in the script as per your environment:

- **$isoPath:** Path to the Windows Server ISO file.
- **$vhdPath:** Path where the resulting VHD(X) will be saved.
- **$unattendPath:** Path to the unattend.xml file.
- **$Edition:** Edition of Windows Server to be installed (e.g., "Windows Server 2022 Standard (Desktop Experience)"). If omitted and more than one image is available, all images are listed.
