# Script para instalar y configurar ngrok automáticamente

Write-Host "🔧 Configurando ngrok para AutoPrest API..." -ForegroundColor Green

# Verificar si ngrok ya está instalado
try {
    $ngrokVersion = ngrok version 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Ngrok ya está instalado: $ngrokVersion" -ForegroundColor Green
        $ngrokInstalled = $true
    } else {
        throw "Ngrok no encontrado"
    }
} catch {
    Write-Host "📦 Ngrok no está instalado. Instalando..." -ForegroundColor Yellow
    $ngrokInstalled = $false
}

# Instalar ngrok si no está instalado
if (-not $ngrokInstalled) {
    try {
        Write-Host "🔄 Instalando ngrok con winget..." -ForegroundColor Cyan
        winget install ngrok.ngrok --accept-source-agreements --accept-package-agreements
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Ngrok instalado exitosamente" -ForegroundColor Green
            # Refrescar PATH
            $env:PATH = [System.Environment]::GetEnvironmentVariable("PATH","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("PATH","User")
        } else {
            throw "Error en la instalación"
        }
    } catch {
        Write-Host "❌ Error al instalar ngrok con winget" -ForegroundColor Red
        Write-Host "💡 Instalación manual:" -ForegroundColor Yellow
        Write-Host "   1. Ve a https://ngrok.com/download" -ForegroundColor Cyan
        Write-Host "   2. Descarga la versión para Windows" -ForegroundColor Cyan
        Write-Host "   3. Extrae ngrok.exe a una carpeta en tu PATH" -ForegroundColor Cyan
        Write-Host "   4. O agrega la carpeta al PATH del sistema" -ForegroundColor Cyan
        exit 1
    }
}

# Verificar instalación
try {
    $ngrokVersion = ngrok version 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Ngrok funcionando correctamente: $ngrokVersion" -ForegroundColor Green
    } else {
        throw "Ngrok no funciona después de la instalación"
    }
} catch {
    Write-Host "❌ Error al verificar ngrok: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Verificar configuración
$ngrokConfig = Get-Content "$env:USERPROFILE\.ngrok2\ngrok.yml" -ErrorAction SilentlyContinue
if (-not $ngrokConfig) {
    Write-Host "⚠️  Ngrok no está configurado con un token" -ForegroundColor Yellow
    Write-Host "💡 Para mejor experiencia (sesiones más largas):" -ForegroundColor Yellow
    Write-Host "   1. Ve a https://ngrok.com/ y crea una cuenta gratuita" -ForegroundColor Cyan
    Write-Host "   2. Obtén tu authtoken desde el dashboard" -ForegroundColor Cyan
    Write-Host "   3. Ejecuta: ngrok config add-authtoken TU_TOKEN" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "🔄 Puedes continuar sin token (sesión limitada a 2 horas)" -ForegroundColor Yellow
} else {
    Write-Host "✅ Ngrok está configurado con token" -ForegroundColor Green
}

Write-Host ""
Write-Host "🎉 Configuración completada!" -ForegroundColor Green
Write-Host "💡 Ahora puedes ejecutar: .\exponer-simple.ps1" -ForegroundColor Cyan
