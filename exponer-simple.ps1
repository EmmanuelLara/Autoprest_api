# Script para exponer la API AutoPrest usando ngrok directamente
# Sin necesidad de Docker Desktop

Write-Host "🚀 Iniciando exposición pública de la API AutoPrest..." -ForegroundColor Green

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
    Write-Host "❌ Ngrok no está instalado o no está en el PATH" -ForegroundColor Red
    Write-Host "💡 Instala ngrok desde: https://ngrok.com/download" -ForegroundColor Yellow
    Write-Host "💡 O ejecuta: winget install ngrok" -ForegroundColor Yellow
    exit 1
}

# Verificar si hay un token configurado
$ngrokConfig = Get-Content "$env:USERPROFILE\.ngrok2\ngrok.yml" -ErrorAction SilentlyContinue
if (-not $ngrokConfig) {
    Write-Host "⚠️  No se encontró configuración de ngrok" -ForegroundColor Yellow
    Write-Host "💡 Para mejor experiencia, configura tu token:" -ForegroundColor Yellow
    Write-Host "   1. Ve a https://ngrok.com/ y crea una cuenta" -ForegroundColor Cyan
    Write-Host "   2. Obtén tu authtoken del dashboard" -ForegroundColor Cyan
    Write-Host "   3. Ejecuta: ngrok config add-authtoken TU_TOKEN" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "🔄 Continuando sin token (sesión limitada a 2 horas)..." -ForegroundColor Yellow
}

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
