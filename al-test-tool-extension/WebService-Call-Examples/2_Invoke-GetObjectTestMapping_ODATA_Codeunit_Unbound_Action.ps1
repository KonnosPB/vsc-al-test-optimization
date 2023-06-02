$alTestSuite = 'MEDT01FOO'
$objFilter = 'KVS*'
$devSuite = 'kvsenavdev543'
$tenant = 'kpa'
$company = 'CRONUS AG'
$user = 'kpa'
$pass = 'Start2020'
$cred = [System.Management.Automation.PSCredential]::new($user,(ConvertTo-SecureString $pass -AsPlainText -Force))

$uri =  "https://$tenant.$devSuite.dev.intra:7048/BC/ODataV4/TestSuggestionWebservice_GetObjectTestMapping/?tenant=$tenant.$devSuite.dev.intra&company=$company"
$body = @{    
    objectFilter = $objFilter
    testSuite = $alTestSuite
} | ConvertTo-Json

# Downloaded erstelle Object/Test Mappings. Reduziert die Ergebnisse auf Kumavision Objekte.

Write-Host "Requesting unbound action`r`n$uri `r`n`r`napplication/json`r`n$body"
$Response = Invoke-RestMethod -Uri $uri -Body $body -Credential $cred -Method Post -ContentType 'application/json'
$val = $Response.value

Write-Host $val