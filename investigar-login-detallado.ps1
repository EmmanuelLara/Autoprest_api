# Script para investigar el problema de login de forma detallada
$baseUrl = "http://localhost:3000"

Write-Host "🔍 Investigación detallada del problema de login..." -ForegroundColor Yellow

# 1. Verificar logs del servidor
Write-Host "1️⃣ Verificando logs del servidor..." -ForegroundColor Cyan
docker-compose logs --tail=20 api

# 2. Probar con diferentes usuarios
Write-Host "2️⃣ Probando con diferentes usuarios..." -ForegroundColor Cyan

$usuarios = @(
    @{
        nombre = "Admin Test"
        telefono = "5512345678"
        email = "admin@test.com"
        pass = "admin123"
        rol = "admin"
    },
    @{
        nombre = "Cliente Test"
        telefono = "5512345679"
        email = "cliente@test.com"
        pass = "cliente123"
        rol = "cliente"
    },
    @{
        nombre = "Gerente Test"
        telefono = "5512345680"
        email = "gerente@test.com"
        pass = "gerente123"
        rol = "gerente"
    }
)

foreach ($usuario in $usuarios) {
    Write-Host "--- Probando usuario: $($usuario.email) ---" -ForegroundColor Magenta
    
    # Intentar registro
    $jsonRegistro = $usuario | ConvertTo-Json -Depth 10
    try {
        $response = Invoke-RestMethod -Uri "$baseUrl/registro" -Method POST -Body $jsonRegistro -ContentType "application/json"
        Write-Host "✅ Registro exitoso para $($usuario.email)" -ForegroundColor Green
    } catch {
        if ($_.Exception.Response.StatusCode -eq 409) {
            Write-Host "ℹ️ Usuario $($usuario.email) ya existe" -ForegroundColor Yellow
        } else {
            Write-Host "❌ Error en registro: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
        }
    }
    
    # Intentar login
    $loginData = @{
        email = $usuario.email
        pass = $usuario.pass
    }
    $jsonLogin = $loginData | ConvertTo-Json -Depth 10
    
    try {
        $response = Invoke-RestMethod -Uri "$baseUrl/login" -Method POST -Body $jsonLogin -ContentType "application/json"
        Write-Host "✅ Login exitoso para $($usuario.email)" -ForegroundColor Green
        Write-Host "   Token: $($response.token.Substring(0, 50))..." -ForegroundColor Gray
    } catch {
        Write-Host "❌ Login falló para $($usuario.email): $($_.Exception.Response.StatusCode)" -ForegroundColor Red
        
        if ($_.Exception.Response) {
            $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
            $responseBody = $reader.ReadToEnd()
            Write-Host "   Respuesta: $responseBody" -ForegroundColor Red
        }
    }
    
    Write-Host ""
}

# 3. Probar con contraseñas incorrectas para verificar que la validación funciona
Write-Host "3️⃣ Probando con contraseña incorrecta..." -ForegroundColor Cyan
$loginIncorrecto = @{
    email = "admin@test.com"
    pass = "contraseña_incorrecta"
}
$jsonIncorrecto = $loginIncorrecto | ConvertTo-Json -Depth 10

try {
    $response = Invoke-RestMethod -Uri "$baseUrl/login" -Method POST -Body $jsonIncorrecto -ContentType "application/json"
    Write-Host "❌ ERROR: Login exitoso con contraseña incorrecta!" -ForegroundColor Red
} catch {
    if ($_.Exception.Response.StatusCode -eq 401) {
        Write-Host "✅ Correcto: Login rechazado con contraseña incorrecta" -ForegroundColor Green
    } else {
        Write-Host "❌ Error inesperado: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
    }
}

Write-Host "🎯 Investigación completada!" -ForegroundColor Green
