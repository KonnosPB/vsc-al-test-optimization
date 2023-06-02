$devSuite = 'kvsenavdev543'
$tenant = 'kpa'
$company = 'CRONUS AG'
$user = 'kpa'
$pass = 'Start2020'
$cred = [System.Management.Automation.PSCredential]::new($user,(ConvertTo-SecureString $pass -AsPlainText -Force))

#$uri =  "https://$tenant.$devSuite.dev.intra:7048/BC/ODataV4/AccountantPortalActivityCues/?tenant=$tenant.$devSuite.dev.intra&company=$company"
#$uri =   https://kpa.kvsenavdev543.dev.intra:7048/BC/ODataV4/Company('CRONUS%20AG')/ELO_BCQueryService?tenant=kpa.kvsenavdev543.dev.intra
$uri =  "https://$tenant.$devSuite.dev.intra:7048/BC/ODataV4/Company('$company')/AccountantPortalActivityCues/?tenant=$tenant.$devSuite.dev.intra"
$metaDataUri =  "https://$tenant.$devSuite.dev.intra:7048/BC/ODataV4/" + '$metadata' + "#Company('$company')/AccountantPortalActivityCues/?tenant=$tenant.$devSuite.dev.intra"
#https://kpa.kvsenavdev543.dev.intra:7048/BC/ODataV4/$metadata#Company('CRONUS%20AG')/AccountantPortalActivityCues

Export-ODataEndpointProxy -Uri $uri -MetadataUri $metaDataUri -OutputModule '.\Invoke-BoundActionExampleSripts\' -Credential $cred -Force 