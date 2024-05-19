function Set-MdtSetupOnVm {
    param (
        [string]$VMName,
        [PSCredential]$Credential,
        [string]$MDTDeploymentShareFolder,
        [string]$MDTDeploymentShareName,
        [string]$WDSRemoteInstallFolder
    )

    $scriptBlock = {
        param (
            [string]$MDTDeploymentShareFolder,
            [string]$MDTDeploymentShareName,
            [string]$WDSRemoteInstallFolder
        )

        net user /add SVC_MDT P@SSw0Rd!
        
        $MDTChocolateyApplications = @('7zip','adobereader','googlechrome','firefox','javaruntime','dotnet3.5','dotnet4.5')
        $ErrorActionPreference = 'Stop'

        Write-Output 'Setting up Scratch Folder'
        if (!(Test-Path -Path 'C:\temp')) {
            mkdir "C:\temp"
        } else {
            Write-Host "The given folder path C:\temp already exists"
        }
        mkdir "C:\temp\Drivers\x64_winpe10"
        mkdir "C:\temp\Drivers\Laptop"
        mkdir "C:\temp\Drivers\Desktop"
        mkdir "C:\temp\software\Windows Kits\10\ADK"

        try {
            Write-Output 'Adding Windows feature NET-Framework-Core'
            Add-WindowsFeature NET-Framework-Core

            Write-Output 'Adding Windows feature Windows Deployment System'
            Add-WindowsFeature WDS -IncludeManagementTools

            Write-Output 'Downloading Chocolatey Wrapper'
            Invoke-WebRequest 'https://raw.githubusercontent.com/keithga/DeployShared/master/Templates/Distribution/Scripts/Extras/Install-Chocolatey.ps1' -OutFile 'C:\temp\Install-Chocolatey.ps1'

            Write-Output 'Setting up MDT'
            mkdir $MDTDeploymentShareFolder
            $Share = [wmiClass]'Win32_Share'
            $Share.create($MDTDeploymentShareFolder, $MDTDeploymentShareName, 0)

            Import-Module 'C:\Program Files\Microsoft Deployment Toolkit\Bin\MicrosoftDeploymentToolkit.psd1' -Force
            New-PSDrive -Name 'DS001' -PSProvider 'MDTProvider' -Root $MDTDeploymentShareFolder -NetworkPath "\\$env:COMPUTERNAME\$MDTDeploymentShareName" -Description 'DeploymentShare' -Verbose | Add-MDTPersistentDrive -Verbose

            New-Item -Path 'DS001:\Operating Systems' -Enable 'True' -Name 'WIN11X64' -Comments '' -ItemType folder -Verbose
            New-Item -Path 'DS001:\Task Sequences' -Enable 'True' -Name 'WIN11X64' -Comments '' -ItemType folder -Verbose
            New-Item -Path 'DS001:\Out-of-Box Drivers' -Enable 'True' -Name 'WINPE' -Comments '' -ItemType folder -Verbose
            New-Item -Path 'DS001:\Out-of-Box Drivers' -Enable 'True' -Name 'DESKTOP' -Comments '' -ItemType folder -Verbose
            New-Item -Path 'DS001:\Out-of-Box Drivers' -Enable 'True' -Name 'LAPTOP' -Comments '' -ItemType folder -Verbose
            New-Item -Path 'DS001:\Packages' -Enable 'True' -Name 'WIN11X64' -Comments '' -ItemType folder -Verbose
            New-Item -Path 'DS001:\Selection Profiles' -Enable 'True' -Name 'WINPE' -Comments '' -Definition "<SelectionProfile><Include path=`"Out-of-Box Drivers\WINPE`" /></SelectionProfile>" -ReadOnly 'False' -Verbose
            New-Item -Path 'DS001:\Selection Profiles' -Enable 'True' -Name 'WIN11X64' -Comments '' -Definition "<SelectionProfile><Include path=`"Packages\WIN11X64`" /></SelectionProfile>" -ReadOnly 'False' -Verbose

            $MDTChocolateyApplications | ForEach-Object {
                $Package = $_
                $Path = "powershell.exe -NoProfile -ExecutionPolicy unrestricted `"%ScriptRoot%\Install-Chocolatey.ps1`" -Verbose -Packages `"$Package`""
                Import-MDTApplication -Path 'DS001:\Applications' -Name $Package -ShortName $Package -NoSource -CommandLine $Path -Enable $true
            }

            Copy-Item -Path 'C:\temp\Install-Chocolatey.ps1' -Destination "$MDTDeploymentShareFolder\Scripts"

            Add-Content "$MDTDeploymentShareFolder\control\Bootstrap.ini" "DeployRoot=\\$env:COMPUTERNAME\$MDTDeploymentShareName"
            Add-Content "$MDTDeploymentShareFolder\control\Bootstrap.ini" "UserID=$env:COMPUTERNAME\SVC_MDT"
            Add-Content "$MDTDeploymentShareFolder\control\Bootstrap.ini" "UserPassword=P@SSw0Rd!"
            Add-Content "$MDTDeploymentShareFolder\control\Bootstrap.ini" "KeyboardLocalePE=0813:00000813"
            Add-Content "$MDTDeploymentShareFolder\control\Bootstrap.ini" "KeyboardLocale=0813:00000813"
            Add-Content "$MDTDeploymentShareFolder\control\Bootstrap.ini" "KeyboardLocalePE=nl-BE"
            Add-Content "$MDTDeploymentShareFolder\control\Bootstrap.ini" "KeyboardLocale=nl-BE"
            Add-Content "$MDTDeploymentShareFolder\control\Bootstrap.ini" "SkipBDDWelcome=YES"

            Add-Content "$MDTDeploymentShareFolder\control\CustomSettings.ini" "[ByLaptopType]"
            Add-Content "$MDTDeploymentShareFolder\control\CustomSettings.ini" "Subsection=Laptop-%IsLaptop%"
            Add-Content "$MDTDeploymentShareFolder\control\CustomSettings.ini" "[ByDesktopType]"
            Add-Content "$MDTDeploymentShareFolder\control\CustomSettings.ini" "Subsection=Desktop-%IsDesktop%"
            Add-Content "$MDTDeploymentShareFolder\control\CustomSettings.ini" "[Laptop-True]"
            Add-Content "$MDTDeploymentShareFolder\control\CustomSettings.ini" "DriverGroup001=LAPTOP\%Model%"
            Add-Content "$MDTDeploymentShareFolder\control\CustomSettings.ini" "DriverSelectionProfile=nothing"
            Add-Content "$MDTDeploymentShareFolder\control\CustomSettings.ini" "[Desktop-True]"
            Add-Content "$MDTDeploymentShareFolder\control\CustomSettings.ini" "DriverGroup001=DESKTOP\%Model%"
            Add-Content "$MDTDeploymentShareFolder\control\CustomSettings.ini" "DriverSelectionProfile=nothing"
            Add-Content "$MDTDeploymentShareFolder\control\CustomSettings.ini" "[Virtual Machine]"
            Add-Content "$MDTDeploymentShareFolder\control\CustomSettings.ini" "DriverSelectionProfile=nothing"

            Import-MDTDriver -Path "DS001:\Out-of-Box Drivers\WINPE" -SourcePath "C:\temp\Drivers\x64_winpe10" -ImportDuplicates -Verbose

            Update-MDTDeploymentShare -Path 'DS001:' -Verbose

        } catch {
            Throw $_
        }
    }

    Invoke-Command -VMName $VMName -Credential $Credential -ScriptBlock $scriptBlock -ArgumentList $MDTDeploymentShareFolder, $MDTDeploymentShareName, $WDSRemoteInstallFolder
}

# Example usage
$vmCredential = Get-Credential -Message "Enter credentials for VM"
Set-MdtSetupOnVm -VMName "YourVMName" -Credential $vmCredential -MDTDeploymentShareFolder 'D:\DeploymentShare' -MDTDeploymentShareName 'DeploymentShare$' -WDSRemoteInstallFolder 'D:\RemoteInstall'
