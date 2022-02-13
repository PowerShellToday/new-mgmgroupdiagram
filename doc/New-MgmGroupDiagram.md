---
external help file: MgmGroupDiagram-help.xml
Module Name: MgmGroupDiagram
online version: https://www.diagrams.net/blog/insert-from-csv
https://jgraph.github.io/drawio-tools/tools/csv.html
schema: 2.0.0
---

# New-MgmGroupDiagram

## SYNOPSIS
Export Azure managementgroups and subscriptions in a hierarchy view as CSV-data that can be used with https://www.diagrams.net/

## SYNTAX

```
New-MgmGroupDiagram [[-TemplatePath] <String>] [-ExcludeDefinition] [-ExpandSubscriptions]
 [-IncludeSubscriptionDetails] [-IncludeManagementGroupRoles] [[-MgmGroupExtraRoleProperties] <String[]>]
 [<CommonParameters>]
```

## DESCRIPTION
Export Azure managementgroups and subscriptions in a hierarchy view as CSV-data that can be used with https://www.diagrams.net/
Generates data that can be used as showcased at https://www.diagrams.net/blog/insert-from-csv

The function uses default azure-context

## EXAMPLES

### EXAMPLE 1
```
New-MgmGroupDiagram


#label: %DisplayName%
#stylename: type
#styles: {"AzManagementGroup": "label;image=img/lib/azure2/general/Management_Groups.svg;whiteSpace=wrap;html=1;rounded=1; fillColor=%fill%;strokeColor=#6c8ebf;fillColor=#dae8fc;points=\[\[0.5,0,0,0,0\],\[0.5,1,0,0,0\]\];",\
#"AzSubscription": "label;image=img/lib/azure2/general/Subscriptions.svg;whiteSpace=wrap;html=1;rounded=1; fillColor=%fill%;strokeColor=#d6b656;fillColor=#fff2cc;points=\[\[0.5,0,0,0,0\],\[0.5,1,0,0,0\]\];imageWidth=26;"}
#
#
#namespace: csvimport-
#
#connect: {"from": "ParentId", "to": "Id", "invert": true, "style": "curved=1;endArrow=blockThin;endFill=1;fontSize=11;edgeStyle=orthogonalEdgeStyle;"}
#
## Node width and height, and padding for autosize
#width: auto
#height: auto
#padding: -12
#
## ignore: id,image,fill,stroke,refs,manager
#
## Column to be renamed to link attribute (used as link).
## link: url
#
## Spacing between nodes, heirarchical levels and parallel connections.
#nodespacing: 40
#levelspacing: 100
#edgespacing: 40
#
## layout: auto
#layout: verticaltree
#
## ---- CSV below this line.
First line are column names.
----
"Id","Name","DisplayName","ParentId","type","State","timeStamp"
"/providers/Microsoft.Management/managementGroups/AzureFoundation","AzureFoundation","AzureFoundation","/providers/Microsoft.Management/managementGroups/007c8676-93f7-4949-8529-db5616f42bc4","AzManagementGroup",,"2022-02-07 19:53"
"/providers/Microsoft.Management/managementGroups/007c8676-93f7-4949-8529-db5616f42bc4","007c8676-93f7-4949-8529-db5616f42bc4","Tenant Root Group",,"AzManagementGroup",,"2022-02-07 19:53"
,,"Subscription-One\<br\>Subscription-Two","/providers/Microsoft.Management/managementGroups/AzureFoundation","AzSubscription",,"2022-02-07 19:53"
```
## PARAMETERS

### -TemplatePath
Path to a custom definition of diagram layout, see https://www.diagrams.net/blog/insert-from-csv

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: (join-path -Path $PSScriptRoot -ChildPath 'template.txt')
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExcludeDefinition
Use to exclude definition from result, useful if you plan to use
https://jgraph.github.io/drawio-tools/tools/csv.html

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExpandSubscriptions
Standard behavior is to group subscriptions below the same managementgroup in one "box",
but if you prefer you can have each subscription as their own item.
Warning, can become much cluttered view.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -IncludeSubscriptionDetails
List more properties for each subscription like:
state,name,QuotaId,SpendingLimit

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -IncludeManagementGroupRoles
Include direct assigned roles to the ManagementGroup.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -MgmGroupExtraRoleProperties
Adds extra columns for role output,
Requires -IncludeManagementGroupRoles for effect
RoleDefinitionName, ObjectType, DisplayName are always there
Need -IncludeManagementGroupRoles to take effect
Supported properties are:
'RoleAssignmentName', 'RoleAssignmentId', 'Scope', 'SignInName', 'RoleDefinitionId', 'ObjectId', 'Description'

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None. You cannot pipe objects to New-MgmGroupDiagram.
## OUTPUTS

### string[]
## NOTES

## RELATED LINKS

[https://www.diagrams.net/blog/insert-from-csv
https://jgraph.github.io/drawio-tools/tools/csv.html](https://www.diagrams.net/blog/insert-from-csv
https://jgraph.github.io/drawio-tools/tools/csv.html)

[https://www.diagrams.net/blog/insert-from-csv
https://jgraph.github.io/drawio-tools/tools/csv.html]()

