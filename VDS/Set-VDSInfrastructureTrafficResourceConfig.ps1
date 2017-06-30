<#
    .SYNOPSIS 
    Configure system traffic ressource.
    .NOTES
    Written by Erwan Quelin under MIT licence.
    .PARAMETER VDS
    VDS name or object.
    .PARAMETER Type
    Traffic type (management, vmotion, vsan...).
    .PARAMETER Shares
    Shares (low, normal, high).
    .EXAMPLE
    .\Set-VDSInfrastructureTrafficResourceConfig.ps1 -VDS 'VDS01' -Type 'vsan' -Shares 'high'

    Set the 'vsan' traffic resource config to 'normal'.
    .EXAMPLE
    Get-VDSwitch -Name VDS01 | .\Set-VDSInfrastructureTrafficResourceConfig.ps1 -Type vdp -Shares low

    Set the 'vdp' traffic resource config to 'low' by providing the VDS through a pipeline. 
#>

[CmdletBinding(SupportsShouldProcess = $True,ConfirmImpact = 'High')] Param (
    [Parameter(Position=0,Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
    [Object]$VDS,
    [ValidateSet('management','faultTolerance','vmotion','virtualMachine','iSCSI','nfs','hbr','vsan','vdp')]
    [String]$Type,
    [ValidateSet('low','normal','high')]
    [String]$Share
)

Switch ($VDS.GetType().Name) {
    'String' {$VDS = Get-VDSwitch -Name $VDS -ErrorAction SilentlyContinue}
    'VmwareVDSwitchImpl' {$VDS = $VDS}
    default {Throw 'Please provide an valid VDS name or object'} }

If (Get-VDSwitch -Name $VDS.Name -ErrorAction SilentlyContinue) {

    #Creates DVSConfigSpec object
    $DVSConfigSpec = New-Object vmware.vim.DVSConfigSpec

    #Retrieves actual config version of the VDS
    $DVSConfigSpec.ConfigVersion = $VDS.ExtensionData.Config.ConfigVersion

    #Retrieves actual configuration
    $DVSConfigSpec.InfrastructureTrafficResourceConfig = $VDS.ExtensionData.Config.InfrastructureTrafficResourceConfig

    #Modify the traffic resource config with informations provided by parameters
    ($DVSConfigSpec.InfrastructureTrafficResourceConfig | where-object {$_.key -match $Type}).AllocationInfo.Shares.Level = $Share

    #Reconfigure the DVS
    If ($pscmdlet.ShouldProcess($VDS.Name,"Modify traffic $Type with value $Share")) {
        Try {
            $VDS.ExtensionData.ReconfigureDvs($DVSConfigSpec)
        }
        Catch {
            Throw $_
        }
    }
    
    #Return VDS object
    Get-VDSwitch -Name $VDS.Name
}