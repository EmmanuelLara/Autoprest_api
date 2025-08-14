// Script de inicialización para MongoDB
db = db.getSiblingDB('autoprest');

// Crear colecciones si no existen
db.createCollection('usuarios');
db.createCollection('catalogos');
db.createCollection('compras');
db.createCollection('contactos');
db.createCollection('ventas');

// Crear índices para optimizar consultas
db.usuarios.createIndex({ "email": 1 }, { unique: true });
db.usuarios.createIndex({ "rol": 1 });
db.catalogos.createIndex({ "marca": 1 });
db.catalogos.createIndex({ "modelo": 1 });
db.compras.createIndex({ "usuarioId": 1 });
db.compras.createIndex({ "estado": 1 });
db.ventas.createIndex({ "vehiculoId": 1 });
db.ventas.createIndex({ "fechaVenta": 1 });

print('Base de datos AutoPrest inicializada correctamente');
