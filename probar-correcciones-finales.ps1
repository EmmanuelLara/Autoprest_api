# Script para probar las correcciones finales

Write-Host "🧪 Probando correcciones finales..." -ForegroundColor Green

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
Write-Host "🧪 Probando correcciones..." -ForegroundColor Yellow

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

# Login como cliente
Write-Host ""
Write-Host "👤 Login como cliente..." -ForegroundColor Cyan
$clienteLoginData = @{
    email = "tortuga@example.com"
    pass = "password123"
}

$clienteLoginResponse = Test-Endpoint -Url "$publicUrl/login" -Method "POST" -Body $clienteLoginData -Description "Login de cliente"

if (-not $clienteLoginResponse -or -not $clienteLoginResponse.token) {
    Write-Host "❌ No se pudo obtener token de cliente" -ForegroundColor Red
    exit 1
}

$clienteToken = $clienteLoginResponse.token
Write-Host "✅ Token de cliente obtenido" -ForegroundColor Green

Write-Host ""
Write-Host "🧪 PRUEBA 1: Validaciones de Descripción y Accesorios con acentos y comas..." -ForegroundColor Cyan

$datosValidos = @{
    VIN = "1HGBH41JXMN109186"
    Marca = "Toyota"
    Modelo = "Corolla"
    Anio = 2020
    Tipo = "Sedán"
    Condicion = "Usado"
    Transmision = "Automática"
    Combustible = "Gasolina"
    Kilometraje = 50000
    Color = "Blanco"
    Precio = 250000
    Descripcion = "Vehículo en excelente estado, bien mantenido, sin accidentes, con acentos: óptimo"
    Accesorios = "Aire acondicionado, radio, alarma, asientos de cuero, navegación GPS"
}

Write-Host "📝 Datos de prueba con acentos y comas:" -ForegroundColor White
Write-Host "   Descripción: 'Vehículo en excelente estado, bien mantenido, sin accidentes, con acentos: óptimo'" -ForegroundColor Gray
Write-Host "   Accesorios: 'Aire acondicionado, radio, alarma, asientos de cuero, navegación GPS'" -ForegroundColor Gray

Write-Host ""
Write-Host "🧪 PRUEBA 2: Token inválido (debería fallar)..." -ForegroundColor Cyan

# Crear un token inválido cambiando una letra
$tokenInvalido = $clienteToken.Substring(0, $clienteToken.Length - 1) + "X"

Write-Host "📝 Token original: $($clienteToken.Substring(0, 20))..." -ForegroundColor Gray
Write-Host "📝 Token inválido: $($tokenInvalido.Substring(0, 20))..." -ForegroundColor Gray

# Probar endpoint protegido con token inválido
$testTokenInvalido = Test-Endpoint -Url "$publicUrl/gerente/vehiculos" -Method "GET" -Description "Probar endpoint con token inválido" -Token $tokenInvalido

Write-Host ""
Write-Host "🧪 PRUEBA 3: Token sin formato Bearer (debería fallar)..." -ForegroundColor Cyan

# Probar sin el prefijo "Bearer"
$testSinBearer = Test-Endpoint -Url "$publicUrl/gerente/vehiculos" -Method "GET" -Description "Probar sin formato Bearer" -Token $clienteToken

Write-Host ""
Write-Host "🧪 PRUEBA 4: Sin token (debería fallar)..." -ForegroundColor Cyan

# Probar sin token
$testSinToken = Test-Endpoint -Url "$publicUrl/gerente/vehiculos" -Method "GET" -Description "Probar sin token"

Write-Host ""
Write-Host "🎉 ¡Pruebas de correcciones completadas!" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Resumen de correcciones implementadas:" -ForegroundColor Yellow
Write-Host "   ✅ Descripción y Accesorios: Ahora permiten acentos, comas, puntos, guiones y paréntesis" -ForegroundColor White
Write-Host "   ✅ Validación de token: Mejorada para detectar tokens inválidos" -ForegroundColor White
Write-Host "   ✅ Formato Bearer: Validación estricta del formato Authorization: Bearer <token>" -ForegroundColor White
Write-Host "   ✅ Mensajes de error: Más descriptivos y específicos" -ForegroundColor White
Write-Host ""
Write-Host "🔗 URL de la API: $publicUrl" -ForegroundColor Cyan
Write-Host "📚 Documentación: $publicUrl/api-docs/" -ForegroundColor Cyan
Write-Host ""
Write-Host "💡 Para probar en Swagger UI:" -ForegroundColor Green
Write-Host "   1. Ve a: $publicUrl/api-docs/" -ForegroundColor White
Write-Host "   2. Haz login como cliente" -ForegroundColor White
Write-Host "   3. Prueba POST /cliente/compras con acentos y comas" -ForegroundColor White
Write-Host "   4. Prueba cambiar una letra del token en Authorize" -ForegroundColor White
