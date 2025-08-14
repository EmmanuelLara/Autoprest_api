# Script para probar con nombre simple
$baseUrl = "http://localhost:3000"

Write-Host "🔐 Probando con nombre simple..." -ForegroundColor Yellow

# Probar con nombre simple
$emailCompleto = "hipopotamo@example.com"
$password = "password123"
$nombreSimple = "Usuario Hipopotamo"

Write-Host "Nombre: '$nombreSimple'" -ForegroundColor Gray
Write-Host "Email: '$emailCompleto'" -ForegroundColor Gray
Write-Host "Contraseña: '$password'" -ForegroundColor Gray

# 1. Intentar registro
Write-Host ""
Write-Host "1️⃣ Intentando registro..." -ForegroundColor Cyan

$registroData = @{
    nombre = $nombreSimple
    telefono = "5512345678"
    email = $emailCompleto
    pass = $password
    rol = "cliente"
}
$jsonRegistro = $registroData | ConvertTo-Json -Depth 10

try {
    $response = Invoke-RestMethod -Uri "$baseUrl/registro" -Method POST -Body $jsonRegistro -ContentType "application/json"
    Write-Host "✅ Usuario registrado exitosamente!" -ForegroundColor Green
    Write-Host "Token: $($response.token.Substring(0, 50))..." -ForegroundColor Cyan
} catch {
    if ($_.Exception.Response.StatusCode -eq 409) {
        Write-Host "ℹ️ El usuario ya existe" -ForegroundColor Yellow
    } else {
        Write-Host "❌ Error en registro: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
        if ($_.Exception.Response) {
            $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
            $responseBody = $reader.ReadToEnd()
            Write-Host "Respuesta: $responseBody" -ForegroundColor Red
        }
    }
}

# 2. Intentar login
Write-Host ""
Write-Host "2️⃣ Intentando login..." -ForegroundColor Cyan

$loginData = @{
    email = $emailCompleto
    pass = $password
}
$jsonLogin = $loginData | ConvertTo-Json -Depth 10

try {
    $responseLogin = Invoke-RestMethod -Uri "$baseUrl/login" -Method POST -Body $jsonLogin -ContentType "application/json"
    Write-Host "✅ Login exitoso!" -ForegroundColor Green
    Write-Host "Token: $($responseLogin.token)" -ForegroundColor Cyan
    Write-Host "Usuario: $($responseLogin.usuario.nombre)" -ForegroundColor Cyan
    Write-Host "Rol: $($responseLogin.usuario.rol)" -ForegroundColor Cyan
} catch {
    Write-Host "❌ Login falló: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host "Respuesta: $responseBody" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "🎯 Prueba completada!" -ForegroundColor Green
