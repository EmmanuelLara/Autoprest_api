# Script específico para probar validación de tokens inválidos

Write-Host "🔐 Probando validación de tokens inválidos..." -ForegroundColor Green

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
    Write-Host "✅ URL de ngrok: $publicUrl" -ForegroundColor Green
} catch {
    Write-Host "❌ Ngrok no está funcionando" -ForegroundColor Red
    Write-Host "💡 Ejecuta .\solucionar-ngrok.ps1 primero" -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "🔐 Probando validación de tokens..." -ForegroundColor Yellow

# Función para hacer requests con headers personalizados
function Test-Endpoint-Custom {
    param($Url, $Method, $Body, $Description, $CustomHeaders, $ShowResponse = $false)
    
    try {
        $headers = @{
            "Content-Type" = "application/json"
        }
        
        # Agregar headers personalizados
        if ($CustomHeaders) {
            foreach ($key in $CustomHeaders.Keys) {
                $headers[$key] = $CustomHeaders[$key]
            }
        }
        
        if ($Method -eq "POST") {
            $response = Invoke-RestMethod -Uri $Url -Method $Method -Body ($Body | ConvertTo-Json) -Headers $headers -TimeoutSec 10
        } else {
            $response = Invoke-RestMethod -Uri $Url -Method $Method -Headers $headers -TimeoutSec 10
        }
        
        Write-Host "✅ $Description - OK" -ForegroundColor Green
        if ($ShowResponse) {
            Write-Host "📄 Respuesta: $($response | ConvertTo-Json -Depth 2)" -ForegroundColor Cyan
        }
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

# Login como cliente para obtener token válido
Write-Host ""
Write-Host "👤 Login como cliente..." -ForegroundColor Cyan
$clienteLoginData = @{
    email = "tortuga@example.com"
    pass = "password123"
}

$clienteLoginResponse = Test-Endpoint-Custom -Url "$publicUrl/login" -Method "POST" -Body $clienteLoginData -Description "Login de cliente"

if (-not $clienteLoginResponse -or -not $clienteLoginResponse.token) {
    Write-Host "❌ No se pudo obtener token de cliente" -ForegroundColor Red
    exit 1
}

$clienteToken = $clienteLoginResponse.token
Write-Host "✅ Token de cliente obtenido: $($clienteToken.Substring(0, 20))..." -ForegroundColor Green

Write-Host ""
Write-Host "🧪 PRUEBA 1: Token válido (debería funcionar)..." -ForegroundColor Cyan
$headersValidos = @{
    "Authorization" = "Bearer $clienteToken"
}
$testTokenValido = Test-Endpoint-Custom -Url "$publicUrl/cliente/vehiculos" -Method "GET" -Description "Probar con token válido" -CustomHeaders $headersValidos

Write-Host ""
Write-Host "🧪 PRUEBA 2: Token inválido (debería fallar)..." -ForegroundColor Cyan
# Crear un token inválido cambiando la última letra
$tokenInvalido = $clienteToken.Substring(0, $clienteToken.Length - 1) + "X"
Write-Host "📝 Token inválido creado: $($tokenInvalido.Substring(0, 20))..." -ForegroundColor Gray

$headersTokenInvalido = @{
    "Authorization" = "Bearer $tokenInvalido"
}
$testTokenInvalido = Test-Endpoint-Custom -Url "$publicUrl/gerente/vehiculos" -Method "GET" -Description "Probar con token inválido" -CustomHeaders $headersTokenInvalido

Write-Host ""
Write-Host "🧪 PRUEBA 3: Sin prefijo Bearer (debería fallar)..." -ForegroundColor Cyan
$headersSinBearer = @{
    "Authorization" = $clienteToken
}
$testSinBearer = Test-Endpoint-Custom -Url "$publicUrl/gerente/vehiculos" -Method "GET" -Description "Probar sin prefijo Bearer" -CustomHeaders $headersSinBearer

Write-Host ""
Write-Host "🧪 PRUEBA 4: Sin header Authorization (debería fallar)..." -ForegroundColor Cyan
$testSinAuth = Test-Endpoint-Custom -Url "$publicUrl/gerente/vehiculos" -Method "GET" -Description "Probar sin header Authorization"

Write-Host ""
Write-Host "🧪 PRUEBA 5: Token vacío (debería fallar)..." -ForegroundColor Cyan
$headersTokenVacio = @{
    "Authorization" = "Bearer "
}
$testTokenVacio = Test-Endpoint-Custom -Url "$publicUrl/gerente/vehiculos" -Method "GET" -Description "Probar con token vacío" -CustomHeaders $headersTokenVacio

Write-Host ""
Write-Host "🧪 PRUEBA 6: Token con caracteres aleatorios (debería fallar)..." -ForegroundColor Cyan
$tokenAleatorio = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJfaWQiOiI2ODk3YmYwMmM3MGNkZjUzMzczMjU1OTciLCJyb2wiOiJjbGllbnRlIiwibm9tYnJlIjoiY2FyYWNvbCIsInRlbGVmb25vIjoiNTUxMjM0NTY3OCIsIm1hdCIxNzU0ODg3NiIsImlhdCI6MTc1NDg4NzYsImV4cCI6MTc1NDk3NDB9.INVALID_SIGNATURE"
Write-Host "📝 Token aleatorio: $($tokenAleatorio.Substring(0, 50))..." -ForegroundColor Gray

$headersTokenAleatorio = @{
    "Authorization" = "Bearer $tokenAleatorio"
}
$testTokenAleatorio = Test-Endpoint-Custom -Url "$publicUrl/gerente/vehiculos" -Method "GET" -Description "Probar con token aleatorio" -CustomHeaders $headersTokenAleatorio

Write-Host ""
Write-Host "🎉 ¡Pruebas de validación de tokens completadas!" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Resumen de validaciones de token:" -ForegroundColor Yellow
Write-Host "   ✅ Token válido: Debería permitir acceso" -ForegroundColor White
Write-Host "   ✅ Token inválido: Debería rechazar con 'Token inválido'" -ForegroundColor White
Write-Host "   ✅ Sin Bearer: Debería rechazar con 'Formato de token inválido'" -ForegroundColor White
Write-Host "   ✅ Sin Authorization: Debería rechazar con 'Token requerido'" -ForegroundColor White
Write-Host "   ✅ Token vacío: Debería rechazar con 'Token requerido'" -ForegroundColor White
Write-Host "   ✅ Token aleatorio: Debería rechazar con 'Token inválido'" -ForegroundColor White
Write-Host ""
Write-Host "🔗 URL de la API: $publicUrl" -ForegroundColor Cyan
Write-Host "📚 Documentación: $publicUrl/api-docs/" -ForegroundColor Cyan
