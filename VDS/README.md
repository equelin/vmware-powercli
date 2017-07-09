# Set-VDSInfrastructureTrafficResourceConfig

## SYNOPSIS
Configure shares parameters for system traffic with distributed switchs and Network I/O control.

## SYNTAX

```
Set-VDSInfrastructureTrafficResourceConfig [-VDS] <Object> -Type <String> -Share <String> [-Value <UInt32>]
 [-WhatIf] [-Confirm]
```

## DESCRIPTION
You can use Network I/O Control on a distributed switch to configure bandwidth allocation for the traffic that is related to the main system features in vSphere:
- Management
- Fault Tolerance
- iSCSI
- NFS
- Virtual SAN
- vMotion
- vSphere Replication
- vSphere Data Protection Backup
- Virtual machine
With this function you'll be able to configure shares for system traffic.
The amount of bandwidth available to a system traffic type is determined by its relative shares and by the amount of data that the other system features are transmitting.

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
Set-VDSInfrastructureTrafficResourceConfig.ps1 -VDS 'VDS01' -Type 'vsan' -Shares 'high'
```

Set the 'vsan' traffic resource config to 'normal'.

### -------------------------- EXAMPLE 2 --------------------------
```
Set-VDSInfrastructureTrafficResourceConfig.ps1 -VDS 'VDS01' -Type 'vsan' -Shares 'custom' -Value 150
```

Set the 'vsan' traffic resource config to a 'custom' value of 150.

### -------------------------- EXAMPLE 3 --------------------------
```
Get-VDSwitch -Name VDS01 | Set-VDSInfrastructureTrafficResourceConfig.ps1 -Type vdp -Shares low
```

Set the 'vdp' traffic resource config to 'low' by providing the VDS through a pipeline.

## PARAMETERS

### -VDS
VDS name or object.

```yaml
Type: Object
Parameter Sets: (All)
Aliases: 

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Type
Traffic type (management, vmotion, vsan...).

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Share
Shares (low, normal, high or custom).

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Value
Value of th custom share.

```yaml
Type: UInt32
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

## INPUTS

## OUTPUTS

## NOTES
Written by Erwan Quelin under MIT licence.

## RELATED LINKS

