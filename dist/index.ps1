$ErrorActionPreference = 'Stop'
Function InitializeSecrets {
    $secrets = [pscustomobject]@{}
    try {
        $GITHUB_secrets = $env:GITHUB_secrets | ConvertFrom-Json
        $GITHUB_secrets.PSObject.Properties | ForEach-Object {
            $converFromBase64 = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($_.Value )) | ConvertFrom-Json
            $secrets | Add-Member `
                -NotePropertyName $_.Name `
                -NotePropertyValue $converFromBase64       
        }
    }
    catch {
        $secretsPath = $PSScriptRoot + '\.githubsecrets'
        if ([System.IO.Directory]::Exists($secretsPath )) {            
            $extension = ".githubsecrets.json"
            $table = get-childitem -Path ($secretsPath + '\*') -Include @('*' + $extension)
            foreach ($file in $table) {
                $secrets | Add-Member `
                    -NotePropertyName ($file.Name.Replace($extension, '')) `
                    -NotePropertyValue (Get-Content $file.Fullname | ConvertFrom-Json)
            }
        }
    }
    $secrets
}
$config = InitializeSecrets
Write-Host '=====InitializeSecrets====='
Write-Host ($config | ConvertTo-Json)
Write-Host '==========================='