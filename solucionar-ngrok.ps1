# Script para solucionar problemas de ngrok automáticamente

Write-Host "🔧 Solucionando problemas de ngrok..." -ForegroundColor Green

# Verificar si el servidor está corriendo
$serverRunning = netstat -ano | findstr :3000
if (-not $serverRunning) {
    Write-Host "❌ El servidor no está corriendo en el puerto 3000" -ForegroundColor Red
    Write-Host "💡 Ejecuta 'npm start' primero" -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ Servidor detectado en puerto 3000" -ForegroundColor Green

# Verificar si ngrok está instalado
try {
    $ngrokVersion = ngrok version 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Ngrok detectado: $ngrokVersion" -ForegroundColor Green
    } else {
        throw "Ngrok no encontrado"
    }
} catch {
    Write-Host "❌ Ngrok no está instalado" -ForegroundColor Red
    Write-Host "🔄 Instalando ngrok automáticamente..." -ForegroundColor Yellow
    
    try {
        winget install ngrok.ngrok --accept-source-agreements --accept-package-agreements
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Ngrok instalado exitosamente" -ForegroundColor Green
            # Refrescar PATH
            $env:PATH = [System.Environment]::GetEnvironmentVariable("PATH","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("PATH","User")
        } else {
            throw "Error en la instalación"
        }
    } catch {
        Write-Host "❌ Error al instalar ngrok automáticamente" -ForegroundColor Red
        Write-Host "💡 Instalación manual:" -ForegroundColor Yellow
        Write-Host "   1. Ve a https://ngrok.com/download" -ForegroundColor Cyan
        Write-Host "   2. Descarga e instala ngrok" -ForegroundColor Cyan
        Write-Host "   3. Vuelve a ejecutar este script" -ForegroundColor Cyan
        exit 1
    }
}

# Verificar instalación
try {
    $ngrokVersion = ngrok version 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Ngrok funcionando correctamente" -ForegroundColor Green
    } else {
        throw "Ngrok no funciona después de la instalación"
    }
} catch {
    Write-Host "❌ Error al verificar ngrok: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Verificar si hay un token configurado
$ngrokConfig = Get-Content "$env:USERPROFILE\.ngrok2\ngrok.yml" -ErrorAction SilentlyContinue
if (-not $ngrokConfig) {
    Write-Host "⚠️  Ngrok no está configurado con un token" -ForegroundColor Yellow
    Write-Host "💡 Para mejor experiencia (sesiones más largas):" -ForegroundColor Yellow
    Write-Host "   1. Ve a https://ngrok.com/ y crea una cuenta gratuita" -ForegroundColor Cyan
    Write-Host "   2. Obtén tu authtoken desde el dashboard" -ForegroundColor Cyan
    Write-Host "   3. Ejecuta: ngrok config add-authtoken TU_TOKEN" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "🔄 Continuando sin token (sesión limitada a 2 horas)..." -ForegroundColor Yellow
} else {
    Write-Host "✅ Ngrok está configurado con token" -ForegroundColor Green
}

# Detener cualquier proceso ngrok existente
Write-Host "🛑 Deteniendo procesos ngrok existentes..." -ForegroundColor Yellow
Get-Process -Name "ngrok" -ErrorAction SilentlyContinue | Stop-Process -Force

Write-Host ""
Write-Host "🌐 Iniciando túnel ngrok..." -ForegroundColor Green
Write-Host "📊 Panel de control: http://localhost:4040" -ForegroundColor Cyan
Write-Host "⏹️  Para detener: Ctrl+C" -ForegroundColor Yellow
Write-Host ""

# Iniciar ngrok
try {
    ngrok http 3000 --log=stdout
} catch {
    Write-Host "❌ Error al iniciar ngrok: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
