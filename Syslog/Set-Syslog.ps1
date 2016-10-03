<#
.SYNOPSIS
  Syslog configuration on VMware ESXi hosts.
.DESCRIPTION
  SSH configuration on VMware ESXi hosts.
  You have to be connected on a host or a vCenter.
.LINK
  http://blog.okcomputer.io
.PARAMETER VMHost
  VMWare vSPhere ESXi host provided for example with command Get-VMHost
.PARAMETER SyslogServer
  IP or FQDN of the syslog server
.PARAMETER StartService
  Start the Syslog service
.PARAMETER StopService
  Stop the Syslog service
.PARAMETER EnableFirewallException
  Open syslog ports
.PARAMETER DisableFirewallException
  Close syslog ports
.EXAMPLE
Get-VMHost | Set-Syslog -SyslogServer udp://192.168.0.1:513

 Configure syslog service for all hosts
#>

[CmdletBinding()]
Param (
  [Parameter(Mandatory=$false,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
  $VMHost = (Get-VMHost),
  [Parameter(Mandatory=$False)]
  [String]$SyslogServer,
  [Parameter(Mandatory=$False)]
  [switch]$StartService,
  [Parameter(Mandatory=$False)]
  [switch]$StopService,
  [Parameter(Mandatory=$False)]
  [switch]$EnableFirewallException,
  [Parameter(Mandatory=$False)]
  [switch]$DisableFirewallException
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

      Write-Verbose "Configuring Syslog on: $($ESXi.Name)"

      If ($PSBoundParameters.ContainsKey('SyslogServer')) {
        Write-Verbose "*** Configuring Syslog advanced parameters"
        $ESXi | Get-AdvancedSetting -Name 'Config.HostAgent.log.level' | Set-AdvancedSetting -Value 'info' -Confirm:$false | Out-Null
        $ESXi | Get-AdvancedSetting -Name 'Vpx.Vpxa.config.log.level' | Set-AdvancedSetting -Value 'info' -Confirm:$false | Out-Null
        $ESXi | Get-AdvancedSetting -Name 'Syslog.global.logHost' | Set-AdvancedSetting -Value $SyslogServer -Confirm:$false | Out-Null

        If ($ESXi.version -ge '6.0.0') {
          Write-Verbose "*** Restarting syslog service" 
          $ESXi | Get-VMHostService | where {$_.Key -eq "vmsyslogd"} | Restart-VMHostService -Confirm:$false | Out-Null
        }
      }

      If ($PSBoundParameters.ContainsKey('StartService')) {
        If ($ESXi.version -ge '6.0.0') {
          Write-Verbose "*** Start syslog service" 
          $ESXi | Get-VMHostService | where {$_.Key -eq "vmsyslogd"} | Start-VMHostService -Confirm:$false  | Out-Null
        }
      }

      If ($PSBoundParameters.ContainsKey('StopService')) {
        If ($ESXi.version -ge '6.0.0') {
          Write-Verbose "*** Stop syslog service" 
          $ESXi | Get-VMHostService | where {$_.Key -eq "vmsyslogd"} | Stop-VMHostService -Confirm:$false  | Out-Null
        }
      }

      If ($PSBoundParameters.ContainsKey('EnableFirewallException')) {
        Write-Verbose "*** Enabling firewall exception" 
        $ESXi | Get-VMHostFirewallException -name syslog | Set-VMHostFirewallException -Enabled $true | Out-Null
      }

      If ($PSBoundParameters.ContainsKey('DisableFirewallException')) {
        Write-Verbose "*** Disabling firewall exception" 
        $ESXi | Get-VMHostFirewallException -name syslog | Set-VMHostFirewallException -Enabled $false | Out-Null
      }

      Write-Output $ESXi
    } else {
      Write-Warning -Message "Host does not exist"
    }
  }
}
