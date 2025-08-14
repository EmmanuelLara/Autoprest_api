# Script para probar el endpoint de compras de AutoPrest
# Requiere un token JWT válido de un usuario cliente

param(
    [string]$BaseUrl = "http://localhost:3000",
    [string]$Token = "",
    [string]$NgrokUrl = "https://e949ecceb86b.ngrok-free.app"
)

Write-Host "🚗 AutoPrest API - Pruebas del Endpoint de Compras" -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Green
Write-Host ""

# Verificar si se proporcionó un token
if (-not $Token) {
    Write-Host "❌ Error: Debes proporcionar un token JWT válido" -ForegroundColor Red
    Write-Host "   Uso: .\probar-compras.ps1 -Token 'tu-token-aqui'" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "💡 Para obtener un token:" -ForegroundColor Cyan
    Write-Host "   1. Registra un usuario: POST $BaseUrl/registro" -ForegroundColor Gray
    Write-Host "   2. Haz login: POST $BaseUrl/login" -ForegroundColor Gray
    Write-Host "   3. Copia el token de la respuesta" -ForegroundColor Gray
    Write-Host ""
    exit 1
}

# Función para hacer peticiones HTTP autenticadas
function Invoke-AuthenticatedRequest {
    param(
        [string]$Method,
        [string]$Url,
        [string]$Body = "",
        [hashtable]$Headers = @{}
    )
    
    # Agregar token de autorización
    $Headers["Authorization"] = "Bearer $Token"
    
    try {
        $params = @{
            Method = $Method
            Uri = $Url
            Headers = $Headers
            ContentType = "application/json"
        }
        
        if ($Body -and $Method -ne "GET") {
            $params.Body = $Body
        }
        
        $response = Invoke-RestMethod @params -ErrorAction Stop
        return @{
            Success = $true
            Data = $response
            StatusCode = 200
        }
    }
    catch {
        $statusCode = $_.Exception.Response.StatusCode.value__
        $errorMessage = $_.Exception.Message
        
        try {
            $errorResponse = $_.Exception.Response.GetResponseStream()
            $reader = New-Object System.IO.StreamReader($errorResponse)
            $errorBody = $reader.ReadToEnd()
        }
        catch {
            $errorBody = "No se pudo leer el cuerpo del error"
        }
        
        return @{
            Success = $false
            StatusCode = $statusCode
            Error = $errorMessage
            ErrorBody = $errorBody
        }
    }
}

# Función para mostrar resultados
function Show-Result {
    param(
        [string]$TestName,
        [hashtable]$Result
    )
    
    if ($Result.Success) {
        Write-Host "✅ $TestName" -ForegroundColor Green
        if ($Result.Data) {
            Write-Host "   Respuesta: $($Result.Data | ConvertTo-Json -Depth 2)" -ForegroundColor Gray
        }
    } else {
        Write-Host "❌ $TestName" -ForegroundColor Red
        Write-Host "   Status: $($Result.StatusCode)" -ForegroundColor Red
        Write-Host "   Error: $($Result.Error)" -ForegroundColor Red
        if ($Result.ErrorBody) {
            Write-Host "   Detalles: $($Result.ErrorBody)" -ForegroundColor Red
        }
    }
    Write-Host ""
}

# Función para probar endpoint de compras
function Test-PurchaseEndpoint {
    param([string]$Url)
    
    Write-Host "🔍 Probando endpoint de compras en: $Url" -ForegroundColor Yellow
    Write-Host "----------------------------------------" -ForegroundColor Yellow
    Write-Host ""
    
    # 1. Probar sin datos (debería fallar)
    Write-Host "1️⃣ Probando compra sin datos (debería fallar)..." -ForegroundColor Cyan
    $result = Invoke-AuthenticatedRequest -Method "POST" -Url "$Url/cliente/compras" -Body "{}"
    Show-Result -TestName "Compra sin datos" -Result $result
    
    # 2. Probar con datos mínimos (debería fallar por campos faltantes)
    Write-Host "2️⃣ Probando compra con datos mínimos..." -ForegroundColor Cyan
    $minData = @{
        VIN = "1HGBH41JXMN109186"
        Marca = "Toyota"
    } | ConvertTo-Json
    
    $result = Invoke-AuthenticatedRequest -Method "POST" -Url "$Url/cliente/compras" -Body $minData
    Show-Result -TestName "Compra con datos mínimos" -Result $result
    
    # 3. Probar con datos completos (debería funcionar)
    Write-Host "3️⃣ Probando compra con datos completos..." -ForegroundColor Cyan
    $completeData = @{
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
        Descripcion = "Vehículo en excelente estado, bien mantenido, sin accidentes"
        Accesorios = "Aire acondicionado, radio, alarma, rines deportivos"
    } | ConvertTo-Json
    
    $result = Invoke-AuthenticatedRequest -Method "POST" -Url "$Url/cliente/compras" -Body $completeData
    Show-Result -TestName "Compra con datos completos" -Result $result
    
    # 4. Probar con VIN inválido (debería fallar)
    Write-Host "4️⃣ Probando compra con VIN inválido..." -ForegroundColor Cyan
    $invalidVinData = @{
        VIN = "123"  # VIN muy corto
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
        Descripcion = "Vehículo de prueba"
    } | ConvertTo-Json
    
    $result = Invoke-AuthenticatedRequest -Method "POST" -Url "$Url/cliente/compras" -Body $invalidVinData
    Show-Result -TestName "Compra con VIN inválido" -Result $result
    
    # 5. Probar con año inválido (debería fallar)
    Write-Host "5️⃣ Probando compra con año inválido..." -ForegroundColor Cyan
    $invalidYearData = @{
        VIN = "1HGBH41JXMN109186"
        Marca = "Toyota"
        Modelo = "Corolla"
        Anio = 1800  # Año muy antiguo
        Tipo = "Sedán"
        Condicion = "Usado"
        Transmision = "Automática"
        Combustible = "Gasolina"
        Kilometraje = 50000
        Color = "Blanco"
        Precio = 250000
        Descripcion = "Vehículo de prueba"
    } | ConvertTo-Json
    
    $result = Invoke-AuthenticatedRequest -Method "POST" -Url "$Url/cliente/compras" -Body $invalidYearData
    Show-Result -TestName "Compra con año inválido" -Result $result
    
    # 6. Probar con precio inválido (debería fallar)
    Write-Host "6️⃣ Probando compra con precio inválido..." -ForegroundColor Cyan
    $invalidPriceData = @{
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
        Precio = -1000  # Precio negativo
        Descripcion = "Vehículo de prueba"
    } | ConvertTo-Json
    
    $result = Invoke-AuthenticatedRequest -Method "POST" -Url "$Url/cliente/compras" -Body $invalidPriceData
    Show-Result -TestName "Compra con precio inválido" -Result $result
    
    # 7. Probar con kilometraje inválido (debería fallar)
    Write-Host "7️⃣ Probando compra con kilometraje inválido..." -ForegroundColor Cyan
    $invalidKmData = @{
        VIN = "1HGBH41JXMN109186"
        Marca = "Toyota"
        Modelo = "Corolla"
        Anio = 2020
        Tipo = "Sedán"
        Condicion = "Usado"
        Transmision = "Automática"
        Combustible = "Gasolina"
        Kilometraje = -1000  # Kilometraje negativo
        Color = "Blanco"
        Precio = 250000
        Descripcion = "Vehículo de prueba"
    } | ConvertTo-Json
    
    $result = Invoke-AuthenticatedRequest -Method "POST" -Url "$Url/cliente/compras" -Body $invalidKmData
    Show-Result -TestName "Compra con kilometraje inválido" -Result $result
}

# Función para mostrar información del token
function Show-TokenInfo {
    Write-Host "🔐 INFORMACIÓN DEL TOKEN" -ForegroundColor Magenta
    Write-Host "=========================" -ForegroundColor Magenta
    Write-Host ""
    
    # Decodificar el token JWT (solo la parte del payload)
    try {
        $tokenParts = $Token.Split('.')
        if ($tokenParts.Length -eq 3) {
            $payload = $tokenParts[1]
            # Agregar padding si es necesario
            $padding = 4 - ($payload.Length % 4)
            if ($padding -ne 4) {
                $payload = $payload + ("=" * $padding)
            }
            
            # Convertir de base64 a JSON
            $bytes = [Convert]::FromBase64String($payload)
            $jsonString = [System.Text.Encoding]::UTF8.GetString($bytes)
            $tokenData = $jsonString | ConvertFrom-Json
            
            Write-Host "✅ Token válido" -ForegroundColor Green
            Write-Host "   Usuario ID: $($tokenData._id)" -ForegroundColor Gray
            Write-Host "   Nombre: $($tokenData.nombre)" -ForegroundColor Gray
            Write-Host "   Email: $($tokenData.email)" -ForegroundColor Gray
            Write-Host "   Rol: $($tokenData.rol)" -ForegroundColor Gray
            Write-Host "   Expira: $([DateTimeOffset]::FromUnixTimeSeconds($tokenData.exp).DateTime)" -ForegroundColor Gray
            Write-Host ""
        } else {
            Write-Host "⚠️ Formato de token inválido" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "⚠️ No se pudo decodificar el token" -ForegroundColor Yellow
    }
}

# Función para mostrar resumen
function Show-Summary {
    Write-Host "📊 RESUMEN DE PRUEBAS DE COMPRAS" -ForegroundColor Magenta
    Write-Host "=================================" -ForegroundColor Magenta
    Write-Host ""
    Write-Host "✅ Endpoints probados:" -ForegroundColor Green
    Write-Host "   - POST /cliente/compras (sin datos)" -ForegroundColor Gray
    Write-Host "   - POST /cliente/compras (datos mínimos)" -ForegroundColor Gray
    Write-Host "   - POST /cliente/compras (datos completos)" -ForegroundColor Gray
    Write-Host "   - POST /cliente/compras (VIN inválido)" -ForegroundColor Gray
    Write-Host "   - POST /cliente/compras (año inválido)" -ForegroundColor Gray
    Write-Host "   - POST /cliente/compras (precio inválido)" -ForegroundColor Gray
    Write-Host "   - POST /cliente/compras (kilometraje inválido)" -ForegroundColor Gray
    Write-Host ""
    Write-Host "🔍 Campos requeridos:" -ForegroundColor Yellow
    Write-Host "   - VIN, Marca, Modelo, Anio, Tipo, Condicion" -ForegroundColor Gray
    Write-Host "   - Transmision, Combustible, Kilometraje, Color, Precio, Descripcion" -ForegroundColor Gray
    Write-Host ""
    Write-Host "📚 Documentación relacionada:" -ForegroundColor Cyan
    Write-Host "   - SOLUCION_ERROR_500.md" -ForegroundColor Gray
    Write-Host "   - SOLUCION_BUSQUEDA_VEHICULOS.md" -ForegroundColor Gray
    Write-Host ""
}

# Función principal
function Main {
    Write-Host "🚀 Iniciando pruebas del endpoint de compras..." -ForegroundColor Green
    Write-Host ""
    
    # Mostrar información del token
    Show-TokenInfo
    
    # Probar servidor local
    Test-PurchaseEndpoint -Url $BaseUrl
    
    Write-Host ""
    Write-Host "🔄 Esperando 2 segundos antes de probar ngrok..." -ForegroundColor Yellow
    Start-Sleep -Seconds 2
    
    # Probar ngrok
    Test-PurchaseEndpoint -Url $NgrokUrl
    
    # Mostrar resumen
    Show-Summary
    
    Write-Host "🎉 ¡Pruebas de compras completadas!" -ForegroundColor Green
    Write-Host "Revisa los resultados arriba para identificar cualquier problema." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "💡 Consejos:" -ForegroundColor Cyan
    Write-Host "   - Si recibes 400, verifica que todos los campos requeridos estén presentes" -ForegroundColor Gray
    Write-Host "   - Si recibes 500, verifica que los tipos de datos sean correctos" -ForegroundColor Gray
    Write-Host "   - Si recibes 401, verifica que el token sea válido" -ForegroundColor Gray
    Write-Host "   - El campo Imagen se llena automáticamente con la ruta del archivo" -ForegroundColor Gray
}

# Ejecutar función principal
Main
