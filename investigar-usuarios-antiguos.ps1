# Script para investigar usuarios antiguos que no funcionan
$baseUrl = "http://localhost:3000"

Write-Host "🔍 Investigando usuarios antiguos..." -ForegroundColor Yellow

# Lista de usuarios que existían antes de la corrección
$usuariosAntiguos = @(
    @{
        email = "cebra@example.com"
        pass = "password123"
        descripcion = "Usuario cebra (antiguo)"
    },
    @{
        email = "admin@test.com"
        pass = "admin123"
        descripcion = "Usuario admin (antiguo)"
    },
    @{
        email = "cliente@test.com"
        pass = "cliente123"
        descripcion = "Usuario cliente (antiguo)"
    },
    @{
        email = "gerente@test.com"
        pass = "gerente123"
        descripcion = "Usuario gerente (antiguo)"
    }
)

Write-Host "1️⃣ Probando usuarios antiguos..." -ForegroundColor Cyan

foreach ($usuario in $usuariosAntiguos) {
    Write-Host "--- Probando: $($usuario.descripcion) ---" -ForegroundColor Magenta
    Write-Host "Email: $($usuario.email)" -ForegroundColor Gray
    Write-Host "Contraseña: $($usuario.pass)" -ForegroundColor Gray
    
    $loginData = @{
        email = $usuario.email
        pass = $usuario.pass
    }
    $jsonLogin = $loginData | ConvertTo-Json -Depth 10
    
    try {
        $response = Invoke-RestMethod -Uri "$baseUrl/login" -Method POST -Body $jsonLogin -ContentType "application/json"
        Write-Host "✅ Login exitoso para $($usuario.email)" -ForegroundColor Green
        Write-Host "   Usuario: $($response.usuario.nombre)" -ForegroundColor Gray
        Write-Host "   Rol: $($response.usuario.rol)" -ForegroundColor Gray
    } catch {
        Write-Host "❌ Login falló para $($usuario.email): $($_.Exception.Response.StatusCode)" -ForegroundColor Red
        
        if ($_.Exception.Response) {
            $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
            $responseBody = $reader.ReadToEnd()
            Write-Host "   Respuesta: $responseBody" -ForegroundColor Red
        }
    }
    
    Write-Host ""
}

# 2. Crear usuarios nuevos con las mismas credenciales para comparar
Write-Host "2️⃣ Creando usuarios nuevos con las mismas credenciales..." -ForegroundColor Cyan

$usuariosNuevos = @(
    @{
        nombre = "Cebra Nuevo"
        telefono = "5512345682"
        email = "cebra_nuevo@example.com"
        pass = "password123"
        rol = "cliente"
    },
    @{
        nombre = "Admin Nuevo"
        telefono = "5512345683"
        email = "admin_nuevo@example.com"
        pass = "admin123"
        rol = "admin"
    }
)

foreach ($usuario in $usuariosNuevos) {
    Write-Host "--- Creando: $($usuario.email) ---" -ForegroundColor Magenta
    
    $jsonRegistro = $usuario | ConvertTo-Json -Depth 10
    
    try {
        $response = Invoke-RestMethod -Uri "$baseUrl/registro" -Method POST -Body $jsonRegistro -ContentType "application/json"
        Write-Host "✅ Usuario nuevo creado: $($usuario.email)" -ForegroundColor Green
        
        # Probar login inmediatamente
        $loginData = @{
            email = $usuario.email
            pass = $usuario.pass
        }
        $jsonLogin = $loginData | ConvertTo-Json -Depth 10
        
        try {
            $responseLogin = Invoke-RestMethod -Uri "$baseUrl/login" -Method POST -Body $jsonLogin -ContentType "application/json"
            Write-Host "✅ Login exitoso con usuario nuevo" -ForegroundColor Green
        } catch {
            Write-Host "❌ Login falló con usuario nuevo: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
        }
        
    } catch {
        Write-Host "❌ Error creando usuario nuevo: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
    }
    
    Write-Host ""
}

Write-Host "🎯 Investigación completada!" -ForegroundColor Green
Write-Host "💡 Si los usuarios antiguos fallan pero los nuevos funcionan," -ForegroundColor Cyan
Write-Host "   necesitamos actualizar las contraseñas de los usuarios antiguos." -ForegroundColor Cyan
