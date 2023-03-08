param(
    [string]$displayName,
    [string]$webAppUrls
)
[hashtable]$return = @{}

$scriptDir = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent

$replyUrls = $webAppUrl.Split(' ')

$app = $(az ad app list --display-name $displayName --output tsv --query '[0].[appId, id]')
if ($null -eq $app) {
    $app = $(az ad app create --display-name $displayName `
                              --enable-access-token-issuance $false `
                              --enable-id-token-issuance $false `
                              --sign-in-audience AzureADMyOrg `
                              --required-resource-accesses "$($scriptDir)\api.resourceAccesses.json" `
                              --output tsv `
                              --query '[appId, id]')
}

$appId = $app[0]
$appObjectId = $app[1]

az rest --method PATCH `
        --headers "Content-Type=application/json" `
        --uri "https://graph.microsoft.com/v1.0/applications/$($appObjectId)" `
        --body "{\`"identifierUris\`":[\`"api://$($appId)\`"], \`"web\`":{\`"redirectUris\`": [$('\"{0}\"' -f ($replyUrls -join '\",\"'))] }}"

# Add API Scope
$scopeGUID = [guid]::NewGuid()
$scopeJSONHash = @{
    adminConsentDescription="Allow the application to access $($displayName) on behalf of the signed-in user."
    adminConsentDisplayName="Access $($displayName)" 
    id="$($scopeGUID)"
    isEnabled=$true
    type="User"
    userConsentDescription="Allow the application to access $($displayName) on your behalf."
    userConsentDisplayName="Access $($displayName)"
    value="user_access"
}

$bodyAPIAccess = @{
    api = @{
        oauth2PermissionScopes = @($scopeJSONHash)
    }
    isFallbackPublicClient = $true
}|ConvertTo-Json -d 3

$accesstoken = (Get-AzAccessToken -Resource "https://graph.microsoft.com/").Token
$header = @{
    'Content-Type' = 'application/json'
    'Authorization' = 'Bearer ' + $accesstoken
}
Invoke-RestMethod -Method Patch -Uri "https://graph.microsoft.com/v1.0/applications/$($appObjectId)" -Headers $header -Body $bodyAPIAccess

# Create service principal
$servicePrincipalObjectId = $(az ad sp list --filter "appId eq '$($appId)'" --output tsv --query [0].id)
if ($null -eq $servicePrincipalObjectId) {
    $servicePrincipalObjectId = $(az ad sp create --id $appId --output tsv --query id)
}

$return.appId = $appId
$return.appObjectId = $appObjectId
return $return