<#
.SYNOPSIS
  Set HA failover ressources in percentage.
.DESCRIPTION
  Set HA failover ressources in percentage.
  You have to be connected on a host or a vCenter.
.EXAMPLE
  .\Set-HAFailoverResourcesPercent.ps1 -Cluster (Get-Cluster CLUSTER01) -percentCPU 50 -percentMem 50

 Set HA failover ressources in percentage fr cluster CLUSTER01
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
  [Parameter(Mandatory=$false,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
  $Cluster = (Get-Cluster),

  # CPU reservation percentage
  [Parameter(Mandatory=$false)]
  [int]$percentCPU = 25,

  # Memory reservation percentage
  [Parameter(Mandatory=$false)]
  [int]$percentMem = 25
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
   
    if($Cl){

        $spec = New-Object VMware.Vim.ClusterConfigSpecEx
        $spec.dasConfig = New-Object VMware.Vim.ClusterDasConfigInfo
        $spec.dasConfig.admissionControlPolicy = New-Object VMware.Vim.ClusterFailoverResourcesAdmissionControlPolicy
        $spec.dasConfig.admissionControlPolicy.cpuFailoverResourcesPercent = $percentCPU
        $spec.dasConfig.admissionControlPolicy.memoryFailoverResourcesPercent = $percentMem

        $Cl = Get-View $Cl
        $Cl.ReconfigureComputeResource_Task($spec, $true)
    } else {
      Write-Warning -Message "Cluster does not exist"
    }   
  }
}