// Configuración específica para Swagger UI
const swaggerUiOptions = {
  swaggerOptions: {
    url: 'https://e8498afce672.ngrok-free.app',
    defaultModelsExpandDepth: -1,
    defaultModelExpandDepth: 3,
    displayRequestDuration: true,
    docExpansion: 'list',
    filter: true,
    showExtensions: true,
    showCommonExtensions: true,
    tryItOutEnabled: true,
    requestInterceptor: (request) => {
      // Forzar el uso de la URL pública de ngrok
      if (request.url && request.url.startsWith('http://localhost')) {
        request.url = request.url.replace('http://localhost:3000', 'https://e8498afce672.ngrok-free.app');
      }
      return request;
    }
  },
  customCss: `
    .swagger-ui .topbar { display: none; }
    .swagger-ui .info .title { color: #2c3e50; }
    .swagger-ui .scheme-container { background: #f8f9fa; }
  `,
  customSiteTitle: 'AutoPrest API - Documentación Pública'
};

module.exports = swaggerUiOptions;
