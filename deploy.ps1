<#
    Despliegue de PoliMusic en IIS (ASP Clasico)
    ---------------------------------------------
    Ejecutar con:  ejecutar.bat   (recomendado)
    Tambien:       powershell -ExecutionPolicy Bypass -File deploy.ps1
#>

$ErrorActionPreference = 'Continue'

# ---------- Autoelevacion ----------
$identity  = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object Security.Principal.WindowsPrincipal($identity)
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host 'Solicitando permisos de administrador...' -ForegroundColor Yellow
    $argList = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', "`"$PSCommandPath`"")
    Start-Process -FilePath 'powershell.exe' -Verb RunAs -ArgumentList $argList
    exit
}

$src    = Join-Path $PSScriptRoot 'webapppolimusicv1_asp'
$dst    = 'C:\inetpub\wwwroot\webapppolimusicv1_asp'
$base   = 'http://localhost/webapppolimusicv1_asp'
$appcmd = "$env:SystemRoot\System32\inetsrv\appcmd.exe"
$report = Join-Path $PSScriptRoot '_diagnostico.txt'

Write-Host ''
Write-Host '=== PoliMusic - despliegue en IIS ===' -ForegroundColor Cyan
Write-Host ''

if (-not (Test-Path $src)) {
    Write-Host "[ERROR] No existe la carpeta del proyecto: $src" -ForegroundColor Red
    Read-Host 'Presiona Enter para salir'
    exit 1
}

# ---------- 1. Soporte ASP ----------
Write-Host '[1/6] Verificando soporte ASP...'
try {
    $asp = Get-WindowsOptionalFeature -Online -FeatureName IIS-ASP -ErrorAction Stop
    if ($asp.State -ne 'Enabled') {
        Write-Host '      Habilitando IIS-ASP...' -ForegroundColor Yellow
        Enable-WindowsOptionalFeature -Online -FeatureName IIS-ASP -All -NoRestart | Out-Null
    }
    Write-Host '      ASP disponible.' -ForegroundColor Green
}
catch {
    Write-Host "      Aviso: no se pudo verificar IIS-ASP ($($_.Exception.Message))" -ForegroundColor Yellow
}

# ---------- 2. Copia ----------
Write-Host "[2/6] Copiando a $dst ..."
robocopy $src $dst /MIR /NFL /NDL /NJH /NJS /NP | Out-Null
if ($LASTEXITCODE -ge 8) {
    Write-Host "[ERROR] Robocopy fallo con codigo $LASTEXITCODE" -ForegroundColor Red
    Read-Host 'Presiona Enter para salir'
    exit 1
}
Write-Host '      Copia completada.' -ForegroundColor Green

# ---------- 3. Permisos ----------
Write-Host '[3/6] Ajustando permisos...'
icacls $dst /grant 'IIS_IUSRS:(OI)(CI)(RX)' /T /Q | Out-Null
Write-Host '      Permisos listos.' -ForegroundColor Green

# ---------- 4. Forzar recompilacion ----------
Write-Host '[4/6] Forzando recompilacion de plantillas ASP...'
Get-ChildItem -Path $dst -Recurse -Include *.asp -ErrorAction SilentlyContinue | ForEach-Object {
    try { $_.LastWriteTime = Get-Date } catch { }
}
Write-Host '      Hecho.' -ForegroundColor Green

# ---------- 5. Errores ASP visibles ----------
Write-Host '[5/6] Activando detalle de errores ASP...'
& $appcmd unlock config /section:system.webServer/asp 2>&1 | Out-Null
& $appcmd set config /section:system.webServer/asp /scriptErrorSentToBrowser:"True" 2>&1 | Out-Null
Write-Host '      Hecho.' -ForegroundColor Green

# ---------- 6. Diagnostico ----------
Write-Host '[6/6] Probando la aplicacion...'

$probes = @{
    '_p1.asp' = '<%@ Language="VBScript" CodePage="65001" %>' + "`r`n" + '<!--#include file="inc/config.asp" -->' + "`r`n" + '<% Response.Write "OK_CONFIG" %>'
    '_p2.asp' = '<%@ Language="VBScript" CodePage="65001" %>' + "`r`n" + '<!--#include file="inc/auth.asp" -->' + "`r`n" + '<% Response.Write "OK_AUTH" %>'
    '_p3.asp' = '<%@ Language="VBScript" CodePage="65001" %>' + "`r`n" + '<!--#include file="inc/config.asp" -->' + "`r`n" + '<!--#include file="inc/auth.asp" -->' + "`r`n" + '<% Response.Write "OK_BOTH " & Len(Session("UserID") & "") %>'
}
foreach ($k in $probes.Keys) {
    try { Set-Content -Path (Join-Path $dst $k) -Value $probes[$k] -Encoding ASCII } catch { }
}

function Get-PageResult($url) {
    try {
        $r = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 20
        return "HTTP $($r.StatusCode) OK`r`n" + $r.Content
    }
    catch {
        $resp = $_.Exception.Response
        if ($resp -ne $null) {
            try {
                $reader = New-Object System.IO.StreamReader($resp.GetResponseStream())
                $text = $reader.ReadToEnd()
                $reader.Close()
                return "HTTP $([int]$resp.StatusCode)`r`n" + $text
            } catch {
                return "HTTP $([int]$resp.StatusCode) (cuerpo no legible)"
            }
        }
        return "SIN RESPUESTA: $($_.Exception.Message)"
    }
}

$targets = @(
    @{ n = 'inc/config.asp (directo)'; u = "$base/inc/config.asp" },
    @{ n = 'inc/auth.asp (directo)';   u = "$base/inc/auth.asp" },
    @{ n = 'default.asp'; u = "$base/default.asp" },
    @{ n = 'login.asp';   u = "$base/login.asp" },
    @{ n = '_p1.asp (solo config.asp)'; u = "$base/_p1.asp" },
    @{ n = '_p2.asp (solo auth.asp)';   u = "$base/_p2.asp" },
    @{ n = '_p3.asp (config + auth)';   u = "$base/_p3.asp" }
)

$lines = New-Object System.Collections.Generic.List[string]
$lines.Add("Diagnostico PoliMusic - $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')")
$lines.Add('')

$todoOk = $true
foreach ($t in $targets) {
    $res = Get-PageResult $t.u
    if ($res -notmatch 'HTTP 200') { $todoOk = $false }
    $lines.Add("===== $($t.n) =====")
    $lines.Add($res)
    $lines.Add('')
}

foreach ($k in $probes.Keys) {
    try { Remove-Item (Join-Path $dst $k) -Force -ErrorAction SilentlyContinue } catch { }
}

Set-Content -Path $report -Value ($lines -join "`r`n") -Encoding UTF8

Write-Host ''
if ($todoOk) {
    Write-Host 'LISTO: la aplicacion responde correctamente.' -ForegroundColor Green
} else {
    Write-Host 'La aplicacion devolvio errores. El detalle quedo en:' -ForegroundColor Yellow
    Write-Host "  $report" -ForegroundColor Yellow
}
Write-Host ''
Write-Host 'Abre en el navegador:  http://localhost/webapppolimusicv1_asp/' -ForegroundColor Cyan
Write-Host ''
Read-Host 'Presiona Enter para cerrar'
