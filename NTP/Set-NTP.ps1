<#
.SYNOPSIS
  Set de NTP configuration on VMware ESXi hosts.
.DESCRIPTION
  Set de NTP configuration on VMware ESXi hosts.
  You have to be connected on a host or a vCenter.
.LINK
  https://github.com/equelin/vmware-powercli
.PARAMETER VMHost
  VMWare vSPhere ESXi host provided for example with command Get-VMHost
.PARAMETER Policy
  NTP Policy. Might be:
  - On
  - Off
  - Auto
.PARAMETER NtpServer
  NTP server's list
.PARAMETER StartService
  Start the SSH service
.PARAMETER StopService
  Stop the SSH service
.EXAMPLE
  Get-VMHost | Set-NTP -NtpServer 192.168.1.1 -Policy On -StartService

 Setup the NTP services on all VMhosts provided by the Get-VMHost command.
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
  [Parameter(Mandatory=$false)]
  [String[]]$NtpServer,
  [Parameter(Mandatory=$false)]
  [ValidateSet('on','off','auto')]
  [String]$Policy,
  [Parameter(Mandatory=$False)]
  [switch]$StartService,
  [Parameter(Mandatory=$False)]
  [switch]$StopService
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
      Write-Verbose "Configuring NTP on: $($ESXi.Name)"

      If ($PSBoundParameters.ContainsKey('NtpServer')) {
        Write-Verbose "*** Setting Time" 
        $ESXi | %{(Get-View $_.ExtensionData.configManager.DateTimeSystem).UpdateDateTime((Get-Date -format u)) }

        $VMHostNtpServer = Get-VMHostNtpServer $ESXi

        If ($VMHostNtpServer) {
          Write-Verbose "*** Removing old NTP Servers" 
          $ESXi | Remove-VMHostNtpServer -NtpServer $VMHostNtpServer -Confirm:$false | Out-Null
        }
        
        Write-Verbose "*** Adding new NTP Servers $NtpServer" 
        $ESXi | Add-VMHostNTPServer -NtpServer $NtpServer -Confirm:$false -ErrorAction SilentlyContinue | Out-Null
      }


      If ($PSBoundParameters.ContainsKey('Policy')) {
        Write-Verbose "*** Setting NTP Client Policy to $Policy" 
        $ESXi | Get-VMHostService | where{$_.Key -eq "ntpd"} | Set-VMHostService -policy $Policy -Confirm:$false | Out-Null
      }

      If ($PSBoundParameters.ContainsKey('StartService')) {
        Write-Verbose "*** Start NTP service" 
        $ESXi | Get-VMHostService | where{$_.Key -eq "ntpd"} | Start-VMHostService -Confirm:$false  | Out-Null
      }

      If ($PSBoundParameters.ContainsKey('StopService')) {
        Write-Verbose "*** Stop NTP service" 
        $ESXi | Get-VMHostService | where{$_.Key -eq "ntpd"} | Stop-VMHostService -Confirm:$false  | Out-Null
      }

      Write-Verbose "*** Restarting NTP Client" 
      $ESXi | Get-VMHostService | where{$_.Key -eq "ntpd"} | Restart-VMHostService -Confirm:$false | Out-Null

      Write-Output $ESXi
    } else {
      Write-Warning -Message "Host does not exist"
    }
  }
}
