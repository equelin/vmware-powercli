<#

.SYNOPSIS
Add hosts to a vCenter. Read the data from a CVS file

#>

[CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact="High")]
Param (
  [Parameter(Mandatory=$True)]
  [string]$username,
  [Parameter(Mandatory=$False)]
  [string]$password,
  [Parameter(Mandatory=$True)]
  [string]$datacenter,
  [Parameter(Mandatory=$False)]
  [string]$csv = '.\hosts.csv'
)

Process {
  If (-not $password) {
    # Prompt for root password
    $secpasswd = read-host "Enter root password" -AsSecureString
  } else {
    $secpasswd = ConvertTo-SecureString $password -AsPlainText -Force
  }
  
  # Create the PSCredential object
  $PSCredential = New-Object System.Management.Automation.PSCredential ($username, $secpasswd)

  # Import CSV
  $srvs = Import-Csv -Path $csv -Delimiter ","

  foreach ($srv in $srvs) {
    $name = $srv.name

    Write-Verbose "Verification if host $name is already managed by the vCenter" 

    #Test if host already exist
    If ((Get-VMHost -Name $name -ErrorAction SilentlyContinue)-eq $null){
      Write-Verbose "$name does not exist in the vCenter, add it"
      If ($pscmdlet.ShouldProcess($name,"Add host")) { 
        Add-VMHost $name -Location (Get-Datacenter $Datacenter) -Credential $PSCredential -RunAsync -force:$true
      }
    } else {
      Write-Verbose "$name does exist in the vCenter, skip it..."
    }
  }
}


