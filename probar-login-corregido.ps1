# Script para probar el login corregido
$baseUrl = "http://localhost:3000"

Write-Host "🔐 Probando login corregido..." -ForegroundColor Yellow

# Datos de login que estaban fallando
$loginData = @{
    email = "cebra@example.com"
    pass = "password123"
}

# Convertir a JSON
$jsonData = $loginData | ConvertTo-Json

Write-Host "📤 Enviando request de login..." -ForegroundColor Cyan
Write-Host "URL: $baseUrl/login" -ForegroundColor Gray
Write-Host "Datos: $jsonData" -ForegroundColor Gray

try {
    $response = Invoke-RestMethod -Uri "$baseUrl/login" -Method POST -Body $jsonData -ContentType "application/json"
    
    Write-Host "✅ Login exitoso!" -ForegroundColor Green
    Write-Host "Token: $($response.token)" -ForegroundColor Cyan
    Write-Host "Usuario: $($response.usuario.nombre)" -ForegroundColor Cyan
    Write-Host "Rol: $($response.usuario.rol)" -ForegroundColor Cyan
    
} catch {
    Write-Host "❌ Error en login:" -ForegroundColor Red
    Write-Host "Status: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
    Write-Host "Mensaje: $($_.Exception.Message)" -ForegroundColor Red
    
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host "Respuesta: $responseBody" -ForegroundColor Red
    }
}

Write-Host "🎯 Prueba completada!" -ForegroundColor Green
