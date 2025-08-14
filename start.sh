#!/bin/bash

echo "🚗 Iniciando AutoPrest API..."

# Verificar si Docker está instalado
if ! command -v docker &> /dev/null; then
    echo "❌ Docker no está instalado. Por favor, instala Docker primero."
    exit 1
fi

# Verificar si Docker Compose está instalado
if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose no está instalado. Por favor, instala Docker Compose primero."
    exit 1
fi

# Crear directorio de uploads si no existe
mkdir -p app/public/uploads

# Crear archivo .env si no existe
if [ ! -f .env ]; then
    echo "📝 Creando archivo .env..."
    cat > .env << EOF
# Configuración del servidor
PORT=3000
NODE_ENV=production

# Base de datos MongoDB
DB=mongodb://admin:password123@mongodb:27017/autoprest?authSource=admin

# JWT
JWT_SECRET=tu_secreto_jwt_super_seguro_para_produccion_2024
JWT_EXPIRES_IN=24h
EOF
    echo "✅ Archivo .env creado"
fi

# Construir y ejecutar contenedores
echo "🐳 Construyendo y ejecutando contenedores..."
docker-compose up -d --build

# Esperar a que los servicios estén listos
echo "⏳ Esperando a que los servicios estén listos..."
sleep 10

# Verificar estado de los contenedores
echo "📊 Estado de los contenedores:"
docker-compose ps

echo ""
echo "🎉 ¡AutoPrest API está ejecutándose!"
echo ""
echo "📚 Documentación API: http://localhost/api-docs"
echo "🌐 API Endpoint: http://localhost:3000"
echo "📊 MongoDB: localhost:27017"
echo ""
echo "📋 Comandos útiles:"
echo "  - Ver logs: docker-compose logs -f"
echo "  - Detener: docker-compose down"
echo "  - Reiniciar: docker-compose restart"
echo ""
echo "🔑 Para probar la API:"
echo "  1. Ve a http://localhost/api-docs"
echo "  2. Registra un usuario con POST /registro"
echo "  3. Inicia sesión con POST /login"
echo "  4. Usa el token en los endpoints protegidos"
