$ErrorActionPreference = 'Stop'
Function InitializeSecrets {
    Write-Host '=====InitializeSecrets====='
    $secrets = [pscustomobject]@{}
    try {
        $GITHUB_secrets = $env:GITHUB_secrets | ConvertFrom-Json
        $GITHUB_secrets.PSObject.Properties | ForEach-Object {
            if ($_.Name -ne "github_token") {
                $converFromBase64 = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($_.Value))
                $secrets | Add-Member `
                    -NotePropertyName $_.Name `
                    -NotePropertyValue ($converFromBase64 | ConvertFrom-Json)   
            }  
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
    Write-Host ($secrets | ConvertTo-Json)
    Write-Host '=====END:InitializeSecrets='
    $secrets
}

function GetLibraryFile ([string] $pathLibrary) {
    
    [System.IO.FileInfo]$infoFile = New-Object System.IO.FileInfo($pathLibrary);
    $o = [pscustomobject]@{}
    $o | Add-Member -NotePropertyName OriginalFilename -NotePropertyValue $infoFile.Name
    $o | Add-Member -NotePropertyName FileVersion -NotePropertyValue $infoFile.FileVersion
    $o | Add-Member -NotePropertyName FileDescription -NotePropertyValue $infoFile.FileDescription
    $o | Add-Member -NotePropertyName FileLength -NotePropertyValue $infoFile.FileLength
    $o | Add-Member -NotePropertyName IsExe -NotePropertyValue ($infoFile.Name -match '.exe$')
    $o | Add-Member -NotePropertyName FileTime -NotePropertyValue ([pscustomobject]@{})
    $o.FileTime | Add-Member -NotePropertyName CreationTime `
        -NotePropertyValue ($infoFile.CreationTime.ToString("yyyyMMdd HH:mm:ss"))
    $o.FileTime | Add-Member -NotePropertyName LastWriteTime `
        -NotePropertyValue ($infoFile.LastWriteTime.ToString("yyyyMMdd HH:mm:ss"))
    $o.FileTime | Add-Member -NotePropertyName LastAccessTime `
        -NotePropertyValue ($infoFile.LastAccessTime.ToString("yyyyMMdd HH:mm:ss"))
    
    $fileBytes = [System.IO.File]::ReadAllBytes($pathLibrary);
    $o | Add-Member -NotePropertyName FileHashMD5 `
        -NotePropertyValue ((Get-FileHash -InputStream  ([System.IO.MemoryStream]::New($fileBytes)) -Algorithm MD5).hash)
    $o | Add-Member -NotePropertyName FileHashSHA1 `
        -NotePropertyValue ((Get-FileHash -InputStream  ([System.IO.MemoryStream]::New($fileBytes)) -Algorithm SHA1).hash)
		
    try {
        $assembly = [System.Reflection.Assembly]::Load($fileBytes)
        $assemblyGetName = $assembly.GetName()
        $assemblyFullName = $assembly.FullName
        $o | Add-Member -NotePropertyName AssemblyFullName -NotePropertyValue $assemblyFullName
        $o | Add-Member -NotePropertyName AssemblyFullNameMD5 -NotePropertyValue `
        (Get-FileHash -Algorithm MD5 -InputStream ([System.IO.MemoryStream]::New([System.Text.Encoding]::ASCII.GetBytes($assemblyFullName)))).hash
        $o | Add-Member -NotePropertyName AssemblyFullNameSHA1 -NotePropertyValue `
        (Get-FileHash -Algorithm SHA1 -InputStream ([System.IO.MemoryStream]::New([System.Text.Encoding]::ASCII.GetBytes($assemblyFullName)))).hash
        
			
        $o | Add-Member -NotePropertyName AssemblyName -NotePropertyValue $assemblyGetName.Name
        $o | Add-Member -NotePropertyName AssemblyVersion -NotePropertyValue $assemblyGetName.Version.ToString()
        $o | Add-Member -NotePropertyName AssemblyProcessorArchitecture -NotePropertyValue $assemblyGetName.ProcessorArchitecture.ToString()
        $o | Add-Member -NotePropertyName AssemblyImageRuntimeVersion -NotePropertyValue $assembly.ImageRuntimeVersion
        $o | Add-Member -NotePropertyName ReferencedAssemblies -NotePropertyValue (New-Object System.Collections.Generic.List[string])
        Foreach ($asm in $assembly.GetReferencedAssemblies()) {
            $asmFullname = $asm.ToString().ToLower()
            $assemblySYSTEM = $asmFullname.StartsWith("mscorlib,".ToLower())
            $assemblySYSTEM = $assemblySYSTEM -or $asmFullname.StartsWith("WindowsBase,".ToLower())
            $assemblySYSTEM = $assemblySYSTEM -or $asmFullname.StartsWith("System,".ToLower())
            $assemblySYSTEM = $assemblySYSTEM -or $asmFullname.StartsWith("System.".ToLower())
            if ($assemblySYSTEM -eq $false) {
                $o.ReferencedAssemblies.Add($asm.FullName.ToString())
            }
        }
    }
    catch {
        $ignore = $_.ToString().Contains("Could not load file or assembly 'ChilkatDotNet4, Version=9.5.0.73, Culture=neutral")
        $ignore = $ignore -or $_.ToString().Contains("bytes loaded from Anonymously Hosted DynamicMethods Assembly")
        if ($ignore) { }
        else {
            Write-Host $o.OriginalFilename
            Write-Host $_
        }
    }
    return $o
}
$secrets = InitializeSecrets
$lib = GetLibraryFile -pathLibrary (Join-Path -Path $PSScriptRoot -ChildPath "OTH.PAY.ViettinBank.Crypto.dll")
Write-Host ($lib | ConvertTo-Json)