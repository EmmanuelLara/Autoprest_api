# Script para probar la API de AutoPrest
Write-Host "🧪 Probando AutoPrest API..." -ForegroundColor Green

# Función para probar un endpoint
function Test-Endpoint {
    param(
        [string]$Method,
        [string]$Url,
        [string]$Description
    )
    
    try {
        Write-Host "🔍 Probando: $Description" -ForegroundColor Cyan
        Write-Host "   📡 $Method $Url" -ForegroundColor Gray
        
        $response = Invoke-RestMethod -Uri $Url -Method $Method -TimeoutSec 10
        Write-Host "   ✅ Éxito: $($response | ConvertTo-Json -Depth 1)" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "   ❌ Error: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Esperar un momento para que la API esté lista
Write-Host "⏳ Esperando a que la API esté lista..." -ForegroundColor Yellow
Start-Sleep -Seconds 5

# Probar endpoints básicos
Write-Host ""
Write-Host "📋 Probando endpoints básicos:" -ForegroundColor Yellow

$endpoints = @(
    @{Method="GET"; Url="http://localhost:3000"; Description="Endpoint raíz"},
    @{Method="GET"; Url="http://localhost:3000/swagger.json"; Description="Especificación Swagger"},
    @{Method="GET"; Url="http://localhost:3000/docs"; Description="Documentación personalizada"},
    @{Method="GET"; Url="http://localhost:3000/api-docs"; Description="Swagger UI"}
)

$successCount = 0
foreach ($endpoint in $endpoints) {
    if (Test-Endpoint -Method $endpoint.Method -Url $endpoint.Url -Description $endpoint.Description) {
        $successCount++
    }
    Write-Host ""
}

# Resumen
Write-Host "📊 Resumen de pruebas:" -ForegroundColor Cyan
Write-Host "   ✅ Endpoints exitosos: $successCount/$($endpoints.Count)" -ForegroundColor White

if ($successCount -eq $endpoints.Count) {
    Write-Host "🎉 ¡Todos los endpoints están funcionando correctamente!" -ForegroundColor Green
    Write-Host ""
    Write-Host "🌐 URLs disponibles:" -ForegroundColor Cyan
    Write-Host "   📚 Swagger UI: http://localhost:3000/api-docs" -ForegroundColor White
    Write-Host "   📖 Documentación: http://localhost:3000/docs" -ForegroundColor White
    Write-Host "   🔗 API: http://localhost:3000" -ForegroundColor White
} else {
    Write-Host "⚠️  Algunos endpoints no están funcionando. Revisa los logs:" -ForegroundColor Yellow
    Write-Host "   docker-compose logs api" -ForegroundColor White
}
