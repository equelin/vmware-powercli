<#
.SYNOPSIS
  Migrating roles and privileges between vCenters
.DESCRIPTION
  Migrating roles and privileges between vCenters
  PowerCLI Session must be connected to both vCenter Server using Connect-VIServer
.LINK
  https://github.com/equelin/vmware-powercli
.PARAMETER VISource
  Source vCenter
.PARAMETER VITarget
  Target vCenter
.EXAMPLE
  .\Copy-VIRole.ps1 -VISource 'vcenter1.example.com' -VITarget 'vcenter2.example.com'

 Copy roles and privileges from vCenter1 to vCenter2
.NOTES
  ===========================================================================
    Created on:    11/07/2016 08:00 AM
    Created by:    Erwan Quelin
    Twitter:       @erwanquelin
    Github:        https://github.com/equelin
    Inspired by:   http://www.thelowercasew.com/migrating-roles-privileges-from-an-old-vcenter-to-a-new-vcenter-using-powercli
  ===========================================================================
#>

[CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact="High")]
Param (
  [Parameter(Mandatory=$true)]
  $VISource,
  [Parameter(Mandatory=$true)]
  $VITarget
)

Process {

    # Get roles to transfer
    $Roles = Get-VIRole -server $VISource
    
    # Get role Privileges
    foreach ($Role in $Roles) {

        Write-Verbose "Processing role $($role.Name)"

        [string[]]$privsforRoleAfromVISource=Get-VIPrivilege -Role (Get-VIRole -Name $role -server $VISource) |%{$_.id}
    
        If (-not (Get-VIRole -server $VITarget -Name $Role.Name -ErrorAction SilentlyContinue)) {
            If ($pscmdlet.ShouldProcess($VITarget,"Creating VI Role $($Role.Name)")) {
                # Create new role in VITarget
                New-VIRole -name $Role.Name -Server $VITarget
                
                # Add Privileges to new role.
                Set-VIRole -role (get-virole -Name $Role -Server $VITarget) -AddPrivilege (get-viprivilege -id $privsforRoleAfromVISource -server $VITarget)
            }
        } else {
            Write-Verbose "Role already exists on the target vCenter"
        }
    }
}

