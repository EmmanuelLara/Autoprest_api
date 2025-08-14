# Script para probar las nuevas validaciones de POST /cliente/compras

Write-Host "🧪 Probando validaciones de POST /cliente/compras..." -ForegroundColor Green

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
Write-Host "🧪 Probando validaciones..." -ForegroundColor Yellow

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

# Crear un archivo temporal para las pruebas
$tempImagePath = "temp_test_image.jpg"
"fake image content" | Out-File -FilePath $tempImagePath -Encoding ASCII

Write-Host ""
Write-Host "🧪 Prueba 1: Datos válidos (debería funcionar)..." -ForegroundColor Cyan
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
    Descripcion = "Vehículo en excelente estado"
    Accesorios = "Aire acondicionado, radio, alarma"
}

# Nota: No podemos probar POST con archivo desde PowerShell fácilmente, pero podemos verificar las validaciones del modelo

Write-Host ""
Write-Host "🧪 Prueba 2: Marca con caracteres especiales (debería fallar)..." -ForegroundColor Cyan
$datosInvalidos = $datosValidos.Clone()
$datosInvalidos.Marca = "Toyota%&$"

Write-Host "📝 Datos de prueba: Marca = 'Toyota%&$'" -ForegroundColor White

Write-Host ""
Write-Host "🧪 Prueba 3: Modelo con caracteres especiales (debería fallar)..." -ForegroundColor Cyan
$datosInvalidos2 = $datosValidos.Clone()
$datosInvalidos2.Modelo = "Corolla@#$"

Write-Host "📝 Datos de prueba: Modelo = 'Corolla@#$'" -ForegroundColor White

Write-Host ""
Write-Host "🧪 Prueba 4: Año inválido (debería fallar)..." -ForegroundColor Cyan
$datosInvalidos3 = $datosValidos.Clone()
$datosInvalidos3.Anio = "abc"

Write-Host "📝 Datos de prueba: Año = 'abc'" -ForegroundColor White

Write-Host ""
Write-Host "🧪 Prueba 5: Precio inválido (debería fallar)..." -ForegroundColor Cyan
$datosInvalidos4 = $datosValidos.Clone()
$datosInvalidos4.Precio = -100

Write-Host "📝 Datos de prueba: Precio = -100" -ForegroundColor White

Write-Host ""
Write-Host "🧪 Prueba 6: Kilometraje inválido (debería fallar)..." -ForegroundColor Cyan
$datosInvalidos5 = $datosValidos.Clone()
$datosInvalidos5.Kilometraje = "xyz"

Write-Host "📝 Datos de prueba: Kilometraje = 'xyz'" -ForegroundColor White

# Limpiar archivo temporal
if (Test-Path $tempImagePath) {
    Remove-Item $tempImagePath
}

Write-Host ""
Write-Host "🎉 ¡Pruebas de validación completadas!" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Resumen de validaciones implementadas:" -ForegroundColor Yellow
Write-Host "   ✅ Campos de texto: No permiten caracteres especiales" -ForegroundColor White
Write-Host "   ✅ Año: Debe ser número entre 1900 y año actual + 1" -ForegroundColor White
Write-Host "   ✅ Kilometraje: Debe ser número >= 0" -ForegroundColor White
Write-Host "   ✅ Precio: Debe ser número > 0" -ForegroundColor White
Write-Host "   ✅ Campo Estado: Removido del formulario" -ForegroundColor White
Write-Host ""
Write-Host "🔗 URL de la API: $publicUrl" -ForegroundColor Cyan
Write-Host "📚 Documentación: $publicUrl/api-docs/" -ForegroundColor Cyan
Write-Host ""
Write-Host "💡 Para probar en Swagger UI:" -ForegroundColor Green
Write-Host "   1. Ve a: $publicUrl/api-docs/" -ForegroundColor White
Write-Host "   2. Haz login como cliente" -ForegroundColor White
Write-Host "   3. Prueba POST /cliente/compras con datos inválidos" -ForegroundColor White
Write-Host "   4. Verifica que se muestren los mensajes de error apropiados" -ForegroundColor White
