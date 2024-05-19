# Hyper-V Automation Project

## Overview
This function automates the setup of a Microsoft Deployment Toolkit (MDT) environment on a specified Hyper-V virtual machine (VM). The function performs various tasks including setting up MDT, configuring Windows Deployment Services (WDS), and importing necessary drivers and applications using Chocolatey. The setup is customizable through parameters and can be executed remotely on the VM using PowerShell Direct.

## Prerequisites
- Hyper-V host with the VM running Windows Server.
- PowerShell 5.1 or above.
- Administrative rights on the VM.
- Network connectivity to download scripts and software.

## Parameters
- **VMName**: The name of the Hyper-V virtual machine.
- **Credential**: PSCredential object for administrative access to the VM.
- **MDTDeploymentShareFolder**: Path to the MDT deployment share folder on the VM.
- **MDTDeploymentShareName**: Name of the MDT deployment share.
- **WDSRemoteInstallFolder**: Path to the WDS remote install folder on the VM.


## Configuration
Edit the `config.json` file to set up your environment. It should include:

- VM names, IPs.
- Domain controller configuration.
- MDT setup details.
- VM template paths.
- Network configurations.

Example:
```json
{
    "VMs": [
        {"Name": "dc1", "IP": "192.168.48.10"},
        {"Name": "mdt1", "IP": "192.168.48.31"}
    ],
    "DomainController": "dc1",
    "TemplateVHDXPath": "C:\\Hyper-V\\Virtual Hard Disks\\Templates\\template_server2019.vhdx",
    "VMStoragePath": "C:\\Hyper-V\\Virtual Machines",
    "VMSwitch": "Default Switch",
    "DomainName": "homelab.local",
    "AdminUsername": "Administrator",
    "AdminPassword": "Azerty123!",
    "SubnetMask": 24,
    "Gateway": "192.168.48.254",
    "DNS": "192.168.48.10",
    "mdt": {
        "vmName": "mdt1",
        "MDTDeploymentShareFolder": "D:\\DeploymentShare",
        "MDTDeploymentShareName": "DeploymentShare$",
        "WDSRemoteInstallFolder": "D:\\RemoteInstall",
        "MDTChocolateyApplications": ["7zip", "adobereader", "googlechrome", "firefox", "javaruntime", "dotnet3.5", "dotnet4.5"],
        "AdminUsername": "Administrator",
        "AdminPassword": "YourAdminPassword"
    }
}
```

## Scripts

- New-VMFromTemplate.ps1: Creates a new VM from a specified VHDX template.
- Configure-VMNetwork.ps1: Configures the network settings for a VM.
- Set-VMStaticIP.ps1: Sets a static IP for a VM.
- Setup-DomainController.ps1: Sets up the domain controller.
- Join-Domain.ps1: Joins VMs to the domain.
- Set-MdtSetupOnVm.ps1: Configures Microsoft Deployment Toolkit and Windows Deployment Server.

## Usage

Download this repo and unzip it (for example c:\temp)
# Navigate to the folder
Open PowerShell as an administrator.
Run the cd command provided by the script output to navigate to the extracted folder.

For Example:

```powershell
cd 'C:\HomeLab-main\Microsoft Deployment Toolkit'
```

# Set execution policy to Unrestricted for the current session

```powershell
Set-ExecutionPolicy Unrestricted -Scope Process -Force
```

# Unblock all files in the folder

```powershell
Get-ChildItem | Unblock-File
```

# Note: At this point, you can execute your scripts or commands in the unblocked environment
The main script:

```powershell
main.ps1
```

## Main Script

The main script orchestrates the creation and configuration of VMs:

1) Creates all VMs from the template.
2) Sets up network configurations for each VM.
3) Initializes the domain controller.
4) Joins VMs to the domain.
5) Configures MDT settings.

## Security

- Credentials: The script uses administrator credentials for several operations. Ensure these are securely managed.

## Testing

Test the scripts in a controlled environment before deploying them in a production setting.

## License

MIT License

Copyright (c) 2024 Marc Mylemans

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.


## Contributing

Contributions to this project are welcome. Please fork the repository and submit a pull request.

## Authors
Marc Mylemans

## Acknowledgments

This section is reserved for acknowledging future contributors, inspirations, and sources of help. Contributions to this project are highly appreciated and will be duly recognized here.

- **Contributors**: A special thanks to those who contribute to the development and improvement of this project.
- **Inspirations**: Acknowledgment of any projects, articles, or forums that have inspired or provided valuable information for this project.
- **Community Support**: Gratitude to the community members who provide support, suggestions, and feedback.

_If you have contributed to this project and wish to be acknowledged here, please let us know._



For detailed information about each script and configuration settings, refer to the comments within each file.
