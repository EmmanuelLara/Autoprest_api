# Script para probar con un usuario específico
$baseUrl = "http://localhost:3000"

Write-Host "🔐 Probador de usuario específico" -ForegroundColor Yellow
Write-Host "===============================" -ForegroundColor Yellow

# Solicitar datos específicos
Write-Host "Ingresa los datos del usuario que no funciona:" -ForegroundColor Cyan

$email = Read-Host "Email del usuario"
$password = Read-Host "Contraseña del usuario" -AsSecureString
$passwordPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($password))

Write-Host ""
Write-Host "📤 Probando usuario específico..." -ForegroundColor Cyan
Write-Host "Email: $email" -ForegroundColor Gray
Write-Host "Contraseña: $passwordPlain" -ForegroundColor Gray

# 1. Verificar si el usuario existe intentando registrarlo
Write-Host ""
Write-Host "1️⃣ Verificando si el usuario existe..." -ForegroundColor Cyan

$registroData = @{
    nombre = "Usuario Verificación"
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
        
        # Si ya existe, intentar login
        Write-Host ""
        Write-Host "2️⃣ Intentando login con usuario existente..." -ForegroundColor Cyan
        
        $loginData = @{
            email = $email
            pass = $passwordPlain
        }
        $jsonLogin = $loginData | ConvertTo-Json -Depth 10
        
        try {
            $responseLogin = Invoke-RestMethod -Uri "$baseUrl/login" -Method POST -Body $jsonLogin -ContentType "application/json"
            Write-Host "✅ Login exitoso!" -ForegroundColor Green
            Write-Host "Token: $($responseLogin.token)" -ForegroundColor Cyan
            Write-Host "Usuario: $($responseLogin.usuario.nombre)" -ForegroundColor Cyan
            Write-Host "Rol: $($responseLogin.usuario.rol)" -ForegroundColor Cyan
        } catch {
            Write-Host "❌ Login falló:" -ForegroundColor Red
            Write-Host "Status: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
            
            if ($_.Exception.Response) {
                $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
                $responseBody = $reader.ReadToEnd()
                Write-Host "Respuesta: $responseBody" -ForegroundColor Red
            }
            
            # Probar con diferentes variaciones de la contraseña
            Write-Host ""
            Write-Host "3️⃣ Probando variaciones de contraseña..." -ForegroundColor Cyan
            
            $variacionesPass = @(
                $passwordPlain,
                $passwordPlain.Trim(),
                $passwordPlain.ToLower(),
                $passwordPlain.ToUpper(),
                " $passwordPlain ",
                $passwordPlain.Replace(" ", "")
            )
            
            foreach ($passVar in $variacionesPass) {
                Write-Host "Probando contraseña: '$passVar'" -ForegroundColor Gray
                
                $loginVar = @{
                    email = $email
                    pass = $passVar
                }
                $jsonVar = $loginVar | ConvertTo-Json -Depth 10
                
                try {
                    $responseVar = Invoke-RestMethod -Uri "$baseUrl/login" -Method POST -Body $jsonVar -ContentType "application/json"
                    Write-Host "✅ Login exitoso con contraseña: '$passVar'" -ForegroundColor Green
                    break
                } catch {
                    Write-Host "❌ Falló con contraseña: '$passVar'" -ForegroundColor Red
                }
            }
        }
    } else {
        Write-Host "❌ Error en registro: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
        if ($_.Exception.Response) {
            $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
            $responseBody = $reader.ReadToEnd()
            Write-Host "Respuesta: $responseBody" -ForegroundColor Red
        }
    }
}

Write-Host ""
Write-Host "🎯 Prueba completada!" -ForegroundColor Green
