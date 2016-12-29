#
# Run with: Invoke-Pester
#

# Allow Powershell Scripts to run
Set-ExecutionPolicy RemoteSigned

Describe "Directory C:\scripts" {
  It "Should Exist" {
    $ScriptsDirectory = "C:\scripts"
    $ScriptsDirectory | Should Exist
  }
}

Describe "Git" {
  It "Is Installed" {
    $Output = Get-ItemProperty HKLM:\Software\GitForWindows
    $Output.PSChildName | Should Be "GitForWindows"
  }
}

Describe "AWSTools" {
  $Output = Get-WmiObject -Query "SELECT * FROM win32_product WHERE name like '%AWS Tools%'"

  It "Is Installed" {
    $Output.Name    | Should Be "AWS Tools for Windows"
  }

  #It "Is Correct Version" {
  #  $Output.Version | Should Be "3.9.598.0"
  #}
}

