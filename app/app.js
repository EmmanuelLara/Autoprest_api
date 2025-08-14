const express = require('express');
const app = express();
const router = require('./routes/usuarioRoutes'); 
const path = require('path');
const swaggerUi = require('swagger-ui-express');
const swaggerSpecs = require('./config/swagger');
const cors = require('cors');

// Configuración de CORS para permitir acceso desde cualquier origen
app.use(cors({
  origin: (origin, callback) => callback(null, true),
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With'],
  credentials: false,
  exposedHeaders: ['Content-Type', 'Authorization']
}));

// Habilitar preflight para todas las rutas
app.options('*', cors());

// Parseo de body JSON y URL encoded
app.use(express.urlencoded({ extended: false }));
app.use(express.json());

// Servir archivos estáticos de la carpeta pública /uploads
app.use('/uploads', express.static(path.join(__dirname, 'public', 'uploads')));

// Servir archivos estáticos de la carpeta pública
app.use('/public', express.static(path.join(__dirname, 'public')));

// Ruta para la documentación Swagger personalizada
app.get('/docs', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'swagger-custom.html'));
});

// Endpoint para obtener la especificación Swagger en JSON con servidor dinámico (IP/host actual)
app.get('/swagger.json', (req, res) => {
    res.setHeader('Content-Type', 'application/json');
    const protocol = req.headers['x-forwarded-proto'] || req.protocol;
    const host = req.get('host');

    // Clonar el spec e inyectar el servidor actual al inicio
    const dynamicSpecs = {
      ...swaggerSpecs,
      servers: [
        { url: `${protocol}://${host}`, description: 'Servidor actual (dinámico)' },
        ...(swaggerSpecs.servers || [])
      ]
    };

    res.json(dynamicSpecs);
});

// Configuración de Swagger UI simplificada (consume /swagger.json dinámico)
app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(null, {
  customCss: '.swagger-ui .topbar { display: none }',
  customSiteTitle: 'AutoPrest API Documentation',
  customfavIcon: '/favicon.ico',
  swaggerOptions: {
    url: '/swagger.json',
    docExpansion: 'list',
    filter: true,
    showRequestHeaders: true,
    showCommonExtensions: true,
    tryItOutEnabled: true,
    defaultModelExpandDepth: 3,
    displayRequestDuration: true,
    persistAuthorization: true
  },
  explorer: true
}));

// Prefijo para las rutas de usuarios
app.use('/', router);

app.get('/', (req, res) => {
    res.json({ mensaje: 'API de AutoPrest funcionando 🚗' });
});

module.exports = app;
