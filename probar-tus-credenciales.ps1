# Script para probar con las credenciales específicas del usuario
$baseUrl = "http://localhost:3000"

Write-Host "🔐 Probador de credenciales específicas" -ForegroundColor Yellow
Write-Host "=====================================" -ForegroundColor Yellow

# Solicitar credenciales al usuario
Write-Host "Por favor, ingresa las credenciales que no están funcionando:" -ForegroundColor Cyan

$email = Read-Host "Email"
$password = Read-Host "Contraseña" -AsSecureString
$passwordPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($password))

Write-Host ""
Write-Host "📤 Probando con tus credenciales..." -ForegroundColor Cyan
Write-Host "Email: $email" -ForegroundColor Gray
Write-Host "Contraseña: $passwordPlain" -ForegroundColor Gray

# 1. Primero intentar login directo
Write-Host ""
Write-Host "1️⃣ Intentando login directo..." -ForegroundColor Cyan

$loginData = @{
    email = $email
    pass = $passwordPlain
}
$jsonLogin = $loginData | ConvertTo-Json -Depth 10

try {
    $response = Invoke-RestMethod -Uri "$baseUrl/login" -Method POST -Body $jsonLogin -ContentType "application/json"
    Write-Host "✅ Login exitoso!" -ForegroundColor Green
    Write-Host "Token: $($response.token)" -ForegroundColor Cyan
    Write-Host "Usuario: $($response.usuario.nombre)" -ForegroundColor Cyan
    Write-Host "Rol: $($response.usuario.rol)" -ForegroundColor Cyan
} catch {
    Write-Host "❌ Login falló:" -ForegroundColor Red
    Write-Host "Status: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
    
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host "Respuesta: $responseBody" -ForegroundColor Red
    }
}

# 2. Intentar registro para ver si el usuario existe
Write-Host ""
Write-Host "2️⃣ Verificando si el usuario existe..." -ForegroundColor Cyan

$registroData = @{
    nombre = "Usuario Test"
    telefono = "5512345678"
    email = $email
    pass = $passwordPlain
    rol = "cliente"
}
$jsonRegistro = $registroData | ConvertTo-Json -Depth 10

try {
    $response = Invoke-RestMethod -Uri "$baseUrl/registro" -Method POST -Body $jsonRegistro -ContentType "application/json"
    Write-Host "✅ Usuario registrado exitosamente (era nuevo)" -ForegroundColor Green
    Write-Host "Token: $($response.token)" -ForegroundColor Cyan
} catch {
    if ($_.Exception.Response.StatusCode -eq 409) {
        Write-Host "ℹ️ El usuario ya existe en la base de datos" -ForegroundColor Yellow
    } else {
        Write-Host "❌ Error en registro: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
        if ($_.Exception.Response) {
            $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
            $responseBody = $reader.ReadToEnd()
            Write-Host "Respuesta: $responseBody" -ForegroundColor Red
        }
    }
}

# 3. Probar con diferentes variaciones del email
Write-Host ""
Write-Host "3️⃣ Probando con variaciones del email..." -ForegroundColor Cyan

$variaciones = @(
    $email,
    $email.ToLower(),
    $email.ToUpper(),
    $email.Trim(),
    " $email ",
    $email.Replace("@", " @ ")
)

foreach ($variacion in $variaciones) {
    Write-Host "Probando: '$variacion'" -ForegroundColor Gray
    
    $loginVariacion = @{
        email = $variacion
        pass = $passwordPlain
    }
    $jsonVariacion = $loginVariacion | ConvertTo-Json -Depth 10
    
    try {
        $response = Invoke-RestMethod -Uri "$baseUrl/login" -Method POST -Body $jsonVariacion -ContentType "application/json"
        Write-Host "✅ Login exitoso con variación: '$variacion'" -ForegroundColor Green
        break
    } catch {
        Write-Host "❌ Falló con '$variacion': $($_.Exception.Response.StatusCode)" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "🎯 Prueba completada!" -ForegroundColor Green
Write-Host "💡 Si el login falló, verifica:" -ForegroundColor Cyan
Write-Host "   - Que el email esté escrito correctamente" -ForegroundColor Gray
Write-Host "   - Que la contraseña sea la correcta" -ForegroundColor Gray
Write-Host "   - Que no haya espacios extra" -ForegroundColor Gray
