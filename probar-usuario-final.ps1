# Script final para probar con el usuario específico
$baseUrl = "http://localhost:3000"

Write-Host "🔐 Probando usuario específico final..." -ForegroundColor Yellow

# Usuario específico que mencionaste
$usuarioEspecifico = @{
    nombre = "Usuario Rinoceronte"
    telefono = "5512345678"
    email = "rinoceronte@example.com"
    pass = "password123"
    rol = "cliente"
}

$jsonEspecifico = $usuarioEspecifico | ConvertTo-Json -Depth 10
Write-Host "JSON: $jsonEspecifico" -ForegroundColor Gray

# 1. Intentar registro
Write-Host ""
Write-Host "1️⃣ Intentando registro..." -ForegroundColor Cyan

try {
    $response = Invoke-RestMethod -Uri "$baseUrl/registro" -Method POST -Body $jsonEspecifico -ContentType "application/json"
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
    email = $usuarioEspecifico.email
    pass = $usuarioEspecifico.pass
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
Write-Host "💡 Si el login funciona, el problema estaba resuelto." -ForegroundColor Cyan
Write-Host "💡 Si aún falla, necesitamos investigar más." -ForegroundColor Cyan
