<#
.SYNOPSIS
  Set the number of required heartbeat datastores per host.
.DESCRIPTION
  Set the number of required heartbeat datastores per host.
  You have to be connected on a host or a vCenter.
.EXAMPLE
  .\Set-HAheartbeatDsPerHost.ps1 -Cluster (Get-Cluster CLUSTER01) -heartbeatDsPerHost 4

 Set the number of required heartbeat datastores per host to 4.
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
  $Cluster = (Get-Cluster),

  # Number of required heartbeat datastores per host.
  [Parameter(Mandatory=$false)]
  [ValidateRange(2,5)]
  [int]$heartbeatDsPerHost = 2
)


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
   
    if($Cl) {

        $Cl | New-AdvancedSetting -Type ClusterHA -Name 'das.heartbeatDsPerHost' -Value $heartbeatDsPerHost -force -Confirm:$false | Out-Null

        Write-Output $Cl

    } else {
      Write-Warning -Message "Cluster does not exist or HA is not enabled"
    }   
  }
}