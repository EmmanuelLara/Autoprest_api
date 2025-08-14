# Script manual para exponer la API AutoPrest
# Usa este script si prefieres control manual del proceso

Write-Host "🚀 Exposición Manual de la API AutoPrest" -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Green

# Verificar Docker
Write-Host "📋 Verificando Docker..." -ForegroundColor Yellow
if (docker info 2>$null) {
    Write-Host "✅ Docker está ejecutándose" -ForegroundColor Green
} else {
    Write-Host "❌ Docker no está ejecutándose. Inicia Docker Desktop." -ForegroundColor Red
    exit 1
}

# Verificar archivo .env
if (-not (Test-Path ".env")) {
    Write-Host "⚠️  Archivo .env no encontrado." -ForegroundColor Yellow
    Write-Host "📝 Crea un archivo .env con tu token de ngrok:" -ForegroundColor Cyan
    Write-Host "   NGROK_AUTHTOKEN=tu_token_aqui" -ForegroundColor White
    Write-Host "🔑 Obtén tu token en: https://ngrok.com/" -ForegroundColor Cyan
    exit 1
}

Write-Host ""
Write-Host "🔧 Comandos disponibles:" -ForegroundColor Yellow
Write-Host "1. Iniciar servicios: docker-compose up -d" -ForegroundColor White
Write-Host "2. Ver estado: docker-compose ps" -ForegroundColor White
Write-Host "3. Ver logs: docker-compose logs -f ngrok" -ForegroundColor White
Write-Host "4. Detener: docker-compose down" -ForegroundColor White
Write-Host "5. Estadísticas ngrok: http://localhost:4040" -ForegroundColor White

Write-Host ""
Write-Host "🎯 Para exponer la API:" -ForegroundColor Green
Write-Host "   docker-compose up -d" -ForegroundColor Cyan
Write-Host ""
Write-Host "📚 Una vez iniciado, visita:" -ForegroundColor Yellow
Write-Host "   http://localhost:4040 (para ver la URL pública)" -ForegroundColor White
Write-Host "   http://localhost:3000/api-docs/ (Swagger local)" -ForegroundColor White
