# Script para probar credenciales específicas que no funcionan
$baseUrl = "http://localhost:3000"

Write-Host "🔐 Probador de credenciales específicas" -ForegroundColor Yellow
Write-Host "=====================================" -ForegroundColor Yellow

Write-Host "Por favor, ingresa las credenciales exactas que no están funcionando:" -ForegroundColor Cyan
Write-Host "(Estas son las credenciales que funcionaban antes pero ahora no)" -ForegroundColor Gray

$email = Read-Host "Email del usuario"
$password = Read-Host "Contraseña del usuario" -AsSecureString
$passwordPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($password))

Write-Host ""
Write-Host "📤 Probando credenciales específicas..." -ForegroundColor Cyan
Write-Host "Email: '$email'" -ForegroundColor Gray
Write-Host "Contraseña: '$passwordPlain'" -ForegroundColor Gray

# 1. Verificar si el usuario existe
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
    Write-Host "Token: $($response.token.Substring(0, 50))..." -ForegroundColor Cyan
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
            
            # Probar con diferentes variaciones
            Write-Host ""
            Write-Host "3️⃣ Probando variaciones..." -ForegroundColor Cyan
            
            # Variaciones del email
            $emailsVariaciones = @(
                $email,
                $email.ToLower(),
                $email.ToUpper(),
                $email.Trim(),
                " $email ",
                $email.Replace("@", " @ ")
            )
            
            # Variaciones de la contraseña
            $passVariaciones = @(
                $passwordPlain,
                $passwordPlain.Trim(),
                $passwordPlain.ToLower(),
                $passwordPlain.ToUpper(),
                " $passwordPlain ",
                $passwordPlain.Replace(" ", "")
            )
            
            $encontrado = $false
            
            foreach ($emailVar in $emailsVariaciones) {
                if ($encontrado) { break }
                foreach ($passVar in $passVariaciones) {
                    Write-Host "Probando: Email='$emailVar', Pass='$passVar'" -ForegroundColor Gray
                    
                    $loginVar = @{
                        email = $emailVar
                        pass = $passVar
                    }
                    $jsonVar = $loginVar | ConvertTo-Json -Depth 10
                    
                    try {
                        $responseVar = Invoke-RestMethod -Uri "$baseUrl/login" -Method POST -Body $jsonVar -ContentType "application/json"
                        Write-Host "✅ Login exitoso con: Email='$emailVar', Pass='$passVar'" -ForegroundColor Green
                        $encontrado = $true
                        break
                    } catch {
                        Write-Host "❌ Falló con: Email='$emailVar', Pass='$passVar'" -ForegroundColor Red
                    }
                }
            }
            
            if (-not $encontrado) {
                Write-Host ""
                Write-Host "❌ No se encontró ninguna combinación que funcione" -ForegroundColor Red
                Write-Host "💡 Posibles causas:" -ForegroundColor Cyan
                Write-Host "   - La contraseña en la base de datos es diferente" -ForegroundColor Gray
                Write-Host "   - El usuario fue creado con diferentes credenciales" -ForegroundColor Gray
                Write-Host "   - Hay un problema con el hashing de la contraseña" -ForegroundColor Gray
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
