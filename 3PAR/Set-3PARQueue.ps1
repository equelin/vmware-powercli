<#
.SYNOPSIS
  Configure ESXi queue
.DESCRIPTION
  Configure ESXi queue
  PowerCLI Session must be connected to vCenter Server using Connect-VIServer
.LINK
  https://github.com/equelin/vmware-powercli
.PARAMETER VMHost
  VMWare vSPhere ESXi host provided for example with command Get-VMHost
.PARAMETER QFullSampleSize
  Queue full sample size
.PARAMETER QFullThreshold
  Queue full threshold
.EXAMPLE
  Get-VMHost | Set-3PARQueue -QFullSampleSize 32 -QFullThreshold 4

 Setup the queue for all hosts available.
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
  $VMHost = (Get-VMHost),
  [Parameter(Mandatory=$false)]
  [Uint32]$QFullSampleSize = 32,
  [Parameter(Mandatory=$false)]
  [Uint32]$QFullThreshold = 4
)

Process {

  foreach ($ESXi in $VMHost) {

    Write-Verbose "[$ESXi] Configuring host queue"

    If ($pscmdlet.ShouldProcess($ESXi,"Configuring host queue")) {
      $ESXi | Set-VMHostAdvancedConfiguration -NameValue @{'Disk.QFullSampleSize'= $QFullSampleSize;'Disk.QFullThreshold'= $QFullThreshold}
    }

  }
}

