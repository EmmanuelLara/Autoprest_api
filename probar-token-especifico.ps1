# Script para probar el caso específico del token con letra extra

Write-Host "🔐 Probando caso específico del token con letra extra..." -ForegroundColor Green

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
Write-Host "🔐 Probando caso específico..." -ForegroundColor Yellow

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

$gerenteLoginResponse = Test-Endpoint-Custom -Url "$publicUrl/login" -Method "POST" -Body $gerenteLoginData -Description "Login de gerente"

if (-not $gerenteLoginResponse -or -not $gerenteLoginResponse.token) {
    Write-Host "❌ No se pudo obtener token de gerente" -ForegroundColor Red
    exit 1
}

$gerenteToken = $gerenteLoginResponse.token
Write-Host "✅ Token de gerente obtenido: $($gerenteToken.Substring(0, 50))..." -ForegroundColor Green

Write-Host ""
Write-Host "🧪 PRUEBA 1: Token válido (debería funcionar)..." -ForegroundColor Cyan
$headersValidos = @{
    "Authorization" = "Bearer $gerenteToken"
}
$testTokenValido = Test-Endpoint-Custom -Url "$publicUrl/gerente/vehiculos" -Method "GET" -Description "Probar con token válido" -CustomHeaders $headersValidos

Write-Host ""
Write-Host "🧪 PRUEBA 2: Token con letra extra al final (debería fallar)..." -ForegroundColor Cyan
# Crear un token inválido agregando una letra al final (como en tu ejemplo)
$tokenConLetraExtra = $gerenteToken + "W"
Write-Host "📝 Token original: $($gerenteToken.Substring($gerenteToken.Length - 10))" -ForegroundColor Gray
Write-Host "📝 Token con letra extra: $($tokenConLetraExtra.Substring($tokenConLetraExtra.Length - 11))" -ForegroundColor Gray

$headersTokenConLetraExtra = @{
    "Authorization" = "Bearer $tokenConLetraExtra"
}
$testTokenConLetraExtra = Test-Endpoint-Custom -Url "$publicUrl/gerente/vehiculos" -Method "GET" -Description "Probar con token con letra extra" -CustomHeaders $headersTokenConLetraExtra

Write-Host ""
Write-Host "🧪 PRUEBA 3: Token con letra extra en medio (debería fallar)..." -ForegroundColor Cyan
# Crear un token inválido agregando una letra en medio
$tokenConLetraEnMedio = $gerenteToken.Substring(0, 50) + "X" + $gerenteToken.Substring(50)
Write-Host "📝 Token con letra en medio: $($tokenConLetraEnMedio.Substring(45, 15))" -ForegroundColor Gray

$headersTokenConLetraEnMedio = @{
    "Authorization" = "Bearer $tokenConLetraEnMedio"
}
$testTokenConLetraEnMedio = Test-Endpoint-Custom -Url "$publicUrl/gerente/vehiculos" -Method "GET" -Description "Probar con token con letra en medio" -CustomHeaders $headersTokenConLetraEnMedio

Write-Host ""
Write-Host "🧪 PRUEBA 4: Token completamente aleatorio (debería fallar)..." -ForegroundColor Cyan
$tokenAleatorio = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJfaWQiOiI2ODk3YzViYmM3OGNkZjUzMzczMjU1OWMiLCJyb2wiOiJnZXJlbnRlIiwibm9tYnJlIjoiY2VicmEiLCJ0ZWxlZm9ubyI6IjU1MTIzNDU2NzgiLCJpYXQiOjE3NTQ4ODg3OTUsImV4cCI6MTc1NDk3NTE5NX0.INVALID_SIGNATURE_WITH_EXTRA_LETTERS"
Write-Host "📝 Token aleatorio: $($tokenAleatorio.Substring(0, 50))..." -ForegroundColor Gray

$headersTokenAleatorio = @{
    "Authorization" = "Bearer $tokenAleatorio"
}
$testTokenAleatorio = Test-Endpoint-Custom -Url "$publicUrl/gerente/vehiculos" -Method "GET" -Description "Probar con token aleatorio" -CustomHeaders $headersTokenAleatorio

Write-Host ""
Write-Host "🎉 ¡Pruebas de token específico completadas!" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Resumen de pruebas:" -ForegroundColor Yellow
Write-Host "   ✅ Token válido: Debería permitir acceso" -ForegroundColor White
Write-Host "   ❌ Token con letra extra al final: Debería rechazar" -ForegroundColor White
Write-Host "   ❌ Token con letra extra en medio: Debería rechazar" -ForegroundColor White
Write-Host "   ❌ Token aleatorio: Debería rechazar" -ForegroundColor White
Write-Host ""
Write-Host "🔗 URL de la API: $publicUrl" -ForegroundColor Cyan
Write-Host "📚 Documentación: $publicUrl/api-docs/" -ForegroundColor Cyan
Write-Host ""
Write-Host "💡 Si las pruebas 2, 3 y 4 muestran 'OK' en lugar de errores, hay un problema con la validación" -ForegroundColor Red
