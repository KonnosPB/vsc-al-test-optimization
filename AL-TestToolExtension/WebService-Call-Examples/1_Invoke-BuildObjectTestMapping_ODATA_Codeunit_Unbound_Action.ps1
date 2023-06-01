$branchName = 'MEDT01FOO'
$objNameFilter = 'KVSKBAKPBCopyPurchaseDocuments' #'KVS*'
$devSuite = 'kvsenavdev543'
$tenant = 'kpa'
$company = 'CRONUS AG'
$user = 'kpa'
$pass = 'Start2020'
$cred = [System.Management.Automation.PSCredential]::new($user,(ConvertTo-SecureString $pass -AsPlainText -Force))

$uri =  "https://$tenant.$devSuite.dev.intra:7048/BC/ODataV4/TestSuggestionWebservice_BuildObjectTestMapping/?tenant=$tenant.$devSuite.dev.intra&company=$company"
$body = @{    
    testCodeunitFilter = $objNameFilter        
    testSuite = $branchName
} | ConvertTo-Json

# Legt eine TestSuite an, fügt automatisiert die Testcodeunit ($objNameFilter), führt den Test mit aktivierten CodeCoverage per Test aus und mapped Objekte und Tests.

Write-Host "Requesting unbound action`r`n$uri `r`n`r`napplication/json`r`n$body"
Invoke-RestMethod -Uri $uri -Body $body -Credential $cred -Method Post -ContentType 'application/json'