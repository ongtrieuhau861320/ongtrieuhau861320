$ErrorActionPreference = 'Stop'
Function InitializeSecrets {
    $secrets = [pscustomobject]@{}
    try {
        $GITHUB_secrets = $env:GITHUB_secrets | ConvertFrom-Json
        $GITHUB_secrets.PSObject.Properties | ForEach-Object {
            $secrets | Add-Member `
                -NotePropertyName $_.Name `
                -NotePropertyValue $_.Value        
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
Write-Host '====='
Write-Host ($config | ConvertTo-Json)