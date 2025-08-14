# Script para probar los endpoints de la API AutoPrest con la NUEVA URL
# Verifica que todos los endpoints funcionen correctamente con la nueva URL pública

Write-Host "🧪 Probando endpoints de la API AutoPrest..." -ForegroundColor Green
Write-Host "🌐 NUEVA URL: https://e949ecceb86b.ngrok-free.app" -ForegroundColor Cyan
Write-Host ""

$baseUrl = "https://e949ecceb86b.ngrok-free.app"

# Función para probar un endpoint
function Test-Endpoint {
    param(
        [string]$Method,
        [string]$Endpoint,
        [string]$Description,
        [object]$Body = $null
    )
    
    try {
        $uri = "$baseUrl$Endpoint"
        $headers = @{
            'Content-Type' = 'application/json'
        }
        
        $params = @{
            Uri = $uri
            Method = $Method
            Headers = $headers
            UseBasicParsing = $true
        }
        
        if ($Body) {
            $params.Body = $Body | ConvertTo-Json
        }
        
        $response = Invoke-WebRequest @params
        
        Write-Host "✅ $Description" -ForegroundColor Green
        Write-Host "   Status: $($response.StatusCode)" -ForegroundColor White
        Write-Host "   URL: $uri" -ForegroundColor Gray
        
    } catch {
        Write-Host "❌ $Description" -ForegroundColor Red
        Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "   URL: $uri" -ForegroundColor Gray
    }
    Write-Host ""
}

# Probar endpoints básicos
Write-Host "🔍 Probando endpoints básicos..." -ForegroundColor Yellow
Test-Endpoint -Method "GET" -Endpoint "/" -Description "Health Check - Página principal"
Test-Endpoint -Method "GET" -Endpoint "/api-docs/" -Description "Documentación Swagger Original"
Test-Endpoint -Method "GET" -Endpoint "/docs" -Description "Documentación Swagger Personalizada"
Test-Endpoint -Method "GET" -Endpoint "/swagger.json" -Description "Especificación Swagger JSON"

# Probar endpoint de registro (POST)
Write-Host "📝 Probando endpoint de registro..." -ForegroundColor Yellow
$registroData = @{
    nombre = "Usuario Test Nueva URL"
    telefono = "5512345678"
    email = "testnuevo@example.com"
    pass = "password123"
    rol = "cliente"
}
Test-Endpoint -Method "POST" -Endpoint "/registro" -Description "Registro de usuario" -Body $registroData

# Probar endpoint de login (POST)
Write-Host "🔐 Probando endpoint de login..." -ForegroundColor Yellow
$loginData = @{
    email = "testnuevo@example.com"
    pass = "password123"
}
Test-Endpoint -Method "POST" -Endpoint "/login" -Description "Login de usuario" -Body $loginData

Write-Host "🎯 Pruebas completadas!" -ForegroundColor Green
Write-Host "💡 Si todos los endpoints funcionan, tu API está correctamente configurada." -ForegroundColor Cyan
Write-Host ""
Write-Host "🌐 URLs disponibles:" -ForegroundColor Cyan
Write-Host "   📚 Documentación Original: $baseUrl/api-docs/" -ForegroundColor White
Write-Host "   🚀 Documentación Personalizada: $baseUrl/docs" -ForegroundColor White
Write-Host "   📋 Especificación JSON: $baseUrl/swagger.json" -ForegroundColor White
Write-Host ""
Write-Host "💡 RECOMENDADO: Usa $baseUrl/docs para evitar errores de localhost" -ForegroundColor Green
