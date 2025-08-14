# 📚 Instrucciones para usar la Documentación Swagger UI

## 🚀 Cómo acceder a la documentación

1. **Asegúrate de que tu servidor esté ejecutándose:**
   ```bash
   npm run dev
   ```

2. **Abre tu navegador y ve a:**
   ```
   http://localhost:3000/api-docs
   ```

## 🔍 Funcionalidades de la Documentación

### **1. Interfaz Interactiva**
- **Try it out**: Botón para ejecutar peticiones directamente
- **Authorize**: Configurar token JWT para endpoints protegidos
- **Ejemplos predefinidos**: Datos de ejemplo para cada endpoint
- **Respuestas detalladas**: Ver exactamente qué devuelve cada endpoint

### **2. Organización por Categorías**
- **🔐 Autenticación**: Registro, login, logout
- **📋 Catálogo**: Ver vehículos disponibles
- **👤 Cliente**: Gestión de compras y vehículos
- **👨‍💼 Gerente**: Aprobar/rechazar vehículos, gestionar ventas
- **👨‍💻 Admin**: Gestión completa de usuarios
- **📞 Contacto**: Enviar y ver mensajes
- **🧪 Pruebas**: Endpoint de verificación

## 🔑 Cómo usar la documentación paso a paso

### **Paso 1: Probar el endpoint de prueba**
1. Ve a la sección **"Pruebas"**
2. Haz clic en `GET /test`
3. Haz clic en **"Try it out"**
4. Haz clic en **"Execute"**
5. Verás la respuesta con timestamp y versión

### **Paso 2: Registrar un usuario**
1. Ve a la sección **"Autenticación"**
2. Haz clic en `POST /registro`
3. Haz clic en **"Try it out"**
4. Selecciona un ejemplo (cliente o gerente)
5. Modifica los datos si quieres
6. Haz clic en **"Execute"**
7. **Copia el token** de la respuesta

### **Paso 3: Configurar autenticación**
1. Haz clic en el botón **"Authorize"** (🔒) en la parte superior
2. En el campo "bearerAuth", ingresa: `Bearer <tu-token>`
3. Haz clic en **"Authorize"**
4. Cierra la ventana

### **Paso 4: Probar endpoints protegidos**
Ahora puedes probar cualquier endpoint que requiera autenticación:
- **Cliente**: `/cliente/compras`, `/cliente/vehiculos`
- **Gerente**: `/gerente/vehiculos/*`, `/gerente/ventas/*`
- **Admin**: `/usuarios/*`

## 📝 Ejemplos de uso

### **Registrar un cliente:**
```json
{
  "nombre": "Juan Pérez",
  "telefono": "5512345678",
  "email": "juan@example.com",
  "pass": "password123",
  "rol": "cliente"
}
```

### **Iniciar sesión:**
```json
{
  "email": "juan@example.com",
  "pass": "password123"
}
```

### **Registrar una compra (requiere token):**
```json
{
  "marca": "Toyota",
  "modelo": "Corolla",
  "año": 2020,
  "precio": 250000,
  "descripcion": "Vehículo en excelente estado"
}
```

## 🎯 Códigos de respuesta

### **Éxito (2xx):**
- **200**: Operación exitosa
- **201**: Recurso creado exitosamente

### **Error del cliente (4xx):**
- **400**: Datos inválidos
- **401**: No autorizado (token requerido)
- **403**: Permisos insuficientes
- **404**: Recurso no encontrado
- **409**: Conflicto (ej: email ya existe)

### **Error del servidor (5xx):**
- **500**: Error interno del servidor

## 🔧 Características avanzadas

### **1. Filtros y búsqueda**
- Usa la barra de búsqueda para encontrar endpoints específicos
- Filtra por tags (Autenticación, Cliente, etc.)

### **2. Headers automáticos**
- Content-Type se establece automáticamente
- Authorization se maneja con el botón Authorize

### **3. Ejemplos predefinidos**
- Cada endpoint tiene ejemplos de request
- Puedes modificar los ejemplos antes de ejecutar

### **4. Respuestas detalladas**
- Verás el código de estado HTTP
- Headers de respuesta
- Body de respuesta formateado
- Tiempo de respuesta

## 🐛 Solución de problemas

### **Problema: "Try it out" no funciona**
- Verifica que el servidor esté ejecutándose
- Recarga la página de documentación

### **Problema: Token no funciona**
- Asegúrate de incluir "Bearer " antes del token
- Verifica que el token no haya expirado
- Regenera el token con un nuevo login

### **Problema: Error 500**
- Revisa los logs del servidor
- Verifica que MongoDB esté conectado
- Comprueba que los datos sean válidos

## 📞 Soporte

Si tienes problemas con la documentación:
1. Verifica que todas las dependencias estén instaladas
2. Revisa los logs del servidor
3. Asegúrate de que MongoDB esté funcionando
4. Contacta al equipo de desarrollo

---

**¡Disfruta explorando tu API con Swagger UI! 🚀**
