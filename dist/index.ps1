# "$env:SUPER_SECRET"
# $GITHUB_secrets = JSON.parse(process.env.GITHUB_secrets);
dir env:
$GITHUB_secrets = $env:GITHUB_secrets | ConvertFrom-Json
Write-Output ($GITHUB_secrets | ConvertTo-Json)