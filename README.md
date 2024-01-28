# Hyper-V Automation Project

## Overview
This project automates the setup of Hyper-V virtual machines (VMs), including the creation of a domain controller, the configuration of Remote Desktop Services (RDS), and setting up VMs from a template. The project uses PowerShell scripts and a JSON configuration file for customization. Currently, the script requires manual input for 'domain admin' credentials during execution. Post-script completion, users must manually integrate their certificates.

## Prerequisites
- Windows Server equipped with the Hyper-V role.
- PowerShell 5.1 or above.
- Administrative rights on the Hyper-V host.
- A sysprepped template VHD created as the base image for all new VMs.
- An answer file embedded in the VHD ***with the same username/password*** as specified in the JSON file for consistent authentication. (https://www.windowsafg.com/)

## Configuration
Edit the `config.json` file to set up your environment. It should include:

- VM names, IPs.
- Domain controller configuration.
- RDS setup details.
- VM template paths.
- Network configurations.

Example:
```json
{
    "VMs": [
        {"Name": "dc1", "IP": "192.168.48.10"},
        {"Name": "rdgw", "IP": "192.168.48.11"},
        {"Name": "rds1", "IP": "192.168.48.12"},
        {"Name": "rds2", "IP": "192.168.48.13"}
    ],
    "DomainController": "dc1",
    "TemplateVHDXPath": "C:\\Hyper-V\\Virtual Hard Disks\\Templates\\template_server2019.vhdx",
    "VMStoragePath": "C:\\Hyper-V\\Virtual Machines",
    "VMSwitch": "vSwitch",
    "DomainName": "homelab.local",
    "AdminUsername": "Administrator",
    "AdminPassword": "Azerty123!",
    "SubnetMask": 24,
    "Gateway": "192.168.48.254",
    "DNS": "192.168.48.10",
    "RDS": {
        "connectionBrokerVM": "dc1",
        "ConnectionBroker": "rdgw.homelab.local",
        "WebAccessServer": "rdgw.homelab.local",
        "SessionHost": "rds1.homelab.local",
        "LicenseServer": "rdgw.homelab.local",
        "HostRemoteApp": "rds2.homelab.local",
        "GatewayExternalFqdn": "rdgw.homelab.com",
        "SessionCollectionName": "RDS Host",
        "RemoteAppCollectionName": "RDS Remote App",
        "UserGroupSession": ["homelab\\domain users", "homelab\\domain admins"],
        "UserGroupRemoteApp": ["homelab\\domain users", "homelab\\domain admins"]
    }
}
```

## Scripts

- New-VMFromTemplate.ps1: Creates a new VM from a specified VHDX template.
- Configure-VMNetwork.ps1: Configures the network settings for a VM.
- Set-VMStaticIP.ps1: Sets a static IP for a VM.
- Setup-DomainController.ps1: Sets up the domain controller.
- Join-Domain.ps1: Joins VMs to the domain.
- Set-RDSConfiguration.ps1: Configures Remote Desktop Services.

## Usage

Download this repo and unzip it (for example c:\temp)
# Navigate to the folder
Open PowerShell as an administrator.
Run the cd command provided by the script output to navigate to the extracted folder.

For Example:

```powershell
cd 'C:\temp'
```

# Set execution policy to Unrestricted for the current session

```powershell
Set-ExecutionPolicy Unrestricted -Scope Process -Force
```

# Unblock all files in the folder

```powershell
Get-ChildItem | Unblock-File
```powershell

# Note: At this point, you can execute your scripts or commands in the unblocked environment
The main script:

```powershell
rds_lab.ps1
```

## Main Script

The main script orchestrates the creation and configuration of VMs:

1) Creates all VMs from the template.
2) Sets up network configurations for each VM.
3) Initializes the domain controller.
4) Joins VMs to the domain.
5) Configures RDS settings.

## Security

- Credentials: The script uses administrator credentials for several operations. Ensure these are securely managed.
- Answer File: If using an answer file for automated Windows installations, handle it securely.

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
