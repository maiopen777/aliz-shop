# Aliz Shop By Biw Dominic - online launcher.
# Downloads a pinned, checksum-verified copy; starts it with current user privileges.
# No persistent execution-policy or antivirus settings are changed.
[CmdletBinding()]
param([switch]$SelfTest)
& {
    param([bool]$RunSelfTest)
    $ErrorActionPreference = 'Stop'
    $programUrl = 'https://raw.githubusercontent.com/maiopen777/aliz-shop/367eba34293b7cba00471436c7cd261c669f2025/AlizShop.ps1'
    $programSha256 = '4d6fa9b93fb4fe856926779bd327cad996a5f4291b88a3477771ac1f428da459'
    $downloadPath = Join-Path ([IO.Path]::GetTempPath()) ('AlizShop-launch-' + [Guid]::NewGuid().ToString('N') + '.ps1')
    $oldProtocol = [Net.ServicePointManager]::SecurityProtocol
    try {
        if ($env:OS -ne 'Windows_NT' -or -not [Environment]::Is64BitOperatingSystem) {
            throw 'Aliz Shop requires 64-bit Windows 10 or 11.'
        }
        [Net.ServicePointManager]::SecurityProtocol = $oldProtocol -bor [Net.SecurityProtocolType]::Tls12
        Write-Host 'Preparing Aliz Shop By Biw Dominic...' -ForegroundColor Magenta
        Invoke-WebRequest -UseBasicParsing -Uri $programUrl -OutFile $downloadPath -TimeoutSec 60
        if ((Get-FileHash -LiteralPath $downloadPath -Algorithm SHA256).Hash.ToLowerInvariant() -cne $programSha256) {
            throw 'Downloaded file checksum mismatch. Nothing was launched.'
        }
        $powershellExe = Join-Path $env:SystemRoot 'System32\WindowsPowerShell\v1.0\powershell.exe'
        if ($RunSelfTest) {
            & $powershellExe -NoProfile -ExecutionPolicy Bypass -File $downloadPath -SelfTest
        } else {
            & $powershellExe -NoProfile -ExecutionPolicy Bypass -File $downloadPath
        }
        if ($LASTEXITCODE -ne 0) { throw ('Aliz Shop exited with code ' + $LASTEXITCODE) }
    } finally {
        [Net.ServicePointManager]::SecurityProtocol = $oldProtocol
        # Only the single exact temporary script generated above is removed.
        if ([IO.File]::Exists($downloadPath)) {
            try { [IO.File]::Delete($downloadPath) } catch { }
        }
    }
} $SelfTest.IsPresent
