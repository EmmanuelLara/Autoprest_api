# Script completo para probar la API de AutoPrest
# Este script prueba todos los endpoints principales

param(
    [string]$BaseUrl = "http://localhost:3000",
    [string]$NgrokUrl = "https://e949ecceb86b.ngrok-free.app"
)

Write-Host "🚗 AutoPrest API - Script de Pruebas Completo" -ForegroundColor Green
Write-Host "===============================================" -ForegroundColor Green
Write-Host ""

# Función para hacer peticiones HTTP
function Invoke-APIRequest {
    param(
        [string]$Method,
        [string]$Url,
        [string]$Body = "",
        [hashtable]$Headers = @{}
    )
    
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

# Función para probar endpoints
function Test-Endpoints {
    param([string]$Url)
    
    Write-Host "🔍 Probando endpoints en: $Url" -ForegroundColor Yellow
    Write-Host "----------------------------------------" -ForegroundColor Yellow
    Write-Host ""
    
    # 1. Test básico
    Write-Host "1️⃣ Probando endpoint básico..." -ForegroundColor Cyan
    $result = Invoke-APIRequest -Method "GET" -Url "$Url/"
    Show-Result -TestName "Endpoint básico" -Result $result
    
    # 2. Test de salud
    Write-Host "2️⃣ Probando endpoint de salud..." -ForegroundColor Cyan
    $result = Invoke-APIRequest -Method "GET" -Url "$Url/test"
    Show-Result -TestName "Endpoint de salud" -Result $result
    
    # 3. Test de Swagger
    Write-Host "3️⃣ Probando documentación Swagger..." -ForegroundColor Cyan
    $result = Invoke-APIRequest -Method "GET" -Url "$Url/swagger.json"
    Show-Result -TestName "Documentación Swagger" -Result $result
    
    # 4. Test de registro (sin datos)
    Write-Host "4️⃣ Probando endpoint de registro..." -ForegroundColor Cyan
    $result = Invoke-APIRequest -Method "POST" -Url "$Url/registro" -Body "{}"
    Show-Result -TestName "Endpoint de registro (sin datos)" -Result $result
    
    # 5. Test de login (sin datos)
    Write-Host "5️⃣ Probando endpoint de login..." -ForegroundColor Cyan
    $result = Invoke-APIRequest -Method "POST" -Url "$Url/login" -Body "{}"
    Show-Result -TestName "Endpoint de login (sin datos)" -Result $result
    
    # 6. Test de catálogo
    Write-Host "6️⃣ Probando endpoint de catálogo..." -ForegroundColor Cyan
    $result = Invoke-APIRequest -Method "GET" -Url "$Url/catalogo"
    Show-Result -TestName "Endpoint de catálogo" -Result $result
    
    # 7. Test de contacto
    Write-Host "7️⃣ Probando endpoint de contacto..." -ForegroundColor Cyan
    $result = Invoke-APIRequest -Method "POST" -Url "$Url/contacto" -Body "{}"
    Show-Result -TestName "Endpoint de contacto (sin datos)" -Result $result
}

# Función para probar con datos válidos
function Test-WithValidData {
    param([string]$Url)
    
    Write-Host "🧪 Probando con datos válidos en: $Url" -ForegroundColor Yellow
    Write-Host "----------------------------------------" -ForegroundColor Yellow
    Write-Host ""
    
    # 1. Registro de usuario válido
    Write-Host "1️⃣ Probando registro con datos válidos..." -ForegroundColor Cyan
    $userData = @{
        nombre = "Usuario Test"
        telefono = "5512345678"
        email = "test@example.com"
        pass = "password123"
        rol = "cliente"
    } | ConvertTo-Json
    
    $result = Invoke-APIRequest -Method "POST" -Url "$Url/registro" -Body $userData
    Show-Result -TestName "Registro con datos válidos" -Result $result
    
    # 2. Login con datos válidos
    Write-Host "2️⃣ Probando login con datos válidos..." -ForegroundColor Cyan
    $loginData = @{
        email = "test@example.com"
        pass = "password123"
    } | ConvertTo-Json
    
    $result = Invoke-APIRequest -Method "POST" -Url "$Url/login" -Body $loginData
    Show-Result -TestName "Login con datos válidos" -Result $result
    
    # 3. Contacto con datos válidos
    Write-Host "3️⃣ Probando contacto con datos válidos..." -ForegroundColor Cyan
    $contactData = @{
        nombre = "Contacto Test"
        email = "contacto@example.com"
        telefono = "5512345678"
        mensaje = "Mensaje de prueba"
    } | ConvertTo-Json
    
    $result = Invoke-APIRequest -Method "POST" -Url "$Url/contacto" -Body $contactData
    Show-Result -TestName "Contacto con datos válidos" -Result $result
}

# Función para mostrar resumen
function Show-Summary {
    Write-Host "📊 RESUMEN DE PRUEBAS" -ForegroundColor Magenta
    Write-Host "=====================" -ForegroundColor Magenta
    Write-Host ""
    Write-Host "✅ Endpoints probados:" -ForegroundColor Green
    Write-Host "   - GET / (básico)" -ForegroundColor Gray
    Write-Host "   - GET /test (salud)" -ForegroundColor Gray
    Write-Host "   - GET /swagger.json (documentación)" -ForegroundColor Gray
    Write-Host "   - POST /registro (usuarios)" -ForegroundColor Gray
    Write-Host "   - POST /login (autenticación)" -ForegroundColor Gray
    Write-Host "   - GET /catalogo (vehículos)" -ForegroundColor Gray
    Write-Host "   - POST /contacto (mensajes)" -ForegroundColor Gray
    Write-Host ""
    Write-Host "🔗 URLs disponibles:" -ForegroundColor Yellow
    Write-Host "   - Local: $BaseUrl" -ForegroundColor Gray
    Write-Host "   - Ngrok: $NgrokUrl" -ForegroundColor Gray
    Write-Host "   - Swagger UI: $BaseUrl/api-docs" -ForegroundColor Gray
    Write-Host "   - Docs personalizado: $BaseUrl/docs" -ForegroundColor Gray
    Write-Host ""
    Write-Host "📚 Documentación:" -ForegroundColor Cyan
    Write-Host "   - SOLUCION_BUSQUEDA_VEHICULOS.md" -ForegroundColor Gray
    Write-Host "   - SOLUCION_ERROR_500.md" -ForegroundColor Gray
    Write-Host "   - INSTRUCCIONES_SWAGGER.md" -ForegroundColor Gray
    Write-Host ""
}

# Función principal
function Main {
    Write-Host "🚀 Iniciando pruebas de la API..." -ForegroundColor Green
    Write-Host ""
    
    # Probar servidor local
    Test-Endpoints -Url $BaseUrl
    
    Write-Host ""
    Write-Host "🔄 Esperando 2 segundos antes de probar ngrok..." -ForegroundColor Yellow
    Start-Sleep -Seconds 2
    
    # Probar ngrok
    Test-Endpoints -Url $NgrokUrl
    
    Write-Host ""
    Write-Host "🔄 Esperando 2 segundos antes de probar con datos válidos..." -ForegroundColor Yellow
    Start-Sleep -Seconds 2
    
    # Probar con datos válidos en local
    Test-WithValidData -Url $BaseUrl
    
    # Mostrar resumen
    Show-Summary
    
    Write-Host "🎉 ¡Pruebas completadas!" -ForegroundColor Green
    Write-Host "Revisa los resultados arriba para identificar cualquier problema." -ForegroundColor Yellow
}

# Ejecutar función principal
Main
