# 🔧 Solución al Error 500 en POST /cliente/compras

## 🚨 Problema Identificado

El error 500 ocurre porque el modelo de Compra requiere **muchos más campos** de los que estás enviando. Según el error, faltan estos campos requeridos:

- `Descripcion`
- `Precio`
- `Color`
- `Kilometraje`
- `Combustible`
- `Transmision`
- `Condicion`
- `Tipo`
- `Anio`
- `Modelo`
- `Marca`
- `VIN`

## ✅ Solución

### **Paso 1: Usar la documentación actualizada**

Ahora la documentación Swagger incluye **todos los campos requeridos** con ejemplos. Sigue estos pasos:

1. **Ve a la documentación**: `http://localhost:3000/api-docs`
2. **Busca el endpoint**: `POST /cliente/compras`
3. **Haz clic en "Try it out"**
4. **Selecciona el ejemplo**: "ejemplo_completo"
5. **Completa todos los campos requeridos**

### **Paso 2: Campos obligatorios que debes enviar**

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
  "Descripcion": "Vehículo en excelente estado, bien mantenido",
  "Accesorios": "Aire acondicionado, radio, alarma"
}
```

### **Paso 3: Campos que se llenan automáticamente**

El controlador llena automáticamente estos campos:
- `NombreVendedor`: Tu nombre (del token)
- `TelefonoVendedor`: Tu teléfono (del token)
- `UsuarioID`: Tu ID de usuario (del token)
- `Imagen`: Ruta del archivo subido
- `Estado`: "pendiente" (por defecto)

## 📋 Instrucciones paso a paso

### **1. Configurar autenticación**
1. Haz clic en **"Authorize"** (🔒)
2. Ingresa: `Bearer <tu-token-de-cliente>`
3. Haz clic en **"Authorize"**

### **2. Llenar el formulario**
1. **VIN**: Número de 17 caracteres (ej: "1HGBH41JXMN109186")
2. **Marca**: Marca del vehículo (ej: "Toyota")
3. **Modelo**: Modelo del vehículo (ej: "Corolla")
4. **Anio**: Año del vehículo (ej: 2020)
5. **Tipo**: Tipo de vehículo (ej: "Sedán", "SUV", "Pickup")
6. **Condicion**: Estado del vehículo (ej: "Usado", "Nuevo")
7. **Transmision**: Tipo de transmisión (ej: "Automática", "Manual")
8. **Combustible**: Tipo de combustible (ej: "Gasolina", "Diesel", "Eléctrico")
9. **Kilometraje**: Número de kilómetros (ej: 50000)
10. **Color**: Color del vehículo (ej: "Blanco", "Negro", "Azul")
11. **Precio**: Precio en números (ej: 250000)
12. **Descripcion**: Descripción detallada
13. **Accesorios**: Opcional (ej: "Aire acondicionado, radio")
14. **Imagen**: Selecciona un archivo de imagen

### **3. Ejecutar la petición**
1. Haz clic en **"Execute"**
2. Deberías recibir una respuesta **200** con el mensaje "Compra guardada correctamente"

## 🎯 Ejemplo completo para copiar y pegar

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
  "Descripcion": "Vehículo en excelente estado, bien mantenido, sin accidentes",
  "Accesorios": "Aire acondicionado, radio, alarma, rines deportivos"
}
```

## ⚠️ Validaciones importantes

### **VIN (Número de identificación del vehículo)**
- Debe tener exactamente 17 caracteres
- Solo letras (A-Z) y números (0-9)
- No puede contener las letras I, O, Q
- Ejemplo válido: "1HGBH41JXMN109186"

### **Año**
- Debe estar entre 1900 y el año actual + 1
- Ejemplo: si estamos en 2024, puede ser hasta 2025

### **Kilometraje**
- Debe ser un número positivo
- Ejemplo: 50000

### **Precio**
- Debe ser un número mayor a 0
- Ejemplo: 250000

## 🐛 Si aún tienes problemas

### **Error 400 - Imagen requerida**
- Asegúrate de seleccionar un archivo de imagen
- El campo "Imagen" es obligatorio

### **Error 400 - VIN inválido**
- Verifica que el VIN tenga exactamente 17 caracteres
- Solo usa letras A-Z (sin I, O, Q) y números 0-9

### **Error 400 - Año inválido**
- El año debe estar entre 1900 y el año actual + 1

### **Error 500 - Otros campos**
- Verifica que todos los campos requeridos estén completos
- Revisa que los tipos de datos sean correctos (números para Precio, Kilometraje, Anio)

## 📞 Soporte adicional

Si sigues teniendo problemas:
1. Verifica que estés usando un token de usuario con rol "cliente"
2. Asegúrate de que el servidor esté ejecutándose
3. Revisa los logs del servidor para más detalles del error
4. Contacta al equipo de desarrollo

---

**¡Con estos cambios, el endpoint debería funcionar correctamente! 🚀**
