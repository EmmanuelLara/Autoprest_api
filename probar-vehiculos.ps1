# Script para probar endpoints de vehículos de AutoPrest
# Requiere un token JWT válido de un usuario cliente

param(
    [string]$BaseUrl = "http://localhost:3000",
    [string]$Token = "",
    [string]$NgrokUrl = "https://e949ecceb86b.ngrok-free.app"
)

Write-Host "🚗 AutoPrest API - Pruebas de Endpoints de Vehículos" -ForegroundColor Green
Write-Host "=====================================================" -ForegroundColor Green
Write-Host ""

# Verificar si se proporcionó un token
if (-not $Token) {
    Write-Host "❌ Error: Debes proporcionar un token JWT válido" -ForegroundColor Red
    Write-Host "   Uso: .\probar-vehiculos.ps1 -Token 'tu-token-aqui'" -ForegroundColor Yellow
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
            if ($Result.Data.Compra) {
                Write-Host "   Vehículos encontrados: $($Result.Data.Compra.Count)" -ForegroundColor Gray
                if ($Result.Data.Compra.Count -gt 0) {
                    Write-Host "   Primer vehículo: $($Result.Data.Compra[0].Marca) $($Result.Data.Compra[0].Modelo) ($($Result.Data.Compra[0].Anio))" -ForegroundColor Gray
                }
            } else {
                Write-Host "   Respuesta: $($Result.Data | ConvertTo-Json -Depth 2)" -ForegroundColor Gray
            }
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

# Función para probar endpoints de vehículos
function Test-VehicleEndpoints {
    param([string]$Url)
    
    Write-Host "🔍 Probando endpoints de vehículos en: $Url" -ForegroundColor Yellow
    Write-Host "----------------------------------------" -ForegroundColor Yellow
    Write-Host ""
    
    # 1. Obtener todos los vehículos del usuario
    Write-Host "1️⃣ Obteniendo todos los vehículos del usuario..." -ForegroundColor Cyan
    $result = Invoke-AuthenticatedRequest -Method "GET" -Url "$Url/cliente/vehiculos"
    Show-Result -TestName "Obtener todos los vehículos" -Result $result
    
    # 2. Buscar por marca (ejemplo: Toyota)
    Write-Host "2️⃣ Buscando vehículos por marca 'Toyota'..." -ForegroundColor Cyan
    $result = Invoke-AuthenticatedRequest -Method "GET" -Url "$Url/cliente/vehiculos/Marca/Toyota"
    Show-Result -TestName "Búsqueda por marca Toyota" -Result $result
    
    # 3. Buscar por modelo (ejemplo: Corolla)
    Write-Host "3️⃣ Buscando vehículos por modelo 'Corolla'..." -ForegroundColor Cyan
    $result = Invoke-AuthenticatedRequest -Method "GET" -Url "$Url/cliente/vehiculos/Modelo/Corolla"
    Show-Result -TestName "Búsqueda por modelo Corolla" -Result $result
    
    # 4. Buscar por año (ejemplo: 2020)
    Write-Host "4️⃣ Buscando vehículos por año '2020'..." -ForegroundColor Cyan
    $result = Invoke-AuthenticatedRequest -Method "GET" -Url "$Url/cliente/vehiculos/Anio/2020"
    Show-Result -TestName "Búsqueda por año 2020" -Result $result
    
    # 5. Buscar por color (ejemplo: Blanco)
    Write-Host "5️⃣ Buscando vehículos por color 'Blanco'..." -ForegroundColor Cyan
    $result = Invoke-AuthenticatedRequest -Method "GET" -Url "$Url/cliente/vehiculos/Color/Blanco"
    Show-Result -TestName "Búsqueda por color Blanco" -Result $result
    
    # 6. Buscar por tipo (ejemplo: Sedán)
    Write-Host "6️⃣ Buscando vehículos por tipo 'Sedán'..." -ForegroundColor Cyan
    $result = Invoke-AuthenticatedRequest -Method "GET" -Url "$Url/cliente/vehiculos/Tipo/Sedán"
    Show-Result -TestName "Búsqueda por tipo Sedán" -Result $result
    
    # 7. Buscar por condición (ejemplo: Usado)
    Write-Host "7️⃣ Buscando vehículos por condición 'Usado'..." -ForegroundColor Cyan
    $result = Invoke-AuthenticatedRequest -Method "GET" -Url "$Url/cliente/vehiculos/Condicion/Usado"
    Show-Result -TestName "Búsqueda por condición Usado" -Result $result
    
    # 8. Buscar por transmisión (ejemplo: Automática)
    Write-Host "8️⃣ Buscando vehículos por transmisión 'Automática'..." -ForegroundColor Cyan
    $result = Invoke-AuthenticatedRequest -Method "GET" -Url "$Url/cliente/vehiculos/Transmision/Automática"
    Show-Result -TestName "Búsqueda por transmisión Automática" -Result $result
    
    # 9. Buscar por combustible (ejemplo: Gasolina)
    Write-Host "9️⃣ Buscando vehículos por combustible 'Gasolina'..." -ForegroundColor Cyan
    $result = Invoke-AuthenticatedRequest -Method "GET" -Url "$Url/cliente/vehiculos/Combustible/Gasolina"
    Show-Result -TestName "Búsqueda por combustible Gasolina" -Result $result
    
    # 10. Búsqueda con valor inexistente
    Write-Host "🔟 Probando búsqueda con valor inexistente..." -ForegroundColor Cyan
    $result = Invoke-AuthenticatedRequest -Method "GET" -Url "$Url/cliente/vehiculos/Marca/VehiculoInexistente"
    Show-Result -TestName "Búsqueda con valor inexistente" -Result $result
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
    Write-Host "📊 RESUMEN DE PRUEBAS DE VEHÍCULOS" -ForegroundColor Magenta
    Write-Host "===================================" -ForegroundColor Magenta
    Write-Host ""
    Write-Host "✅ Endpoints probados:" -ForegroundColor Green
    Write-Host "   - GET /cliente/vehiculos (todos los vehículos)" -ForegroundColor Gray
    Write-Host "   - GET /cliente/vehiculos/Marca/{valor}" -ForegroundColor Gray
    Write-Host "   - GET /cliente/vehiculos/Modelo/{valor}" -ForegroundColor Gray
    Write-Host "   - GET /cliente/vehiculos/Anio/{valor}" -ForegroundColor Gray
    Write-Host "   - GET /cliente/vehiculos/Color/{valor}" -ForegroundColor Gray
    Write-Host "   - GET /cliente/vehiculos/Tipo/{valor}" -ForegroundColor Gray
    Write-Host "   - GET /cliente/vehiculos/Condicion/{valor}" -ForegroundColor Gray
    Write-Host "   - GET /cliente/vehiculos/Transmision/{valor}" -ForegroundColor Gray
    Write-Host "   - GET /cliente/vehiculos/Combustible/{valor}" -ForegroundColor Gray
    Write-Host ""
    Write-Host "🔍 Campos de búsqueda válidos:" -ForegroundColor Yellow
    Write-Host "   - Marca, Modelo, Anio, Tipo, Condicion" -ForegroundColor Gray
    Write-Host "   - Transmision, Combustible, Color, Precio, VIN" -ForegroundColor Gray
    Write-Host ""
    Write-Host "📚 Documentación relacionada:" -ForegroundColor Cyan
    Write-Host "   - SOLUCION_BUSQUEDA_VEHICULOS.md" -ForegroundColor Gray
    Write-Host "   - SOLUCION_ERROR_500.md" -ForegroundColor Gray
    Write-Host ""
}

# Función principal
function Main {
    Write-Host "🚀 Iniciando pruebas de endpoints de vehículos..." -ForegroundColor Green
    Write-Host ""
    
    # Mostrar información del token
    Show-TokenInfo
    
    # Probar servidor local
    Test-VehicleEndpoints -Url $BaseUrl
    
    Write-Host ""
    Write-Host "🔄 Esperando 2 segundos antes de probar ngrok..." -ForegroundColor Yellow
    Start-Sleep -Seconds 2
    
    # Probar ngrok
    Test-VehicleEndpoints -Url $NgrokUrl
    
    # Mostrar resumen
    Show-Summary
    
    Write-Host "🎉 ¡Pruebas de vehículos completadas!" -ForegroundColor Green
    Write-Host "Revisa los resultados arriba para identificar cualquier problema." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "💡 Consejos:" -ForegroundColor Cyan
    Write-Host "   - Si recibes 204, significa que no hay vehículos con esos criterios" -ForegroundColor Gray
    Write-Host "   - Si recibes 404, verifica que el campo y valor sean correctos" -ForegroundColor Gray
    Write-Host "   - Si recibes 401, verifica que el token sea válido" -ForegroundColor Gray
}

# Ejecutar función principal
Main
