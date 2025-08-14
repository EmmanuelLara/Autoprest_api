# Script para probar los endpoints de la API AutoPrest
# Verifica que todos los endpoints funcionen correctamente con la URL pública

Write-Host "🧪 Probando endpoints de la API AutoPrest..." -ForegroundColor Green
Write-Host "🌐 URL: https://e8498afce672.ngrok-free.app" -ForegroundColor Cyan
Write-Host ""

$baseUrl = "https://e8498afce672.ngrok-free.app"

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
Test-Endpoint -Method "GET" -Endpoint "/api-docs/" -Description "Documentación Swagger"

# Probar endpoint de registro (POST)
Write-Host "📝 Probando endpoint de registro..." -ForegroundColor Yellow
$registroData = @{
    nombre = "Usuario Test"
    telefono = "5512345678"
    email = "test@example.com"
    pass = "password123"
    rol = "cliente"
}
Test-Endpoint -Method "POST" -Endpoint "/registro" -Description "Registro de usuario" -Body $registroData

# Probar endpoint de login (POST)
Write-Host "🔐 Probando endpoint de login..." -ForegroundColor Yellow
$loginData = @{
    email = "test@example.com"
    pass = "password123"
}
Test-Endpoint -Method "POST" -Endpoint "/login" -Description "Login de usuario" -Body $loginData

Write-Host "🎯 Pruebas completadas!" -ForegroundColor Green
Write-Host "💡 Si todos los endpoints funcionan, tu API está correctamente configurada." -ForegroundColor Cyan
Write-Host "🌐 Accede a la documentación: $baseUrl/api-docs/" -ForegroundColor Cyan
