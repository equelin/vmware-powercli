<#	
.NOTES
===========================================================================
    Created on:   	10/27/2015 9:25 PM
    Created by:   	Brian Graf
    Twitter:        @vBrianGraf
    VMware Blog:    blogs.vmware.com/powercli
    Personal Blog:  www.vtagion.com

    Modified on:   	10/04/2016 02:00 PM
    Modified by:   	Erwan Quelin
    Twitter:        @erwanquelin
    Github:         https://github.com/equelin
===========================================================================

.DESCRIPTION
This function will allow users to enable/disable VMCP and also allow
them to configure the additional VMCP settings
For each parameter, users should use the 'Tab' button to auto-fill the
possible values.

.Example
Set-VMCPSettings -cluster LAB-CL -enableVMCP:$True -VmStorageProtectionForPDL `
restartAggressive -VmStorageProtectionForAPD restartAggressive `
-VmTerminateDelayForAPDSec 2000 -VmReactionOnAPDCleared reset

This will enable VMCP and configure the Settings 

.Example
Set-VMCPSettings -cluster LAB-CL -enableVMCP:$False -VmStorageProtectionForPDL `
disabled -VmStorageProtectionForAPD disabled `
-VmTerminateDelayForAPDSec 600 -VmReactionOnAPDCleared none 

This will disable VMCP and configure the Settings
#>

 [CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact="High")]
  param (
    
    #Cluster name or object
    [Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True,HelpMessage='What is the Cluster Name?')]
    $cluster,
    
    #Enable VMCP
    [Parameter(Mandatory=$false,ValueFromPipeline=$False,HelpMessage='True=Enabled False=Disabled')]
    [bool]$enableVMCP = $false,

    #Response to a PDL event
    [Parameter(Mandatory=$false,ValueFromPipeline=$False,HelpMessage='Actions that can be taken in response to a PDL event')]
    [ValidateSet("disabled","warning","restartAggressive")]
    [string]$VmStorageProtectionForPDL = 'disabled',

    #Response to an APD event
    [Parameter(Mandatory=$false,ValueFromPipeline=$False,HelpMessage='Options available for an APD response')]
    [ValidateSet("disabled","restartConservative","restartAggressive","warning")]
    [string]$VmStorageProtectionForAPD = 'disabled',
    
    #VM Terminate delay for APD (in seconds)
    [Parameter(Mandatory=$false,ValueFromPipeline=$False,HelpMessage='Value in seconds')]
    [Int]$VmTerminateDelayForAPDSec = 180,
    
    #VM reaction on APD cleared
    [Parameter(Mandatory=$false,ValueFromPipeline=$False,HelpMessage='This setting will instruct vSphere HA to take a certain action if an APD event is cleared')][ValidateSet("reset","none")]
    [string]$VmReactionOnAPDCleared = 'none'
  )

Process {

    Foreach ($Clus in $Cluster) {

        # Determine input and convert to ClusterImpl object
        Switch ($Clus.GetType().Name)
        {
            "string" {$CL = Get-Cluster $Clus}
            "ClusterImpl" {$CL = $Clus}
        }

        # Create the object we will configure
        $settings = New-Object VMware.Vim.ClusterConfigSpecEx
        $settings.dasConfig = New-Object VMware.Vim.ClusterDasConfigInfo
        
        # Based on $enableVMCP switch 
        if ($enableVMCP -eq $false)  { 
            $settings.dasConfig.vmComponentProtecting = "disabled"
        } 
        elseif ($enableVMCP -eq $true) { 
            $settings.dasConfig.vmComponentProtecting = "enabled" 
        }  

        #Create the VMCP object to work with
        $settings.dasConfig.defaultVmSettings = New-Object VMware.Vim.ClusterDasVmSettings
        $settings.dasConfig.defaultVmSettings.vmComponentProtectionSettings = New-Object VMware.Vim.ClusterVmComponentProtectionSettings

        #Storage Protection For PDL
        $settings.dasConfig.defaultVmSettings.vmComponentProtectionSettings.vmStorageProtectionForPDL = "$VmStorageProtectionForPDL"

        #Storage Protection for APD
        switch ($VmStorageProtectionForAPD) {
            "disabled" {
                # If Disabled, there is no need to set the Timeout Value
                $settings.dasConfig.defaultVmSettings.vmComponentProtectionSettings.vmStorageProtectionForAPD = 'disabled'
                $settings.dasConfig.defaultVmSettings.vmComponentProtectionSettings.enableAPDTimeoutForHosts = $false
            }

            "restartConservative" {
                $settings.dasConfig.defaultVmSettings.vmComponentProtectionSettings.vmStorageProtectionForAPD = 'restartConservative'
                $settings.dasConfig.defaultVmSettings.vmComponentProtectionSettings.enableAPDTimeoutForHosts = $true
                $settings.dasConfig.defaultVmSettings.vmComponentProtectionSettings.vmTerminateDelayForAPDSec = $VmTerminateDelayForAPDSec
            }

            "restartAggressive" {
                $settings.dasConfig.defaultVmSettings.vmComponentProtectionSettings.vmStorageProtectionForAPD = 'restartAggressive'
                $settings.dasConfig.defaultVmSettings.vmComponentProtectionSettings.enableAPDTimeoutForHosts = $true
                $settings.dasConfig.defaultVmSettings.vmComponentProtectionSettings.vmTerminateDelayForAPDSec = $VmTerminateDelayForAPDSec
            }

            "warning" {
                # If Warning, there is no need to set the Timeout Value
                $settings.dasConfig.defaultVmSettings.vmComponentProtectionSettings.vmStorageProtectionForAPD = 'warning'
                $settings.dasConfig.defaultVmSettings.vmComponentProtectionSettings.enableAPDTimeoutForHosts = $false
            }

        }

        # Reaction On APD Cleared
        $settings.dasConfig.defaultVmSettings.vmComponentProtectionSettings.vmReactionOnAPDCleared = "$VmReactionOnAPDCleared"

        # Execute API Call
        $modify = $true
        $ClusterMod = Get-View -Id "ClusterComputeResource-$($cl.ExtensionData.MoRef.Value)"

        If ($pscmdlet.ShouldProcess($Cl.Name,"Modify VMCP configuration")) {
            $ClusterMod.ReconfigureComputeResource_Task($settings, $modify) | out-null
        }

        # Update variable data after API call
        $ClusterMod.updateViewData()

        # Create Hashtable with desired properties to return
        $properties = [ordered]@{
        'Cluster' = $ClusterMod.Name;
        'VMCP Status' = $clustermod.Configuration.DasConfig.VmComponentProtecting;
        'Protection For APD' = $clustermod.Configuration.DasConfig.DefaultVmSettings.VmComponentProtectionSettings.VmStorageProtectionForAPD;
        'APD Timeout Enabled' = $clustermod.Configuration.DasConfig.DefaultVmSettings.VmComponentProtectionSettings.EnableAPDTimeoutForHosts;
        'APD Timeout (Seconds)' = $clustermod.Configuration.DasConfig.DefaultVmSettings.VmComponentProtectionSettings.VmTerminateDelayForAPDSec;
        'Reaction on APD Cleared' = $clustermod.Configuration.DasConfig.DefaultVmSettings.VmComponentProtectionSettings.VmReactionOnAPDCleared;
        'Protection For PDL' = $clustermod.Configuration.DasConfig.DefaultVmSettings.VmComponentProtectionSettings.VmStorageProtectionForPDL
        }

        # Create PSObject with the Hashtable
        $object = New-Object -TypeName PSObject -Prop $properties

        # Show object
        return $object
    }
}


