Connect-VIServer -Server vcenter-mgmt.vcf2.sddc.lab -user administrator@vsphere.local -Password VMware123!
$WEBOLD="web-pg-vds01"
$DBOLD="db-pg-vds01"
$WEBNEW="ov-web"
$DBNEW="ov-db"
Get-VM |Get-NetworkAdapter |Where {$_.NetworkName -eq $WEBOLD } |Set-NetworkAdapter -Portgroup $WEBNEW -Confirm:$false
Get-VM |Get-NetworkAdapter |Where {$_.NetworkName -eq $DBOLD } |Set-NetworkAdapter -Portgroup $DBNEW -Confirm:$false
