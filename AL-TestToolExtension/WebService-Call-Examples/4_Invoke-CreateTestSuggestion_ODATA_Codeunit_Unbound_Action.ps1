$branchName = 'MEDT03FOO'
$devSuite = 'kvsenavdev543'
$tenant = 'kpa'
$company = 'CRONUS AG'
$user = 'kpa'
$pass = 'Start2020'
$cred = [System.Management.Automation.PSCredential]::new($user,(ConvertTo-SecureString $pass -AsPlainText -Force))

# Erstelle Vorschlag

$gitDiff = @'
diff --git a/app/src/codeunit/ItemSubscribers.Codeunit.al b/app/src/codeunit/ItemSubscribers.Codeunit.al
index 0fd9101e3..ba7e82c83 100644
--- a/app/src/codeunit/ItemSubscribers.Codeunit.al
+++ b/app/src/codeunit/ItemSubscribers.Codeunit.al
@@ -13,6 +13,8 @@ codeunit 5048753 "KVSKBAItemSubscribers"
         if not RunTrigger then
             exit;

+
+
         MandFieldsLib.OnInsertItem(Rec);
     end;

@@ -374,4 +376,4 @@ codeunit 5048753 "KVSKBAItemSubscribers"
     local procedure OnBeforeAdditionalChecksOnBeforePostingItemJnlFromProduction(var ItemJournalLine: Record "Item Journal Line"; var SkipAdditionalChecks: Boolean; var IsHandled: Boolean)
     begin
     end;
-}
\ No newline at end of file
+}
'@

$uri =  "https://$tenant.$devSuite.dev.intra:7048/BC/ODataV4/TestSuggestionWebservice_CreateSuggestionTestSuite/?tenant=$tenant.$devSuite.dev.intra&company=$company"
$body = @{    
  branch = $branchName
  gitDiff = $gitDiff
} | ConvertTo-Json

Write-Host "Requesting unbound action`r`n$uri `r`n`r`napplication/json`r`n$body"
Invoke-RestMethod -Uri $uri -Body $body -Credential $cred -Method Post -ContentType 'application/json'