<#
.SYNOPSIS
  Add Isolation addresses advanced settings to a cluster. 
.DESCRIPTION
  Add Isolation addresses advanced settings to a cluster. 
  You have to be connected on a host or a vCenter.
.EXAMPLE
  .\Set-HAIsolationAddress.ps1 -Cluster (Get-Cluster CLUSTER01) -isolationaddress 192.168.0.1,192.168.0.2,192.168.0.3,192.168.0.4 -usedefaultisolationaddress $false

 Add the specified IP as Isolation addresses.
.LINK
  https://github.com/equelin/vmware-powercli
.NOTES
  ===========================================================================
    Created on:    10/04/2016 02:00 PM
    Created by:    Erwan Quelin
    Twitter:       @erwanquelin
    Github:        https://github.com/equelin
  ===========================================================================
#>

[CmdletBinding()]
Param (
  # Cluster name or object.
  [Parameter(Mandatory=$true,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
  $Cluster,

  # List of IP addresses used as isolation address targets.
  [Parameter(Mandatory=$true)]
  [ipaddress[]]$isolationaddress,

  # Set the value to the advanced parameters 'usedefaultisolationaddress'
  [Parameter(Mandatory=$false)]
  [bool]$usedefaultisolationaddress = $false,

  # If true, update the existing configuration, if false delete the configuration.
  [switch]$Update
)

Begin {
  $isolationaddressName = 'das.isolationaddress'
}

Process {

  foreach ($Cl in $Cluster) {

    Switch ($Cl.GetType().Name) {
      'ClusterImpl' {
        $Cl = $Cl
      }
      'String' {
        $Cl = Get-Cluster -Name $Cl -ErrorAction SilentlyContinue   
      }
    }
   
    if(($Cl) -and ($Cl.HAEnabled)){

      #Delete existing das.isolationaddress advanced settings ?
      If ((-not $Update) -and ($OldAdvancedSettings = $Cl | Get-AdvancedSetting -Name 'das.isolationaddress*' -ErrorAction SilentlyContinue)) {
        
        Write-Verbose -Message 'Delete existing advanced settings'
        $OldAdvancedSettings | Remove-AdvancedSetting -Confirm:$false | Out-Null
      }

      For ($i=0; $i -lt $isolationaddress.count; $i++) {
        
        $AdvancedSetting = $isolationaddressName + $i

        Write-Verbose -Message " Add advanced settings Name: $AdvancedSetting Value: $isolationaddress[$i]" 
        $Cl | New-AdvancedSetting -Type ClusterHA -Name $AdvancedSetting -Value $isolationaddress[$i] -force -Confirm:$false | Out-Null
      }

      # Set das.usedefaultisolationaddress
      $Cl | New-AdvancedSetting -Type ClusterHA -Name 'das.usedefaultisolationaddress' -Value $usedefaultisolationaddress -force -Confirm:$false | Out-Null

    } else {
      Write-Warning -Message "Cluster does not exist or HA is not enabled"
    }   
  }
}