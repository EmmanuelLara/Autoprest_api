# Script de inicio para AutoPrest API con Docker
Write-Host "🚗 Iniciando AutoPrest API..." -ForegroundColor Green

# Verificar si Docker está ejecutándose
try {
    docker info | Out-Null
    Write-Host "✅ Docker está ejecutándose" -ForegroundColor Green
} catch {
    Write-Host "❌ Docker no está ejecutándose. Por favor, inicia Docker Desktop" -ForegroundColor Red
    exit 1
}

# Detener contenedores existentes si los hay
Write-Host "🛑 Deteniendo contenedores existentes..." -ForegroundColor Yellow
docker-compose down

# Construir y levantar los contenedores
Write-Host "🔨 Construyendo y levantando contenedores..." -ForegroundColor Yellow
docker-compose up --build -d

# Esperar a que los servicios estén listos
Write-Host "⏳ Esperando a que los servicios estén listos..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

# Verificar el estado de los contenedores
Write-Host "📊 Estado de los contenedores:" -ForegroundColor Cyan
docker-compose ps

# Mostrar logs de la API
Write-Host "📝 Logs de la API:" -ForegroundColor Cyan
docker-compose logs api

Write-Host ""
Write-Host "🎉 AutoPrest API está ejecutándose!" -ForegroundColor Green
Write-Host "📍 URLs disponibles:" -ForegroundColor Cyan
Write-Host "   🌐 API: http://localhost:3000" -ForegroundColor White
Write-Host "   📚 Swagger UI: http://localhost:3000/api-docs" -ForegroundColor White
Write-Host "   📖 Documentación: http://localhost:3000/docs" -ForegroundColor White
Write-Host "   🗄️  MongoDB: localhost:27018" -ForegroundColor White
Write-Host "   🌍 Nginx: http://localhost:8080" -ForegroundColor White
Write-Host "   🔗 Ngrok: http://localhost:4040" -ForegroundColor White
Write-Host ""
Write-Host "💡 Para ver logs en tiempo real: docker-compose logs -f api" -ForegroundColor Yellow
Write-Host "💡 Para detener: docker-compose down" -ForegroundColor Yellow
