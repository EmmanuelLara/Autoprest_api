# Script para probar directamente con localhost

Write-Host "🧪 Probando directamente con localhost..." -ForegroundColor Green

# Verificar si el servidor está corriendo
$serverRunning = netstat -ano | findstr :3000
if (-not $serverRunning) {
    Write-Host "❌ El servidor no está corriendo en el puerto 3000" -ForegroundColor Red
    Write-Host "💡 Ejecuta 'npm start' primero" -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ Servidor detectado en puerto 3000" -ForegroundColor Green

Write-Host ""
Write-Host "🧪 Probando con localhost..." -ForegroundColor Yellow

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

# Login como gerente para obtener token válido
Write-Host ""
Write-Host "👤 Login como gerente..." -ForegroundColor Cyan
$gerenteLoginData = @{
    email = "gerente@example.com"
    pass = "password123"
}

$gerenteLoginResponse = Test-Endpoint-Custom -Url "http://localhost:3000/login" -Method "POST" -Body $gerenteLoginData -Description "Login de gerente"

if (-not $gerenteLoginResponse -or -not $gerenteLoginResponse.token) {
    Write-Host "❌ No se pudo obtener token de gerente" -ForegroundColor Red
    exit 1
}

$gerenteToken = $gerenteLoginResponse.token
Write-Host "✅ Token de gerente obtenido: $($gerenteToken.Substring(0, 50))..." -ForegroundColor Green

Write-Host ""
Write-Host "🧪 PRUEBA 1: Endpoint sin autenticación (debería funcionar)..." -ForegroundColor Cyan
$testSinAuth = Test-Endpoint-Custom -Url "http://localhost:3000/test" -Method "GET" -Description "Probar endpoint sin autenticación"

Write-Host ""
Write-Host "🧪 PRUEBA 2: Endpoint con autenticación válida (debería funcionar)..." -ForegroundColor Cyan
$headersValidos = @{
    "Authorization" = "Bearer $gerenteToken"
}
$testConAuth = Test-Endpoint-Custom -Url "http://localhost:3000/test-auth" -Method "GET" -Description "Probar endpoint con autenticación válida" -CustomHeaders $headersValidos -ShowResponse $true

Write-Host ""
Write-Host "🧪 PRUEBA 3: Endpoint con token inválido (debería fallar)..." -ForegroundColor Cyan
$tokenInvalido = $gerenteToken + "W"
$headersTokenInvalido = @{
    "Authorization" = "Bearer $tokenInvalido"
}
$testTokenInvalido = Test-Endpoint-Custom -Url "http://localhost:3000/test-auth" -Method "GET" -Description "Probar endpoint con token inválido" -CustomHeaders $headersTokenInvalido

Write-Host ""
Write-Host "🧪 PRUEBA 4: Endpoint sin token (debería fallar)..." -ForegroundColor Cyan
$testSinToken = Test-Endpoint-Custom -Url "http://localhost:3000/test-auth" -Method "GET" -Description "Probar endpoint sin token"

Write-Host ""
Write-Host "🎉 ¡Pruebas con localhost completadas!" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Resumen de pruebas:" -ForegroundColor Yellow
Write-Host "   ✅ Endpoint sin auth: Debería funcionar" -ForegroundColor White
Write-Host "   ✅ Endpoint con auth válida: Debería funcionar" -ForegroundColor White
Write-Host "   ❌ Endpoint con token inválido: Debería fallar" -ForegroundColor White
Write-Host "   ❌ Endpoint sin token: Debería fallar" -ForegroundColor White
Write-Host ""
Write-Host "💡 Si las pruebas 3 y 4 muestran 'OK' en lugar de errores, hay un problema con la validación" -ForegroundColor Red
