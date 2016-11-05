<#
.SYNOPSIS
 SSH configuration on VMware ESXi hosts.
.DESCRIPTION
  SSH configuration on VMware ESXi hosts.
  You have to be connected on a host or a vCenter
.LINK
  https://github.com/equelin/vmware-powercli
.PARAMETER VMHost
  VMWare vSPhere ESXi host provided for example with command Get-VMHost.
.PARAMETER StartService
  Start the SSH service
.PARAMETER StopService
  Stop the SSH service
.PARAMETER EnableWarning
  Enable SSH Warning
.PARAMETER DisableWarning
  Disable SSH Warning
.PARAMETER Policy
  SSH Policy. Might be:
  - On
  - Off
  - Auto
.EXAMPLE
  Get-VMHost | Set-SSH -Policy On -StartService -DisableWarning

  Configure SSH service
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
  [Parameter(Mandatory=$false,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
  $VMHost = (Get-VMHost),
  [Parameter(Mandatory=$False)]
  [ValidateSet('on','off','auto')]
  [String]$Policy,
  [Parameter(Mandatory=$False)]
  [switch]$StartService,
  [Parameter(Mandatory=$False)]
  [switch]$StopService,
  [Parameter(Mandatory=$False)]
  [switch]$EnableWarning,
  [Parameter(Mandatory=$False)]
  [switch]$DisableWarning

)
Process {

  foreach ($VMH in $VMHost) {

    Switch ($VMH.GetType().Name) {
      'VMHostImpl' {
        $ESXi = $VMH
      }
      'String' {
        $ESXi = Get-VMHost -Name $VMH -ErrorAction SilentlyContinue   
      }
    }

    If ($ESXi) {
        Write-Verbose "Configuring SSH on: $($ESXi.Name)"

        If ($PSBoundParameters.ContainsKey('Policy')) {
          Write-Verbose "*** Configuring SSH activation policy" 
          $ESXi | Get-VMHostService | where{$_.Key -eq "TSM-SSH"} | Set-VMHostService -policy $policy -Confirm:$false  | Out-Null
        }

        If ($PSBoundParameters.ContainsKey('StartService')) {
          Write-Verbose "*** Start SSH service" 
          $ESXi | Get-VMHostService | where{$_.Key -eq "TSM-SSH"} | Start-VMHostService -Confirm:$false  | Out-Null
        }

        If ($PSBoundParameters.ContainsKey('StopService')) {
          Write-Verbose "*** Stop SSH service" 
          $ESXi | Get-VMHostService | where{$_.Key -eq "TSM-SSH"} | Stop-VMHostService -Confirm:$false  | Out-Null
        }

        If ($PSBoundParameters.ContainsKey('EnableWarning')) {
          Write-Verbose "*** Enable SSH warning" 
          $ESXi | Get-AdvancedSetting -Name 'UserVars.SuppressShellWarning' | Set-AdvancedSetting -Value '0' -Confirm:$false  | Out-Null
        }

        If ($PSBoundParameters.ContainsKey('DisableWarning')) {
          Write-Verbose "*** Disable SSH warning" 
          $ESXi | Get-AdvancedSetting -Name 'UserVars.SuppressShellWarning' | Set-AdvancedSetting -Value '1' -Confirm:$false  | Out-Null
        }

        Write-Output $ESXi
    } else {
      Write-Warning -Message "Host does not exist"
    }
  }
}
