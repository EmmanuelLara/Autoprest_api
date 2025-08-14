# Script para resetear y crear vehículos de prueba

Write-Host "🚗 Reseteando y creando vehículos de prueba..." -ForegroundColor Green

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
    param($Url, $Method, $Body, $Description, $Token)
    
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

# Crear vehículos de prueba
Write-Host ""
Write-Host "🚗 Creando vehículos de prueba..." -ForegroundColor Cyan

# Función para crear vehículo
function Crear-Vehiculo {
    param($VIN, $Marca, $Modelo, $Anio, $Tipo, $Condicion, $Transmision, $Combustible, $Kilometraje, $Color, $Precio, $Descripcion, $Accesorios, $Numero)
    
    Write-Host "   Creando vehículo $Numero: $Marca $Modelo..." -ForegroundColor Yellow
    
    # Crear archivo de imagen temporal
    $tempImagePath = "temp_image_$Numero.jpg"
    "fake image data for vehicle $Numero" | Out-File -FilePath $tempImagePath -Encoding ASCII
    
    try {
        $boundary = [System.Guid]::NewGuid().ToString()
        $LF = "`r`n"
        
        $bodyLines = (
            "--$boundary",
            "Content-Disposition: form-data; name=`"VIN`"",
            "",
            $VIN,
            "--$boundary",
            "Content-Disposition: form-data; name=`"Marca`"",
            "",
            $Marca,
            "--$boundary",
            "Content-Disposition: form-data; name=`"Modelo`"",
            "",
            $Modelo,
            "--$boundary",
            "Content-Disposition: form-data; name=`"Anio`"",
            "",
            $Anio,
            "--$boundary",
            "Content-Disposition: form-data; name=`"Tipo`"",
            "",
            $Tipo,
            "--$boundary",
            "Content-Disposition: form-data; name=`"Condicion`"",
            "",
            $Condicion,
            "--$boundary",
            "Content-Disposition: form-data; name=`"Transmision`"",
            "",
            $Transmision,
            "--$boundary",
            "Content-Disposition: form-data; name=`"Combustible`"",
            "",
            $Combustible,
            "--$boundary",
            "Content-Disposition: form-data; name=`"Kilometraje`"",
            "",
            $Kilometraje,
            "--$boundary",
            "Content-Disposition: form-data; name=`"Color`"",
            "",
            $Color,
            "--$boundary",
            "Content-Disposition: form-data; name=`"Precio`"",
            "",
            $Precio,
            "--$boundary",
            "Content-Disposition: form-data; name=`"Descripcion`"",
            "",
            $Descripcion,
            "--$boundary",
            "Content-Disposition: form-data; name=`"Accesorios`"",
            "",
            $Accesorios,
            "--$boundary",
            "Content-Disposition: form-data; name=`"Imagen`"; filename=`"test$Numero.jpg`"",
            "Content-Type: image/jpeg",
            "",
            [System.IO.File]::ReadAllBytes($tempImagePath),
            "--$boundary--"
        ) -join $LF
        
        $headers = @{
            "Authorization" = "Bearer $clienteToken"
            "Content-Type" = "multipart/form-data; boundary=$boundary"
        }
        
        $response = Invoke-RestMethod -Uri "$publicUrl/cliente/compras" -Method "POST" -Body $bodyLines -Headers $headers -TimeoutSec 10
        Write-Host "   ✅ Vehículo $Numero creado exitosamente" -ForegroundColor Green
        return $true
    } catch {
        Write-Host "   ❌ Error al crear vehículo $Numero: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    } finally {
        if (Test-Path $tempImagePath) {
            Remove-Item $tempImagePath
        }
    }
}

# Crear 3 vehículos de prueba
$vehiculosCreados = 0

# Vehículo 1
if (Crear-Vehiculo -VIN "1HGBH41JXMN109186" -Marca "Toyota" -Modelo "Corolla" -Anio 2020 -Tipo "Sedán" -Condicion "Usado" -Transmision "Automática" -Combustible "Gasolina" -Kilometraje 50000 -Color "Blanco" -Precio 250000 -Descripcion "Vehículo en excelente estado" -Accesorios "Aire acondicionado, radio" -Numero 1) {
    $vehiculosCreados++
}

# Vehículo 2
if (Crear-Vehiculo -VIN "2T1BURHE0JC123456" -Marca "Honda" -Modelo "Civic" -Anio 2019 -Tipo "Sedán" -Condicion "Usado" -Transmision "Manual" -Combustible "Gasolina" -Kilometraje 75000 -Color "Negro" -Precio 220000 -Descripcion "Vehículo bien mantenido" -Accesorios "Aire acondicionado, alarma" -Numero 2) {
    $vehiculosCreados++
}

# Vehículo 3
if (Crear-Vehiculo -VIN "3VWDX7AJ5DM123456" -Marca "Volkswagen" -Modelo "Jetta" -Anio 2021 -Tipo "Sedán" -Condicion "Usado" -Transmision "Automática" -Combustible "Gasolina" -Kilometraje 30000 -Color "Gris" -Precio 280000 -Descripcion "Vehículo seminuevo" -Accesorios "Aire acondicionado, radio, GPS" -Numero 3) {
    $vehiculosCreados++
}

Write-Host ""
Write-Host "📊 Vehículos creados: $vehiculosCreados/3" -ForegroundColor Yellow

# Verificar vehículos pendientes
Write-Host ""
Write-Host "🔍 Verificando vehículos pendientes..." -ForegroundColor Cyan

# Login como gerente
$gerenteLoginData = @{
    email = "gerente@example.com"
    pass = "password123"
}

$gerenteLoginResponse = Test-Endpoint -Url "$publicUrl/login" -Method "POST" -Body $gerenteLoginData -Description "Login de gerente"

if ($gerenteLoginResponse -and $gerenteLoginResponse.token) {
    $gerenteToken = $gerenteLoginResponse.token
    
    # Probar endpoint de vehículos pendientes
    $pendientesResponse = Test-Endpoint -Url "$publicUrl/gerente/vehiculos/pendientes" -Method "GET" -Description "Obtener vehículos pendientes" -Token $gerenteToken
    
    if ($pendientesResponse) {
        Write-Host "📊 Vehículos pendientes encontrados: $($pendientesResponse.vehiculos.Count)" -ForegroundColor Yellow
        if ($pendientesResponse.vehiculos.Count -gt 0) {
            foreach ($vehiculo in $pendientesResponse.vehiculos) {
                Write-Host "   🚗 $($vehiculo.Marca) $($vehiculo.Modelo) - VIN: $($vehiculo.VIN) - Estado: $($vehiculo.Estado)" -ForegroundColor White
            }
        }
    }
    
    # Probar endpoint de todos los vehículos
    $todosResponse = Test-Endpoint -Url "$publicUrl/gerente/vehiculos" -Method "GET" -Description "Obtener todos los vehículos" -Token $gerenteToken
    
    if ($todosResponse) {
        Write-Host "📊 Total de vehículos: $($todosResponse.vehiculos.Count)" -ForegroundColor Yellow
        if ($todosResponse.vehiculos.Count -gt 0) {
            foreach ($vehiculo in $todosResponse.vehiculos) {
                $estado = if ($vehiculo.Estado) { $vehiculo.Estado } else { "Sin estado" }
                Write-Host "   🚗 $($vehiculo.Marca) $($vehiculo.Modelo) - VIN: $($vehiculo.VIN) - Estado: $estado" -ForegroundColor White
            }
        }
    }
}

Write-Host ""
Write-Host "🎉 Reseteo de vehículos completado!" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Resumen:" -ForegroundColor Yellow
Write-Host "   - Vehículos creados: $vehiculosCreados" -ForegroundColor White
Write-Host "   - Estado por defecto: pendiente" -ForegroundColor White
Write-Host "   - URL de la API: $publicUrl" -ForegroundColor Cyan
Write-Host "   - Documentación: $publicUrl/api-docs/" -ForegroundColor Cyan
Write-Host ""
Write-Host "💡 Ahora puedes probar el endpoint GET /gerente/vehiculos/pendientes" -ForegroundColor Green
