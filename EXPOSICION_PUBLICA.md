# 🌐 Exposición Pública de la API AutoPrest

## 📋 Descripción
Este documento explica cómo exponer tu API AutoPrest públicamente usando Docker y Ngrok, permitiendo que sea accesible desde cualquier parte del mundo durante aproximadamente 2 horas.

## 🚀 Pasos para Exposición Pública

### 1. Obtener Token de Ngrok
1. Ve a [https://ngrok.com/](https://ngrok.com/)
2. Crea una cuenta gratuita
3. Inicia sesión en tu dashboard
4. Copia tu **authtoken** desde la sección "Your Authtoken"

### 2. Configurar Variables de Entorno
1. Abre el archivo `.env` (se creará automáticamente)
2. Reemplaza `tu_token_de_ngrok_aqui` con tu token real:
   ```env
   NGROK_AUTHTOKEN=tu_token_real_aqui
   ```

### 3. Ejecutar el Script de Exposición
```powershell
# En PowerShell, ejecuta:
.\exponer-api.ps1
```

### 4. Verificar la Exposición
El script te mostrará:
- ✅ Estado de Docker
- 🔨 Construcción de servicios
- 🌐 URL pública generada
- 📚 Enlaces a la documentación Swagger

## 📱 URLs Disponibles

Una vez expuesta, tendrás acceso a:
- **API Base**: `https://xxxx-xx-xx-xxx-xx.ngrok.io`
- **Documentación Swagger**: `https://xxxx-xx-xx-xxx-xx.ngrok.io/api-docs/`
- **Health Check**: `https://xxxx-xx-xx-xxx-xx.ngrok.io/health`

## ⏰ Duración y Limitaciones

- **Duración**: 2 horas (plan gratuito de ngrok)
- **Conexiones simultáneas**: Limitadas en plan gratuito
- **Ancho de banda**: Limitado en plan gratuito

## 🛑 Detener la Exposición

```powershell
# Para detener todos los servicios:
docker-compose down

# Para ver logs en tiempo real:
docker-compose logs -f ngrok
```

## 🔧 Solución de Problemas

### Error: "No se pudo obtener la URL pública"
1. Verifica que Docker esté ejecutándose
2. Asegúrate de que el token de ngrok sea válido
3. Revisa los logs: `docker-compose logs ngrok`

### Error: "Puerto ya en uso"
1. Detén servicios existentes: `docker-compose down`
2. Verifica que no haya otros servicios usando el puerto 3000

### Error: "Token inválido"
1. Verifica tu token en [https://ngrok.com/dashboard](https://ngrok.com/dashboard)
2. Asegúrate de que el archivo `.env` contenga el token correcto

## 📊 Monitoreo

### Ver Estado de Servicios
```powershell
docker-compose ps
```

### Ver Logs en Tiempo Real
```powershell
# Logs de ngrok:
docker-compose logs -f ngrok

# Logs de la API:
docker-compose logs -f api

# Logs de MongoDB:
docker-compose logs -f mongodb
```

### Estadísticas de Ngrok
- Visita: `http://localhost:4040`
- Verás estadísticas en tiempo real del túnel

## 🔒 Seguridad

⚠️ **IMPORTANTE**: Esta exposición es temporal y pública
- No uses en producción
- No expongas datos sensibles
- La URL es accesible desde cualquier lugar
- Considera implementar autenticación adicional si es necesario

## 📞 Soporte

Si tienes problemas:
1. Verifica que Docker esté ejecutándose
2. Revisa los logs de los servicios
3. Asegúrate de que el token de ngrok sea válido
4. Verifica que los puertos 3000 y 4040 estén disponibles

## 🎯 Próximos Pasos

Una vez que tu API esté expuesta:
1. Comparte la URL con tu equipo
2. Prueba los endpoints desde diferentes dispositivos
3. Verifica que la documentación Swagger sea accesible
4. Monitorea el uso y rendimiento

---

**¡Tu API AutoPrest está lista para ser compartida con el mundo! 🌍**
