# Script para hacer la API AutoPrest privada
# Ejecutar como administrador

Write-Host "🔒 Haciendo API AutoPrest PRIVADA..." -ForegroundColor Yellow

# Detener contenedores actuales
Write-Host "⏹️  Deteniendo contenedores actuales..." -ForegroundColor Cyan
docker-compose down

# Verificar que no hay contenedores corriendo
$containers = docker ps -q --filter "name=autoprest"
if ($containers) {
    Write-Host "🛑 Deteniendo contenedores restantes..." -ForegroundColor Red
    docker stop $containers
    docker rm $containers
}

# Opción 1: Solo API local (más privado)
Write-Host "📋 Opciones de privacidad:" -ForegroundColor Green
Write-Host "1. Solo acceso local (localhost/127.0.0.1)" -ForegroundColor White
Write-Host "2. Solo red local (192.168.x.x)" -ForegroundColor White
Write-Host "3. Completamente privado (sin puertos expuestos)" -ForegroundColor White

$opcion = Read-Host "Selecciona una opción (1-3)"

switch ($opcion) {
    "1" {
        Write-Host "🔐 Configurando solo acceso local..." -ForegroundColor Green
        # Modificar docker-compose para solo localhost
        (Get-Content docker-compose.yml) -replace 'ports:\s*-\s*"3000:3000"', 'ports:`n      - "127.0.0.1:3000:3000"' | Set-Content docker-compose.yml
    }
    "2" {
        Write-Host "🏠 Configurando solo red local..." -ForegroundColor Green
        # Mantener configuración actual (ya está en red local)
    }
    "3" {
        Write-Host "🚫 Configurando completamente privado..." -ForegroundColor Green
        # Comentar puertos en docker-compose
        (Get-Content docker-compose.yml) -replace 'ports:', '# ports:' | Set-Content docker-compose.yml
        (Get-Content docker-compose.yml) -replace '^\s*-\s*"3000:3000"', '      # - "3000:3000"' | Set-Content docker-compose.yml
    }
    default {
        Write-Host "❌ Opción inválida. Usando configuración por defecto." -ForegroundColor Red
    }
}

# Iniciar contenedores con nueva configuración
Write-Host "🚀 Iniciando contenedores con configuración privada..." -ForegroundColor Green
docker-compose up -d

# Verificar estado
Write-Host "✅ Verificando estado de los contenedores..." -ForegroundColor Cyan
docker-compose ps

Write-Host "`n🔒 API AutoPrest ahora es PRIVADA" -ForegroundColor Green
Write-Host "📝 Para acceder:" -ForegroundColor White

switch ($opcion) {
    "1" { Write-Host "   http://localhost:3000 (solo desde esta máquina)" -ForegroundColor Yellow }
    "2" { Write-Host "   http://192.168.1.81:3000 (solo desde red local)" -ForegroundColor Yellow }
    "3" { Write-Host "   Solo desde dentro de Docker (completamente privado)" -ForegroundColor Yellow }
}

Write-Host "`n💡 Para hacer pública nuevamente, ejecuta: hacer-publico.ps1" -ForegroundColor Cyan

