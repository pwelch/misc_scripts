# Requires -RunAsAdministrator
#
# Provision Windows VM
#
# If updating packages, use 'Get-WmiObject Win32_Product' to get new ProductID
#

# Allow Powershell Scripts to run
Set-ExecutionPolicy RemoteSigned

$CurrentDir     = (Get-Item -Path ".\" -Verbose).FullName
$ScriptLocation = "$CurrentDir"

# load sensitive info from .secrets.josn
#if ((Test-Path "$ScriptLocation\.secrets.json") -ne $True) {
# Write-Host "Please add the .secrets.json file"
# Break
#}
# $Secrets        = Get-Content -Raw -Path .secrets.json | ConvertFrom-Json

## PowerShell DSC Provision
# https://msdn.microsoft.com/en-us/powershell/dsc/builtinresource
Configuration Provisioner {
  Import-DscResource -ModuleName PSDesiredStateConfiguration

  Node localhost {
    File ScriptsDirectory {
      Type            = "Directory"
      DestinationPath = "$Env:SystemDrive\scripts"
      Ensure          = "Present"
    }
  }
}

# Enable this to avoid 'The client cannot connect to the destination specified in the request.'
# Run without on Windows Servers to see if its an issue.
Enable-PSRemoting -SkipNetworkProfileCheck

# Compile the configuration file to a MOF format
Provisioner

# Run the configuration on localhost
Start-DscConfiguration -Path ".\Provisioner" -Wait -Force -Verbose

## Finish Provisioning with Chocolatey
# Install required packages
$chocoPackages = @('sysinternals', 'awstools.powershell', 'awscli', 'googlechrome', 'chefdk', 'notepadplusplus.install', 'python')

# Install Chocolatey package manager
function Install-Choco {
  if ((Test-Path "C:\ProgramData\Chocolatey") -eq $True) {
    echo "Chocolatey already installed. Moving on... `n"
  }
  else {
    echo "Chocolately not found. Installing... `n"
    iwr https://chocolatey.org/install.ps1 -UseBasicParsing | iex
  }
}
# Install Chocolatey packages
function Install-Packages {
  foreach ($pkg in $chocoPackages) {
    echo "Installing choco package: $pkg `n"
    choco install $pkg --yes
  }
}

Install-Choco
Install-Packages

# Disable PSRemoting if not needed
# Disable-PSRemoting
