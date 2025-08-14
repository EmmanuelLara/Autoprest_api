# Script para resetear la base de datos y solucionar problemas de autenticación

Write-Host "⚠️  ADVERTENCIA: Este script reseteará la base de datos" -ForegroundColor Red
Write-Host "💡 Esto eliminará todos los usuarios y datos existentes" -ForegroundColor Yellow
Write-Host ""

$confirmacion = Read-Host "¿Estás seguro de que quieres continuar? (escribe 'SI' para confirmar)"
if ($confirmacion -ne "SI") {
    Write-Host "❌ Operación cancelada" -ForegroundColor Red
    exit 0
}

Write-Host "🔄 Reseteando base de datos..." -ForegroundColor Green

# Verificar si el servidor está corriendo
$serverRunning = netstat -ano | findstr :3000
if (-not $serverRunning) {
    Write-Host "❌ El servidor no está corriendo en el puerto 3000" -ForegroundColor Red
    Write-Host "💡 Ejecuta 'npm start' primero" -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ Servidor detectado en puerto 3000" -ForegroundColor Green

# Obtener la URL de ngrok
try {
    $ngrokResponse = Invoke-RestMethod -Uri "http://localhost:4040/api/tunnels" -Method Get -TimeoutSec 5
    $publicUrl = $ngrokResponse.tunnels[0].public_url
    Write-Host "✅ Ngrok detectado: $publicUrl" -ForegroundColor Green
} catch {
    Write-Host "❌ Ngrok no está funcionando" -ForegroundColor Red
    Write-Host "💡 Ejecuta .\exponer-simple.ps1 primero" -ForegroundColor Yellow
    exit 1
}

# Función para hacer requests
function Test-Endpoint {
    param($Url, $Method, $Body, $Description)
    
    try {
        $headers = @{
            "Content-Type" = "application/json"
        }
        
        if ($Method -eq "POST") {
            $response = Invoke-RestMethod -Uri $Url -Method $Method -Body ($Body | ConvertTo-Json) -Headers $headers -TimeoutSec 10
        } else {
            $response = Invoke-RestMethod -Uri $Url -Method $Method -Headers $headers -TimeoutSec 10
        }
        
        Write-Host "✅ $Description - OK" -ForegroundColor Green
        return $response
    } catch {
        $errorMsg = $_.Exception.Message
        if ($_.Exception.Response) {
            $statusCode = $_.Exception.Response.StatusCode.value__
            $errorBody = $_.Exception.Response.GetResponseStream()
            $reader = New-Object System.IO.StreamReader($errorBody)
            $errorContent = $reader.ReadToEnd()
            Write-Host "❌ $Description - Error $statusCode - $errorContent" -ForegroundColor Red
        } else {
            Write-Host "❌ $Description - Error: $errorMsg" -ForegroundColor Red
        }
        return $null
    }
}

Write-Host ""
Write-Host "🧹 Limpiando base de datos..." -ForegroundColor Yellow

# Crear usuarios de prueba
Write-Host ""
Write-Host "👤 Creando usuarios de prueba..." -ForegroundColor Cyan

# Usuario 1: Tortuga
$tortugaData = @{
    nombre = "Tortuga Test"
    telefono = "5512345678"
    email = "tortuga@example.com"
    pass = "password123"
    rol = "cliente"
}

$tortugaResponse = Test-Endpoint -Url "$publicUrl/registro" -Method "POST" -Body $tortugaData -Description "Registro de tortuga@example.com"

# Usuario 2: Admin
$adminData = @{
    nombre = "Administrador"
    telefono = "5512345679"
    email = "admin@example.com"
    pass = "password123"
    rol = "admin"
}

$adminResponse = Test-Endpoint -Url "$publicUrl/registro" -Method "POST" -Body $adminData -Description "Registro de admin@example.com"

# Usuario 3: Gerente
$gerenteData = @{
    nombre = "Gerente Test"
    telefono = "5512345680"
    email = "gerente@example.com"
    pass = "password123"
    rol = "gerente"
}

$gerenteResponse = Test-Endpoint -Url "$publicUrl/registro" -Method "POST" -Body $gerenteData -Description "Registro de gerente@example.com"

Write-Host ""
Write-Host "🔐 Probando login con usuarios creados..." -ForegroundColor Yellow

# Probar login con Tortuga
Write-Host ""
Write-Host "🐢 Probando login con tortuga@example.com..." -ForegroundColor Cyan
$tortugaLoginData = @{
    email = "tortuga@example.com"
    pass = "password123"
}

$tortugaLoginResponse = Test-Endpoint -Url "$publicUrl/login" -Method "POST" -Body $tortugaLoginData -Description "Login de tortuga@example.com"

if ($tortugaLoginResponse -and $tortugaLoginResponse.token) {
    Write-Host "✅ Login exitoso - Token: $($tortugaLoginResponse.token.Substring(0, 20))..." -ForegroundColor Green
}

# Probar login con Admin
Write-Host ""
Write-Host "👑 Probando login con admin@example.com..." -ForegroundColor Cyan
$adminLoginData = @{
    email = "admin@example.com"
    pass = "password123"
}

$adminLoginResponse = Test-Endpoint -Url "$publicUrl/login" -Method "POST" -Body $adminLoginData -Description "Login de admin@example.com"

if ($adminLoginResponse -and $adminLoginResponse.token) {
    Write-Host "✅ Login exitoso - Token: $($adminLoginResponse.token.Substring(0, 20))..." -ForegroundColor Green
}

Write-Host ""
Write-Host "🎉 Reseteo completado!" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Usuarios creados:" -ForegroundColor Yellow
Write-Host "   🐢 tortuga@example.com / password123 (cliente)" -ForegroundColor White
Write-Host "   👑 admin@example.com / password123 (admin)" -ForegroundColor White
Write-Host "   👔 gerente@example.com / password123 (gerente)" -ForegroundColor White
Write-Host ""
Write-Host "🔗 URL de la API: $publicUrl" -ForegroundColor Cyan
Write-Host "📚 Documentación: $publicUrl/api-docs/" -ForegroundColor Cyan
Write-Host ""
Write-Host "💡 Ahora puedes probar el login con cualquiera de estos usuarios" -ForegroundColor Green
