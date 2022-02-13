
Import-Module -Name .\MgmGroupDiagram\MgmGroupDiagram.psm1 -Force -Verbose
Get-Command New-MgmGroupDiagram | fl * -Force
#get-help New-MgmGroupDiagram -ShowWindow
New-MgmGroupDiagram  | Set-Clipboard



New-MgmGroupDiagram -IncludeManagementGroupRoles -ExpandSubscriptions -IncludeSubscriptionDetails | scb

break


$MgmGroups = Get-AzManagementGroup 

$ManagementGroups = $MgmGroups | ForEach-Object  -Parallel {
    $MgmGroup = Get-AzManagementGroup -GroupId $_.Name -Expand
    $MgmGroup
}

$ManagementGroups | Where-Object {-not $_.children} | ForEach-Object -Parallel {
    $_ | Remove-AzManagementGroup 
}