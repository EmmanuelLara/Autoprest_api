const swaggerJsdoc = require('swagger-jsdoc');

const options = {
  definition: {
    openapi: '3.0.0',
    info: {
      title: 'AutoPrest API',
      version: '1.0.0',
      description: 'API para gestión de vehículos y préstamos automotrices. Puedes probar todos los endpoints directamente desde esta interfaz.',
      contact: {
        name: 'AutoPrest Support',
        email: 'support@autoprest.com'
      }
    },
    servers: [
      {
        url: 'http://localhost:3000',
        description: '🏠 Servidor local - Para desarrollo'
      },
      {
        url: 'http://localhost:3000',
        description: '🐳 Servidor Docker - Para pruebas con contenedores'
      },
      {
        url: 'https://e949ecceb86b.ngrok-free.app',
        description: '🌐 Servidor público (ngrok) - RECOMENDADO para pruebas externas'
      }
    ],
    components: {
      securitySchemes: {
        bearerAuth: {
          type: 'http',
          scheme: 'bearer',
          bearerFormat: 'JWT',
          description: 'Ingresa tu token JWT obtenido del login'
        }
      },
      schemas: {
        Usuario: {
          type: 'object',
          properties: {
            nombre: {
              type: 'string',
              description: 'Nombre completo del usuario',
              example: 'Juan Pérez'
            },
            telefono: {
              type: 'string',
              description: 'Número de teléfono (10 dígitos)',
              example: '5512345678'
            },
            email: {
              type: 'string',
              format: 'email',
              description: 'Correo electrónico',
              example: 'juan@example.com'
            },
            pass: {
              type: 'string',
              description: 'Contraseña (mínimo 6 caracteres, una letra y un número)',
              example: 'password123'
            },
            rol: {
              type: 'string',
              enum: ['admin', 'cliente', 'gerente'],
              description: 'Rol del usuario',
              example: 'cliente'
            }
          },
          required: ['nombre', 'telefono', 'email', 'pass']
        },
        Login: {
          type: 'object',
          properties: {
            email: {
              type: 'string',
              format: 'email',
              description: 'Correo electrónico',
              example: 'juan@example.com'
            },
            pass: {
              type: 'string',
              description: 'Contraseña',
              example: 'password123'
            }
          },
          required: ['email', 'pass']
        },
                 Vehiculo: {
           type: 'object',
           properties: {
             VIN: {
               type: 'string',
               description: 'Número VIN del vehículo (17 caracteres alfanuméricos)',
               example: '1HGBH41JXMN109186'
             },
             Marca: {
               type: 'string',
               description: 'Marca del vehículo',
               example: 'Toyota'
             },
             Modelo: {
               type: 'string',
               description: 'Modelo del vehículo',
               example: 'Corolla'
             },
             Anio: {
               type: 'number',
               description: 'Año del vehículo (1900-actual+1)',
               example: 2020
             },
             Tipo: {
               type: 'string',
               description: 'Tipo de vehículo',
               example: 'Sedán'
             },
             Condicion: {
               type: 'string',
               description: 'Condición del vehículo',
               example: 'Usado'
             },
             Transmision: {
               type: 'string',
               description: 'Tipo de transmisión',
               example: 'Automática'
             },
             Combustible: {
               type: 'string',
               description: 'Tipo de combustible',
               example: 'Gasolina'
             },
             Kilometraje: {
               type: 'number',
               description: 'Kilometraje del vehículo',
               example: 50000
             },
             Color: {
               type: 'string',
               description: 'Color del vehículo',
               example: 'Blanco'
             },
             Precio: {
               type: 'number',
               description: 'Precio del vehículo',
               example: 250000
             },
             Descripcion: {
               type: 'string',
               description: 'Descripción detallada del vehículo',
               example: 'Vehículo en excelente estado, bien mantenido'
             },
             Accesorios: {
               type: 'string',
               description: 'Accesorios adicionales',
               example: 'Aire acondicionado, radio, alarma'
             },
                           // Estado se establece automáticamente como 'pendiente'
             Imagen: {
               type: 'string',
               format: 'binary',
               description: 'Subir archivo de imagen del vehículo (requerido)',
               example: 'archivo.jpg'
             }
           },
           required: ['VIN', 'Marca', 'Modelo', 'Anio', 'Tipo', 'Condicion', 'Transmision', 'Combustible', 'Kilometraje', 'Color', 'Precio', 'Descripcion', 'Accesorios', 'Imagen']
         },
        Contacto: {
          type: 'object',
          properties: {
            nombre: {
              type: 'string',
              description: 'Nombre del contacto',
              example: 'María García'
            },
            email: {
              type: 'string',
              format: 'email',
              description: 'Correo electrónico',
              example: 'maria@example.com'
            },
            mensaje: {
              type: 'string',
              description: 'Mensaje del contacto',
              example: 'Me interesa un vehículo'
            }
          },
          required: ['nombre', 'email', 'mensaje']
        },
        Venta: {
          type: 'object',
          properties: {
            comprador_nombre: {
              type: 'string',
              description: 'Nombre del comprador',
              example: 'Juan Carlos'
            },
            comprador_apellidos: {
              type: 'string',
              description: 'Apellidos del comprador',
              example: 'García López'
            },
            comprador_telefono: {
              type: 'string',
              description: 'Teléfono del comprador',
              example: '5512345678'
            },
            comprador_correo: {
              type: 'string',
              format: 'email',
              description: 'Correo electrónico del comprador',
              example: 'juan.garcia@example.com'
            },
            vehiculoId: {
              type: 'string',
              description: 'ID del vehículo vendido (opcional, se obtiene automáticamente)',
              example: '507f1f77bcf86cd799439011'
            },
            precioVenta: {
              type: 'number',
              description: 'Precio de venta (opcional, se obtiene del vehículo)',
              example: 250000
            },
            fechaVenta: {
              type: 'string',
              format: 'date',
              description: 'Fecha de venta (opcional, se establece automáticamente)',
              example: '2024-01-15'
            }
          },
          required: ['comprador_nombre', 'comprador_apellidos', 'comprador_telefono', 'comprador_correo']
        },
        ErrorResponse: {
          type: 'object',
          properties: {
            mensaje: {
              type: 'string',
              description: 'Mensaje de error',
              example: 'Error en el servidor'
            },
            errores: {
              type: 'array',
              items: {
                type: 'string'
              },
              description: 'Lista de errores de validación',
              example: ['Email inválido', 'Contraseña muy corta']
            }
          }
        },
        SuccessResponse: {
          type: 'object',
          properties: {
            mensaje: {
              type: 'string',
              description: 'Mensaje de éxito',
              example: 'Operación exitosa'
            },
            token: {
              type: 'string',
              description: 'Token JWT para autenticación',
              example: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...'
            },
            usuario: {
              type: 'object',
              properties: {
                usuarioId: {
                  type: 'string',
                  example: '507f1f77bcf86cd799439011'
                },
                nombre: {
                  type: 'string',
                  example: 'Juan Pérez'
                },
                rol: {
                  type: 'string',
                  example: 'cliente'
                },
                telefono: {
                  type: 'string',
                  example: '5512345678'
                },
                email: {
                  type: 'string',
                  example: 'juan@example.com'
                }
              }
            }
          }
        }
      }
    }
  },
  apis: ['./app/routes/*.js', './app/controllers/*.js']
};

const specs = swaggerJsdoc(options);

module.exports = specs;
