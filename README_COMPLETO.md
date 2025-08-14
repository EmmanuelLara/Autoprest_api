# 🚗 AutoPrest API - Solución Completa

## 📋 Resumen del Proyecto

AutoPrest API es una aplicación backend para la gestión de vehículos y préstamos automotrices. Este proyecto incluye soluciones completas para los problemas identificados y herramientas de prueba automatizadas.

## ✅ Problemas Resueltos

### 1. **Error 500 en POST /cliente/compras**
- **Problema**: Faltaban campos requeridos en el modelo de Compra
- **Solución**: Documentación completa de todos los campos obligatorios
- **Archivo**: `SOLUCION_ERROR_500.md`

### 2. **Error 204 en búsqueda de vehículos**
- **Problema**: La búsqueda no filtraba por usuario autenticado
- **Solución**: Implementación de filtrado por `UsuarioID` del token JWT
- **Archivo**: `SOLUCION_BUSQUEDA_VEHICULOS.md`

### 3. **Configuración de Swagger personalizado**
- **Problema**: Swagger UI básico sin configuración para ngrok
- **Solución**: Interfaz personalizada con interceptores de URL y configuración de servidores
- **Archivo**: `public/swagger-custom.html`

## 🛠️ Herramientas de Prueba

### Scripts de PowerShell Disponibles

#### 1. **probar-api-completa.ps1**
Prueba todos los endpoints principales de la API:
```powershell
.\probar-api-completa.ps1
```

**Características:**
- ✅ Prueba endpoints básicos (/, /test, /swagger.json)
- ✅ Prueba endpoints de autenticación (/registro, /login)
- ✅ Prueba endpoints públicos (/catalogo, /contacto)
- ✅ Prueba tanto servidor local como ngrok
- ✅ Incluye pruebas con datos válidos

#### 2. **probar-vehiculos.ps1**
Prueba específicamente los endpoints de vehículos:
```powershell
.\probar-vehiculos.ps1 -Token "tu-token-jwt-aqui"
```

**Características:**
- 🔐 Requiere token JWT válido de usuario cliente
- 🔍 Prueba búsqueda por todos los campos válidos
- 📊 Muestra información del token decodificado
- 🚗 Prueba tanto servidor local como ngrok
- 📝 Incluye ejemplos de todos los campos de búsqueda

#### 3. **probar-compras.ps1**
Prueba el endpoint de compras con validaciones:
```powershell
.\probar-compras.ps1 -Token "tu-token-jwt-aqui"
```

**Características:**
- 🔐 Requiere token JWT válido de usuario cliente
- 🧪 Prueba casos válidos e inválidos
- ✅ Valida todos los campos requeridos
- ❌ Prueba validaciones de campos (VIN, año, precio, kilometraje)
- 📊 Muestra información del token decodificado

## 🚀 Cómo Usar los Scripts

### Paso 1: Obtener un Token JWT

1. **Registrar un usuario:**
```bash
POST http://localhost:3000/registro
{
  "nombre": "Usuario Test",
  "telefono": "5512345678",
  "email": "test@example.com",
  "pass": "password123",
  "rol": "cliente"
}
```

2. **Hacer login:**
```bash
POST http://localhost:3000/login
{
  "email": "test@example.com",
  "pass": "password123"
}
```

3. **Copiar el token de la respuesta**

### Paso 2: Ejecutar los Scripts

#### Script básico (sin token):
```powershell
.\probar-api-completa.ps1
```

#### Script de vehículos (con token):
```powershell
.\probar-vehiculos.ps1 -Token "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

#### Script de compras (con token):
```powershell
.\probar-compras.ps1 -Token "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

## 🔧 Configuración de la API

### Servidores Disponibles

1. **🏠 Servidor Local**: `http://localhost:3000`
2. **🐳 Servidor Docker**: `http://localhost:3000`
3. **🌐 Servidor Público (ngrok)**: `https://e949ecceb86b.ngrok-free.app`

### URLs de Documentación

- **Swagger UI estándar**: `http://localhost:3000/api-docs`
- **Documentación personalizada**: `http://localhost:3000/docs`
- **Especificación JSON**: `http://localhost:3000/swagger.json`

## 📚 Documentación de Soluciones

### Archivos de Solución

1. **`SOLUCION_ERROR_500.md`** - Solución completa al error 500 en compras
2. **`SOLUCION_BUSQUEDA_VEHICULOS.md`** - Solución al error 204 en búsqueda
3. **`INSTRUCCIONES_SWAGGER.md`** - Guía de uso de Swagger UI
4. **`EXPOSICION_PUBLICA.md`** - Instrucciones para exponer la API públicamente

### Campos de Búsqueda Válidos

Los campos de búsqueda deben coincidir **exactamente** con los del modelo:

- ✅ `Marca` (no "marca")
- ✅ `Modelo` (no "modelo")
- ✅ `Anio` (no "año")
- ✅ `Tipo`
- ✅ `Condicion`
- ✅ `Transmision`
- ✅ `Combustible`
- ✅ `Color`
- ✅ `Precio`
- ✅ `VIN`

### Campos Requeridos para Compras

```json
{
  "VIN": "1HGBH41JXMN109186",
  "Marca": "Toyota",
  "Modelo": "Corolla",
  "Anio": 2020,
  "Tipo": "Sedán",
  "Condicion": "Usado",
  "Transmision": "Automática",
  "Combustible": "Gasolina",
  "Kilometraje": 50000,
  "Color": "Blanco",
  "Precio": 250000,
  "Descripcion": "Descripción del vehículo"
}
```

## 🐛 Solución de Problemas Comunes

### Error 204 - No Content
- **Causa**: No hay vehículos que coincidan con los criterios de búsqueda
- **Solución**: Verificar que tengas vehículos registrados y que los criterios sean correctos

### Error 400 - Bad Request
- **Causa**: Campos faltantes o datos inválidos
- **Solución**: Verificar que todos los campos requeridos estén presentes y sean válidos

### Error 401 - Unauthorized
- **Causa**: Token JWT inválido o expirado
- **Solución**: Obtener un nuevo token haciendo login

### Error 500 - Internal Server Error
- **Causa**: Campos faltantes en el modelo de Compra
- **Solución**: Usar la documentación actualizada con todos los campos requeridos

## 🔍 Endpoints Principales

### Autenticación
- `POST /registro` - Registrar nuevo usuario
- `POST /login` - Iniciar sesión

### Cliente
- `GET /cliente/vehiculos` - Obtener todos los vehículos del usuario
- `GET /cliente/vehiculos/:key/:value` - Buscar vehículos por criterio
- `POST /cliente/compras` - Registrar nuevo vehículo

### Público
- `GET /catalogo` - Ver catálogo de vehículos
- `POST /contacto` - Enviar mensaje de contacto

## 🚀 Iniciar el Proyecto

### Opción 1: Script de PowerShell
```powershell
.\start.ps1
```

### Opción 2: Comando npm
```bash
npm start
```

### Opción 3: Docker
```bash
docker-compose up -d
```

## 📊 Resultados Esperados

### Búsqueda Exitosa (200)
```json
{
  "Compra": [
    {
      "_id": "507f1f77bcf86cd799439011",
      "VIN": "1HGBH41JXMN109186",
      "Marca": "Toyota",
      "Modelo": "Corolla",
      "Anio": 2020,
      "Tipo": "Sedán",
      "Condicion": "Usado",
      "Transmision": "Automática",
      "Combustible": "Gasolina",
      "Kilometraje": 50000,
      "Color": "Blanco",
      "Precio": 250000,
      "Descripcion": "Vehículo en excelente estado",
      "Estado": "pendiente",
      "Imagen": "/uploads/1234567890-imagen.jpg",
      "UsuarioID": "507f1f77bcf86cd799439012"
    }
  ]
}
```

### Compra Exitosa (200)
```json
{
  "mensaje": "Compra guardada correctamente",
  "info": {
    "_id": "507f1f77bcf86cd799439011",
    "VIN": "1HGBH41JXMN109186",
    "Marca": "Toyota",
    "Modelo": "Corolla",
    "Anio": 2020,
    "Tipo": "Sedán",
    "Condicion": "Usado",
    "Transmision": "Automática",
    "Combustible": "Gasolina",
    "Kilometraje": 50000,
    "Color": "Blanco",
    "Precio": 250000,
    "Descripcion": "Vehículo en excelente estado",
    "Estado": "pendiente",
    "Imagen": "/uploads/1234567890-imagen.jpg",
    "UsuarioID": "507f1f77bcf86cd799439012"
  }
}
```

## 🎯 Próximos Pasos

1. **Ejecutar pruebas básicas** con `probar-api-completa.ps1`
2. **Obtener token JWT** registrando un usuario y haciendo login
3. **Probar endpoints de vehículos** con `probar-vehiculos.ps1`
4. **Probar endpoint de compras** con `probar-compras.ps1`
5. **Verificar documentación** en Swagger UI
6. **Revisar logs** para identificar cualquier problema restante

## 📞 Soporte

Si encuentras problemas:

1. **Revisa la documentación** en los archivos `.md`
2. **Ejecuta los scripts de prueba** para identificar el problema
3. **Verifica los logs** del servidor
4. **Consulta la documentación Swagger** para ver los endpoints disponibles

---

**¡Con estas herramientas y soluciones, tu API de AutoPrest debería funcionar perfectamente! 🚀**
