$webAppUrls = "https://localhost:7161/signin-oidc" #Update with the URL of your public domain name
$apiDisplayName = "aca-web-api"
$bffDisplayName = "aca-gateway"

$api = $(./api.appRegistration.ps1 -displayName $apiDisplayName -webAppUrls $webAppUrls)
Write-Host "$($apiDisplayName) clientId = $($api.appId)"
Write-Host " ---------------- "

$bff = $(./bff.appRegistration.ps1 -displayName $bffDisplayName -webAppUrls $webAppUrls -apiClientId $api.appId)
Write-Host "$($bffDisplayName) clientId = $($bff.appId)"
Write-Host "$($bffDisplayName) secret = $($bff.appPassword)"
