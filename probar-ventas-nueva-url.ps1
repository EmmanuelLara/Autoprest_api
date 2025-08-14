# Script para probar ventas con la nueva URL de ngrok

Write-Host "🔍 Probando ventas con nueva URL..." -ForegroundColor Green

# Verificar si el servidor está corriendo
$serverRunning = netstat -ano | findstr :3000
if (-not $serverRunning) {
    Write-Host "❌ El servidor no está corriendo en el puerto 3000" -ForegroundColor Red
    Write-Host "💡 Ejecuta 'npm start' primero" -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ Servidor detectado en puerto 3000" -ForegroundColor Green

# Obtener la nueva URL de ngrok
try {
    $ngrokResponse = Invoke-RestMethod -Uri "http://localhost:4040/api/tunnels" -Method Get -TimeoutSec 5
    $publicUrl = $ngrokResponse.tunnels[0].public_url
    Write-Host "✅ Nueva URL de ngrok: $publicUrl" -ForegroundColor Green
} catch {
    Write-Host "❌ Ngrok no está funcionando" -ForegroundColor Red
    Write-Host "💡 Ejecuta .\solucionar-ngrok.ps1 primero" -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "🔍 Probando endpoints de ventas..." -ForegroundColor Yellow

# Función para hacer requests
function Test-Endpoint {
    param($Url, $Method, $Body, $Description, $Token, $ShowResponse = $false)
    
    try {
        $headers = @{
            "Content-Type" = "application/json"
        }
        
        if ($Token) {
            $headers["Authorization"] = "Bearer $Token"
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

# Login como gerente
Write-Host ""
Write-Host "👔 Login como gerente..." -ForegroundColor Cyan
$gerenteLoginData = @{
    email = "gerente@example.com"
    pass = "password123"
}

$gerenteLoginResponse = Test-Endpoint -Url "$publicUrl/login" -Method "POST" -Body $gerenteLoginData -Description "Login de gerente"

if (-not $gerenteLoginResponse -or -not $gerenteLoginResponse.token) {
    Write-Host "❌ No se pudo obtener token de gerente" -ForegroundColor Red
    exit 1
}

$gerenteToken = $gerenteLoginResponse.token
Write-Host "✅ Token de gerente obtenido" -ForegroundColor Green

# Probar GET /gerente/ventas (todas las ventas)
Write-Host ""
Write-Host "🔍 Probando GET /gerente/ventas..." -ForegroundColor Cyan
$todasVentasResponse = Test-Endpoint -Url "$publicUrl/gerente/ventas" -Method "GET" -Description "Obtener todas las ventas" -Token $gerenteToken -ShowResponse $true

# Probar GET /gerente/ventas/VIN/1HGBH41JXMN109198 (búsqueda específica)
Write-Host ""
Write-Host "🔍 Probando GET /gerente/ventas/VIN/1HGBH41JXMN109198..." -ForegroundColor Cyan
$ventaEspecificaResponse = Test-Endpoint -Url "$publicUrl/gerente/ventas/VIN/1HGBH41JXMN109198" -Method "GET" -Description "Buscar venta por VIN" -Token $gerenteToken -ShowResponse $true

# Probar GET /gerente/ventas/comprador_nombre/Pato (búsqueda por comprador)
Write-Host ""
Write-Host "🔍 Probando GET /gerente/ventas/comprador_nombre/Pato..." -ForegroundColor Cyan
$ventaCompradorResponse = Test-Endpoint -Url "$publicUrl/gerente/ventas/comprador_nombre/Pato" -Method "GET" -Description "Buscar venta por comprador" -Token $gerenteToken -ShowResponse $true

Write-Host ""
Write-Host "🎉 ¡Pruebas completadas!" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Resumen:" -ForegroundColor Yellow
Write-Host "   - Nueva URL de ngrok: $publicUrl" -ForegroundColor White
Write-Host "   - Login exitoso: $($gerenteLoginResponse -ne $null)" -ForegroundColor White
Write-Host "   - Todas las ventas: $($todasVentasResponse -ne $null)" -ForegroundColor White
Write-Host "   - Venta específica por VIN: $($ventaEspecificaResponse -ne $null)" -ForegroundColor White
Write-Host "   - Venta por comprador: $($ventaCompradorResponse -ne $null)" -ForegroundColor White
Write-Host ""
Write-Host "🔗 URL de la API: $publicUrl" -ForegroundColor Cyan
Write-Host "📚 Documentación: $publicUrl/api-docs/" -ForegroundColor Cyan
Write-Host ""
Write-Host "💡 Ahora puedes probar en Swagger UI:" -ForegroundColor Green
Write-Host "   1. Ve a: $publicUrl/api-docs/" -ForegroundColor White
Write-Host "   2. Haz login como gerente" -ForegroundColor White
Write-Host "   3. Prueba GET /gerente/ventas" -ForegroundColor White
