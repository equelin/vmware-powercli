
<#	
	.NOTES
	===========================================================================
	 Created on:   	10/27/2015 9:25 PM
	 Created by:   	Brian Graf
     Twitter:       @vBrianGraf
     VMware Blog:   blogs.vmware.com/powercli
     Personal Blog: www.vtagion.com

     Modified on:  	10/04/2016 02:00 PM
     Modified by:  	Erwan Quelin
     Twitter:       @erwanquelin
     Github:        https://github.com/equelin
    ===========================================================================
	.DESCRIPTION
    This function will allow users to view the VMCP settings for their clusters

    .Example
    Get-VMCPSettings -cluster LAB-CL

    This will show you the VMCP settings for the cluster LAB-CL

    .Example
    Get-Cluster | Get-VMCPSettings

    This will show you the VMCP settings for all the clusters
#>
[CmdletBinding()]
param (

    #Cluster name or object
    [Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True,HelpMessage='What is the Cluster Name?')]
    $cluster
)

Process {

    Foreach ($Clus in $Cluster) {

        # Determine input and convert to ClusterImpl object
        Switch ($Clus.GetType().Name)
        {
            "string" {$CL = Get-Cluster $Clus}
            "ClusterImpl" {$CL = $Clus}
        }

        # Work with the Cluster View
        $ClusterMod = Get-View -Id "ClusterComputeResource-$($cl.ExtensionData.MoRef.Value)"

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



