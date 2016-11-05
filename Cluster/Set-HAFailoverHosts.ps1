<#
.SYNOPSIS
  Select dedicated HA failover hosts.
.DESCRIPTION
  Select dedicated HA failover hosts.
  You have to be connected on a host or a vCenter.
.EXAMPLE
  .\Set-HAFailoverHosts.ps1 -Cluster (Get-Cluster CLUSTER01) -VMHost (Get-VMHost ESX01)

 Select VMHost ESXi as a dedicated host for HA for the cluster CLUSTER01.
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

  #Cluster name or object
  [Parameter(Mandatory=$true,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
  $Cluster,

  #Host name or object
  [Parameter(Mandatory=$true)]
  $VMHost
)

Process {
  Switch ($Cluster.GetType().Name) {
    'ClusterImpl' {
      $Clus = $Cluster
    }
    'String' {
      $Clus = Get-Cluster -Name $Cluster -ErrorAction SilentlyContinue   
    }
  }
  
  if($Clus){

    Try {
      $esxMoRef = $Clus | Get-VMHost $VMHost -ErrorAction Stop | %{$_.ExtensionData.MoRef}
    }

    Catch {
      Throw "Can't get informations on host. Please check if the host exist and if it's part of the cluster." 
    }

    $spec = New-Object VMware.Vim.ClusterConfigSpec
    $spec.DasConfig = New-Object VMware.Vim.ClusterDasConfigInfo
    $spec.DasConfig.Enabled = $true
    $spec.DasConfig.AdmissionControlPolicy = New-Object VMware.Vim.ClusterFailoverHostAdmissionControlPolicy
    $spec.DasConfig.AdmissionControlPolicy.failoverHosts = $esxMoRef

    $Clus.ExtensionData.ReconfigureCluster($spec,$true)
  } else {
    Write-Warning -Message "Cluster does not exist"
  }
}