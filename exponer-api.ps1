# Script para exponer la API AutoPrest públicamente usando Docker y Ngrok
# Duración aproximada: 2 horas (gratuito)

Write-Host "🚀 Iniciando exposición pública de la API AutoPrest..." -ForegroundColor Green

# Verificar si Docker está ejecutándose
Write-Host "📋 Verificando estado de Docker..." -ForegroundColor Yellow
try {
    docker info | Out-Null
    Write-Host "✅ Docker está ejecutándose" -ForegroundColor Green
} catch {
    Write-Host "❌ Docker no está ejecutándose." -ForegroundColor Red
    Write-Host "💡 Opciones:" -ForegroundColor Yellow
    Write-Host "   1. Inicia Docker Desktop y vuelve a intentar" -ForegroundColor Cyan
    Write-Host "   2. O usa el script simple: .\exponer-simple.ps1" -ForegroundColor Cyan
    Write-Host "   3. O instala ngrok: .\instalar-ngrok.ps1" -ForegroundColor Cyan
    exit 1
}

# Verificar si existe el archivo .env
if (-not (Test-Path ".env")) {
    Write-Host "⚠️  Archivo .env no encontrado. Creando desde ngrok-config.yml..." -ForegroundColor Yellow
    
    if (Test-Path "ngrok-config.yml") {
        Copy-Item "ngrok-config.yml" ".env"
        Write-Host "📝 Archivo .env creado. IMPORTANTE: Edita .env y agrega tu token de ngrok." -ForegroundColor Yellow
        Write-Host "🔑 Obtén tu token en: https://ngrok.com/" -ForegroundColor Cyan
        Write-Host "⏸️  Presiona Enter cuando hayas configurado tu token..." -ForegroundColor Yellow
        Read-Host
    } else {
        Write-Host "❌ No se pudo crear el archivo .env. Verifica ngrok-config.yml" -ForegroundColor Red
        exit 1
    }
}

# Detener contenedores existentes si están corriendo
Write-Host "🛑 Deteniendo contenedores existentes..." -ForegroundColor Yellow
docker-compose down

# Construir y levantar los servicios
Write-Host "🔨 Construyendo y levantando servicios..." -ForegroundColor Yellow
docker-compose up -d --build

# Esperar a que los servicios estén listos
Write-Host "⏳ Esperando a que los servicios estén listos..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

# Verificar estado de los servicios
Write-Host "📊 Verificando estado de los servicios..." -ForegroundColor Yellow
docker-compose ps

# Obtener la URL pública de ngrok
Write-Host "🌐 Obteniendo URL pública..." -ForegroundColor Yellow
Start-Sleep -Seconds 5

try {
    $ngrokResponse = Invoke-RestMethod -Uri "http://localhost:4040/api/tunnels" -Method Get
    $publicUrl = $ngrokResponse.tunnels[0].public_url
    
    if ($publicUrl) {
        Write-Host "✅ API expuesta públicamente!" -ForegroundColor Green
        Write-Host "🔗 URL Pública: $publicUrl" -ForegroundColor Cyan
        Write-Host "📚 Documentación Swagger: $publicUrl/api-docs/" -ForegroundColor Cyan
        Write-Host "⏰ Duración: 2 horas (gratuito)" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "📋 Endpoints disponibles:" -ForegroundColor White
        Write-Host "   - API Base: $publicUrl" -ForegroundColor White
        Write-Host "   - Swagger UI: $publicUrl/api-docs/" -ForegroundColor White
        Write-Host "   - Health Check: $publicUrl/health" -ForegroundColor White
        Write-Host ""
        Write-Host "💡 Comparte esta URL para que otros puedan acceder a tu API desde cualquier lugar!" -ForegroundColor Green
        Write-Host ""
        Write-Host "🛑 Para detener la exposición pública, ejecuta: docker-compose down" -ForegroundColor Yellow
    } else {
        Write-Host "❌ No se pudo obtener la URL pública de ngrok" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Error al obtener la URL pública: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "🔍 Verificando logs de ngrok..." -ForegroundColor Yellow
    docker-compose logs ngrok
}

Write-Host ""
Write-Host "🎯 La API está ahora expuesta públicamente!" -ForegroundColor Green
