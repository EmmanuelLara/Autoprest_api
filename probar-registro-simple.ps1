# Script simple para probar registro
$baseUrl = "http://localhost:3000"

Write-Host "🔍 Probando registro simple..." -ForegroundColor Yellow

# Caso simple sin campos extra
$registroSimple = @{
    nombre = "Test Simple"
    telefono = "5512345678"
    email = "simple@test.com"
    pass = "password123"
    rol = "cliente"
}

$jsonSimple = $registroSimple | ConvertTo-Json -Depth 10
Write-Host "JSON: $jsonSimple" -ForegroundColor Gray

try {
    $response = Invoke-RestMethod -Uri "$baseUrl/registro" -Method POST -Body $jsonSimple -ContentType "application/json"
    Write-Host "✅ Registro exitoso!" -ForegroundColor Green
    Write-Host "Token: $($response.token.Substring(0, 50))..." -ForegroundColor Cyan
    
    # Probar login inmediatamente
    $loginData = @{
        email = $registroSimple.email
        pass = $registroSimple.pass
    }
    $jsonLogin = $loginData | ConvertTo-Json -Depth 10
    
    try {
        $responseLogin = Invoke-RestMethod -Uri "$baseUrl/login" -Method POST -Body $jsonLogin -ContentType "application/json"
        Write-Host "✅ Login exitoso!" -ForegroundColor Green
    } catch {
        Write-Host "❌ Login falló: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
    }
    
} catch {
    Write-Host "❌ Error en registro: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
    
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host "Respuesta: $responseBody" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "🎯 Prueba completada!" -ForegroundColor Green
