#Requires -Module Az.Resources,Az.Accounts
#Requires -Version 7

<#
.SYNOPSIS

Export Azure managementgroups and subscriptions in a hierarchy view as CSV-data that can be used with https://www.diagrams.net/

.DESCRIPTION

Export Azure managementgroups and subscriptions in a hierarchy view as CSV-data that can be used with https://www.diagrams.net/
Generates data that can be used as showcased at https://www.diagrams.net/blog/insert-from-csv

The function uses default azure-context

.INPUTS

None. You cannot pipe objects to New-MgmGroupDiagram.

.OUTPUTS

string[]


.EXAMPLE

PS> New-MgmGroupDiagram

#label: %DisplayName%
#stylename: type
#styles: {"AzManagementGroup": "label;image=img/lib/azure2/general/Management_Groups.svg;whiteSpace=wrap;html=1;rounded=1; fillColor=%fill%;strokeColor=#6c8ebf;fillColor=#dae8fc;points=[[0.5,0,0,0,0],[0.5,1,0,0,0]];",\
#"AzSubscription": "label;image=img/lib/azure2/general/Subscriptions.svg;whiteSpace=wrap;html=1;rounded=1; fillColor=%fill%;strokeColor=#d6b656;fillColor=#fff2cc;points=[[0.5,0,0,0,0],[0.5,1,0,0,0]];imageWidth=26;"}
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
## ---- CSV below this line. First line are column names. ----
"Id","Name","DisplayName","ParentId","type","State","timeStamp"
"/providers/Microsoft.Management/managementGroups/AzureFoundation","AzureFoundation","AzureFoundation","/providers/Microsoft.Management/managementGroups/007c8676-93f7-4949-8529-db5616f42bc4","AzManagementGroup",,"2022-02-07 19:53"
"/providers/Microsoft.Management/managementGroups/007c8676-93f7-4949-8529-db5616f42bc4","007c8676-93f7-4949-8529-db5616f42bc4","Tenant Root Group",,"AzManagementGroup",,"2022-02-07 19:53"
,,"Subscription-One<br>Subscription-Two","/providers/Microsoft.Management/managementGroups/AzureFoundation","AzSubscription",,"2022-02-07 19:53"

.LINK

https://www.diagrams.net/blog/insert-from-csv
https://jgraph.github.io/drawio-tools/tools/csv.html

#>
function New-MgmGroupDiagram {
    [OutputType([String[]])]
    [CmdletBinding()]
    param (
        # Path to a custom definition of diagram layout, see https://www.diagrams.net/blog/insert-from-csv
        [ValidateScript({
            
                if (Test-Path -Path $_ ) {
                    $true
                }
                else {
                    throw "TemplatePath $_ is not valid" 
                }
            })]
        [String]$TemplatePath = (join-path -Path $PSScriptRoot -ChildPath 'template.txt'),
        # Use to exclude definition from result, useful if you plan to use
        # https://jgraph.github.io/drawio-tools/tools/csv.html
        [Parameter()]
        [switch]$ExcludeDefinition,
        # Standard behavior is to group subscriptions below the same managementgroup in one "box",
        # but if you prefer you can have each subscription as their own item.
        # Warning, can become much cluttered view.
        [switch]$ExpandSubscriptions,
        # List more properties for each subscription like:
        # state,name,QuotaId,SpendingLimit
        [switch]$IncludeSubscriptionDetails,
        # Include direct assigned roles to the ManagementGroup.
        [switch]$IncludeManagementGroupRoles,
        # Adds extra columns for role output,
        #
        # Requires -IncludeManagementGroupRoles for effect
        #
        # RoleDefinitionName, ObjectType, DisplayName are always there
        #
        # Supported properties are:
        # 'RoleAssignmentName', 'RoleAssignmentId', 'Scope', 'SignInName', 'RoleDefinitionId', 'ObjectId', 'Description'
        [ValidateSet('RoleAssignmentName', 'RoleAssignmentId', 'Scope', 'SignInName', 'RoleDefinitionId', 'ObjectId', 'Description')]
        [ValidateCount(1, 10)]
        [string[]]$MgmGroupExtraRoleProperties

        
    )
    
    begin {
        
    }
    
    process {
        $MgmGroups = Get-AzManagementGroup 

        $ManagementGroups = $MgmGroups | ForEach-Object  -Parallel {
            $MgmGroup = Get-AzManagementGroup -GroupId $_.Name -Expand
            if ($using:IncludeManagementGroupRoles.IsPresent) {
                $scope = $MgmGroup.Id
                $DisplayProperties = @{N = 'Role'; E = { $_.RoleDefinitionName } }, 'DisplayName', @{N = 'Type'; E = { $_.ObjectType } } 
                #+ $Using:MgmGroupExtraRoleProperties
                if ($Using:MgmGroupExtraRoleProperties) {
                    $DisplayProperties += $Using:MgmGroupExtraRoleProperties
                }
                $Assignments = Get-AzRoleAssignment -Scope $scope | Where-Object Scope -eq $scope
                $DisplayName = '<h2>' + $MgmGroup.DisplayName + '</h2><hr><h3>Roles:</h3>' + ($Assignments | Sort-Object RoleDefinitionName, ObjectType, DisplayName | Select-Object -Property $DisplayProperties | ConvertTo-Html -Fragment ) #-join ''
            }
            else {
                $DisplayName = $MgmGroup.DisplayName
            }
            Add-Member -InputObject $MgmGroup -MemberType NoteProperty -Name DisplayName2 -Value $DisplayName
            $MgmGroup
        }

        $SubTranslate = @{}

        foreach ($ManagementGroup in $ManagementGroups.Where{ $_.Children.Type -eq '/subscriptions' }) {
            foreach ($subscription in $ManagementGroup.Children.where{ $_.Type -eq '/subscriptions' }) {
                $SubTranslate[$subscription.Name] = $ManagementGroup.id
            }
        }

        $timeStamp = (get-date).ToString('yyyy-MM-dd HH:mm')
        
        $result = @()

        $result += $ManagementGroups | Select-Object -Property Id, Name, @{n = 'DisplayName'; e = { $_.DisplayName2 } }, ParentId, @{n = 'type'; e = { 'AzManagementGroup' } }, State, @{n = 'timeStamp'; e = { $timeStamp } }, @{n = 'Roles'; e = { 'roles-' + $_.id } } | Sort-Object DisplayName

        $subscriptions = Get-AzSubscription | Select-Object *, @{n = 'ParentId'; e = { $SubTranslate[$_.id] } } , @{n = 'timeStamp'; e = { $timeStamp } }, DisplayName 
        
        $result += if ($ExpandSubscriptions) {
        
            foreach ($subscription in $subscriptions) {
                if ($IncludeSubscriptionDetails.IsPresent) {
                    [string]$subscription.DisplayName = $subscription | Select-Object -property state, name, @{N = "QuotaId"; E = { $_.SubscriptionPolicies.QuotaId } }, @{N = "SpendingLimit"; E = { $_.SubscriptionPolicies.SpendingLimit } } | ConvertTo-Html -Fragment -as List
                } else {
                    $subscription.DisplayName = $subscription.State -eq 'Disabled' ? '<del>{0}<del>' -f $subscription.Name : $subscription.Name
                }
            }
            $subscriptions | Sort-Object Name | Select-Object Id, Name, DisplayName, ParentId, @{n = 'type'; e = { 'AzSubscription' } }, State, @{n = 'timeStamp'; e = { $timeStamp } }
        }
        else {
            $subscriptions | Sort-Object ParentId, Name | Group-Object ParentId | ForEach-Object {
                if ($IncludeSubscriptionDetails.IsPresent) {
                    $SortProps = @{Expression = "state"; Descending = $true }, @{Expression = "name"; Descending = $false }
                    [string]$DisplayName = ($_.group | Sort-Object -Property $SortProps | Select-Object -property state, name, @{N = "QuotaId"; E = { $_.SubscriptionPolicies.QuotaId } }, @{N = "SpendingLimit"; E = { $_.SubscriptionPolicies.SpendingLimit } } | ConvertTo-Html -Fragment)
                }
                else {
                    $Names = foreach ($Subscription in $_.group) {
                        $Subscription.State -eq 'Disabled' ? '<del>{0}<del>' -f $Subscription.Name : $Subscription.Name
                    }
                    [string]$DisplayName = $Names -join '<br>'                   
                }

                [PSCustomObject]@{
                    ParentId    = $_.name
                    DisplayName = $DisplayName
                    type        = 'AzSubscription'
                    timeStamp   = $timeStamp
                }
            }
        }
        
        if (-not $ExcludeDefinition) {
            $templateContent = Get-Content $TemplatePath
            $templateContent -replace '^()', '#$1' | Write-Output
            
        }


        $result | ConvertTo-Csv | Write-Output
    }
    
    end {
        
    }
}

Export-ModuleMember -Function New-MgmGroupDiagram