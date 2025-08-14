# AutoPrest API

API REST para gestión de vehículos y préstamos automotrices con documentación Swagger UI y contenedores Docker.

## 🚗 Descripción

AutoPrest es una API REST que permite gestionar vehículos, usuarios y transacciones para un sistema de préstamos automotrices. La API incluye:

- **Autenticación JWT** con roles de usuario (admin, cliente, gerente)
- **Gestión de vehículos** (catálogo, compras, ventas)
- **Gestión de usuarios** (registro, login, administración)
- **Sistema de contactos** para comunicación
- **Documentación completa** con Swagger UI
- **Contenedores Docker** para fácil despliegue

## 📋 Características

### Roles de Usuario
- **Cliente**: Puede registrar compras de vehículos y ver su catálogo
- **Gerente**: Puede aprobar/rechazar vehículos y gestionar ventas
- **Admin**: Gestión completa de usuarios y sistema

### Endpoints Principales
- **Autenticación**: `/registro`, `/login`, `/logout`
- **Catálogo**: `/catalogo` (público)
- **Cliente**: `/cliente/compras`, `/cliente/vehiculos`
- **Gerente**: `/gerente/vehiculos/*`, `/gerente/ventas/*`
- **Admin**: `/usuarios/*`
- **Contacto**: `/contacto`

## 🐳 Instalación con Docker

### Prerrequisitos
- Docker
- Docker Compose

### Pasos de Instalación

1. **Clonar el repositorio**
```bash
git clone <tu-repositorio>
cd Autoprest_api
```

2. **Configurar variables de entorno**
```bash
# Crear archivo .env basado en el ejemplo
cp .env.example .env

# Editar variables según tu entorno
nano .env
```

3. **Ejecutar con Docker Compose**
```bash
# Construir y ejecutar todos los servicios
docker-compose up -d

# Ver logs en tiempo real
docker-compose logs -f

# Detener servicios
docker-compose down
```

### Variables de Entorno

```env
# Configuración del servidor
PORT=3000
NODE_ENV=production

# Base de datos MongoDB
DB=mongodb://admin:password123@mongodb:27017/autoprest?authSource=admin

# JWT
JWT_SECRET=tu_secreto_jwt_super_seguro_para_produccion_2024
JWT_EXPIRES_IN=24h
```

## 📚 Documentación API

### Acceso a Swagger UI
Una vez ejecutada la aplicación, puedes acceder a la documentación interactiva en:

- **Con Docker**: http://localhost/api-docs
- **Sin Nginx**: http://localhost:3000/api-docs

### Autenticación
La API usa autenticación JWT Bearer Token:

1. **Registrar usuario**: `POST /registro`
2. **Iniciar sesión**: `POST /login`
3. **Usar token**: Incluir en header: `Authorization: Bearer <token>`

### Ejemplos de Uso

#### Registrar Usuario
```bash
curl -X POST http://localhost:3000/registro \
  -H "Content-Type: application/json" \
  -d '{
    "nombre": "Juan Pérez",
    "telefono": "5512345678",
    "email": "juan@example.com",
    "pass": "password123",
    "rol": "cliente"
  }'
```

#### Iniciar Sesión
```bash
curl -X POST http://localhost:3000/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "juan@example.com",
    "pass": "password123"
  }'
```

#### Registrar Compra (Cliente)
```bash
curl -X POST http://localhost:3000/cliente/compras \
  -H "Authorization: Bearer <tu-token>" \
  -F "marca=Toyota" \
  -F "modelo=Corolla" \
  -F "año=2020" \
  -F "precio=250000" \
  -F "descripcion=Vehículo en excelente estado" \
  -F "Imagen=@imagen.jpg"
```

## 🔧 Desarrollo Local

### Instalación sin Docker

1. **Instalar dependencias**
```bash
npm install
```

2. **Configurar MongoDB**
```bash
# Instalar MongoDB localmente o usar MongoDB Atlas
# Configurar variable DB en .env
```

3. **Ejecutar aplicación**
```bash
npm run dev
```

### Estructura del Proyecto

```
Autoprest_api/
├── app/
│   ├── config/
│   │   ├── conexion.js
│   │   ├── configuracion.js
│   │   └── swagger.js
│   ├── controllers/
│   │   ├── AdminController.js
│   │   ├── CatalogoController.js
│   │   ├── Compracontroller.js
│   │   ├── ContactoController.js
│   │   ├── GerenteController.js
│   │   ├── UsuarioController.js
│   │   └── VentaController.js
│   ├── middlewares/
│   │   ├── auth.js
│   │   └── subirImagen.js
│   ├── models/
│   │   ├── Catalogomodel.js
│   │   ├── Compramodel.js
│   │   ├── Contactomodel.js
│   │   ├── Usuariomodel.js
│   │   └── Ventamodel.js
│   ├── public/uploads/
│   ├── routes/
│   │   └── usuarioRoutes.js
│   └── app.js
├── docker-compose.yml
├── Dockerfile
├── nginx.conf
├── mongo-init.js
├── package.json
└── server.js
```

## 🚀 Comandos Docker Útiles

```bash
# Ver logs de todos los servicios
docker-compose logs

# Ver logs de un servicio específico
docker-compose logs api
docker-compose logs mongodb

# Reiniciar un servicio
docker-compose restart api

# Ejecutar comandos dentro del contenedor
docker-compose exec api npm install
docker-compose exec mongodb mongo

# Limpiar contenedores y volúmenes
docker-compose down -v
docker system prune -a
```

## 🔒 Seguridad

- **JWT Tokens**: Autenticación segura con tokens
- **Validación de datos**: Validación en todos los endpoints
- **Roles y permisos**: Control de acceso basado en roles
- **Variables de entorno**: Configuración segura
- **HTTPS**: Configurado en Nginx (requiere certificados)

## 📊 Base de Datos

### Colecciones MongoDB
- `usuarios`: Información de usuarios
- `catalogos`: Vehículos disponibles
- `compras`: Registro de compras de clientes
- `contactos`: Mensajes de contacto
- `ventas`: Registro de ventas

### Índices Optimizados
- Email único en usuarios
- Búsquedas por marca/modelo en catálogo
- Filtros por estado en compras
- Fechas en ventas

## 🐛 Troubleshooting

### Problemas Comunes

1. **Puerto 3000 ocupado**
```bash
# Cambiar puerto en docker-compose.yml
ports:
  - "3001:3000"
```

2. **Error de conexión a MongoDB**
```bash
# Verificar que MongoDB esté ejecutándose
docker-compose logs mongodb
```

3. **Error de permisos en uploads**
```bash
# Crear directorio con permisos correctos
mkdir -p app/public/uploads
chmod 755 app/public/uploads
```

4. **Token JWT inválido**
```bash
# Verificar JWT_SECRET en variables de entorno
# Regenerar token con nuevo login
```

## 📞 Soporte

Para soporte técnico o preguntas:
- Email: support@autoprest.com
- Documentación: http://localhost/api-docs
- Issues: [GitHub Issues](https://github.com/tu-usuario/autoprest-api/issues)

## 📄 Licencia

Este proyecto está bajo la Licencia MIT. Ver el archivo `LICENSE` para más detalles.
