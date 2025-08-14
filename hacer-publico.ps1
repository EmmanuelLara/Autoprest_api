# Script para hacer la API AutoPrest pública nuevamente
# Ejecutar como administrador

Write-Host "🌐 Haciendo API AutoPrest PÚBLICA..." -ForegroundColor Yellow

# Detener contenedores actuales
Write-Host "⏹️  Deteniendo contenedores actuales..." -ForegroundColor Cyan
docker-compose down

# Restaurar configuración original
Write-Host "🔄 Restaurando configuración pública..." -ForegroundColor Green

# Restaurar puertos en docker-compose
(Get-Content docker-compose.yml) -replace '# ports:', 'ports:' | Set-Content docker-compose.yml
(Get-Content docker-compose.yml) -replace '^\s*#\s*-\s*"3000:3000"', '      - "3000:3000"' | Set-Content docker-compose.yml
(Get-Content docker-compose.yml) -replace '^\s*-\s*"127\.0\.0\.1:3000:3000"', '      - "3000:3000"' | Set-Content docker-compose.yml

# Descomentar ngrok si estaba comentado
(Get-Content docker-compose.yml) -replace '^\s*#\s*ngrok:', '  ngrok:' | Set-Content docker-compose.yml
(Get-Content docker-compose.yml) -replace '^\s*#\s*image:', '    image:' | Set-Content docker-compose.yml
(Get-Content docker-compose.yml) -replace '^\s*#\s*container_name:', '    container_name:' | Set-Content docker-compose.yml
(Get-Content docker-compose.yml) -replace '^\s*#\s*restart:', '    restart:' | Set-Content docker-compose.yml
(Get-Content docker-compose.yml) -replace '^\s*#\s*ports:', '    ports:' | Set-Content docker-compose.yml
(Get-Content docker-compose.yml) -replace '^\s*#\s*environment:', '    environment:' | Set-Content docker-compose.yml
(Get-Content docker-compose.yml) -replace '^\s*#\s*command:', '    command:' | Set-Content docker-compose.yml
(Get-Content docker-compose.yml) -replace '^\s*#\s*depends_on:', '    depends_on:' | Set-Content docker-compose.yml
(Get-Content docker-compose.yml) -replace '^\s*#\s*networks:', '    networks:' | Set-Content docker-compose.yml

# Restaurar CORS permisivo
Write-Host "🔓 Restaurando CORS permisivo..." -ForegroundColor Green
$appJsContent = Get-Content app/app.js -Raw
$appJsContent = $appJsContent -replace '// Configuración de CORS RESTRICTIVA.*?allowedOrigins\.indexOf\(origin\) !== -1\) \{.*?\} else \{.*?\}', '// Configuración de CORS para permitir acceso desde cualquier origen
app.use(cors({
  origin: (origin, callback) => callback(null, true),'
$appJsContent = $appJsContent -replace 'const allowedOrigins = \[.*?\];', ''
Set-Content app/app.js $appJsContent

# Iniciar contenedores con configuración pública
Write-Host "🚀 Iniciando contenedores con configuración pública..." -ForegroundColor Green
docker-compose up -d

# Verificar estado
Write-Host "✅ Verificando estado de los contenedores..." -ForegroundColor Cyan
docker-compose ps

Write-Host "`n🌐 API AutoPrest ahora es PÚBLICA" -ForegroundColor Green
Write-Host "📝 URLs de acceso:" -ForegroundColor White
Write-Host "   http://localhost:3000" -ForegroundColor Yellow
Write-Host "   http://192.168.1.81:3000" -ForegroundColor Yellow
Write-Host "   http://localhost:8080 (via Nginx)" -ForegroundColor Yellow

# Verificar si ngrok está funcionando
$ngrokContainer = docker ps --filter "name=autoprest_ngrok" --format "{{.Names}}"
if ($ngrokContainer) {
    Write-Host "`n🌍 Ngrok está activo. URL pública disponible en:" -ForegroundColor Cyan
    Write-Host "   http://localhost:4040 (para ver la URL de ngrok)" -ForegroundColor Yellow
}

Write-Host "`n💡 Para hacer privada nuevamente, ejecuta: hacer-privado.ps1" -ForegroundColor Cyan

