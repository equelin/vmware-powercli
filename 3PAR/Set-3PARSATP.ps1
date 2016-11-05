<#
.SYNOPSIS
  Configure ESXi with best practices for 3PAR array
.DESCRIPTION
  Configure ESXi with best practices for 3PAR array
  PowerCLI Session must be connected to vCenter Server using Connect-VIServer
.LINK
  https://github.com/equelin/vmware-powercli
.PARAMETER VMHost
  VMWare vSPhere ESXi host provided for example with command Get-VMHost
.EXAMPLE
  Get-VMHost | Set-3PARSATP

 Setup the SATP configuration for all hosts available.
.NOTES
  ===========================================================================
    Created on:    11/04/2016 08:00 AM
    Created by:    Erwan Quelin
    Twitter:       @erwanquelin
    Github:        https://github.com/equelin
  ===========================================================================
#>

[CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact="High")]
Param (
  [Parameter(Mandatory=$false,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
  $VMHost = (Get-VMHost)
)

Process {

  foreach ($ESXi in $VMHost) {
    $esxcli = get-vmhost $ESXi | Get-EsxCli
    Write-Verbose "[$ESXi] Configuring SATP for HP 3PAR SAN array"

    If ($pscmdlet.ShouldProcess($ESXi,"Configuring SATP for HP 3PAR SAN array")) {
      $result = $esxcli.storage.nmp.satp.rule.add($null,"tpgs_on","HP 3PAR Custom iSCSI/FC/FCoE ALUA Rule",$null,$null,$null,"VV",$null,"VMW_PSP_RR","iops=1","VMW_SATP_ALUA",$null,$null,"3PARdata")
    }

    If ($result) {
      Write-Verbose "[$ESXi] Modification applied: $result"
      $esxcli.storage.nmp.satp.rule.list() | where {$_.description -like "*3par*"}
    }
  }

}
