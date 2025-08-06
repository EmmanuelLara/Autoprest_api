// routes/usuarioRoutes.js
const express = require('express');
const router = express.Router();
const UsuarioController = require('../controllers/UsuarioController');
const CompraController = require('../controllers/Compracontroller');
const GerenteController = require('../controllers/GerenteController');
const authMiddleware = require('../middlewares/auth');
const subirImagen = require('../middlewares/subirImagen');
const CatalogoController = require('../controllers/CatalogoController');
const ContactoController = require('../controllers/ContactoController');
const ventascontroller = require('../controllers/VentaController');
const adminController = require('../controllers/AdminController');
const { get } = require('mongoose');

// --- Rutas públicas ---
router.post('/registro', UsuarioController.postRegistro);
router.post('/login', UsuarioController.postLogin);
router.get('/catalogo', CatalogoController.mostrarCatalogo);
router.post('/contacto' , ContactoController.agregarContacto);
router.get('/contacto', ContactoController.mostrarContacto);


// --- Rutas protegidas ---
router.post('/logout', authMiddleware.verificarToken, UsuarioController.logout);

// === Rutas para CLIENTE ===
router.post(
    '/cliente/compras',
    authMiddleware.verificarToken,
    authMiddleware.verificarRol('cliente'),
    subirImagen.upload.single('Imagen'),
    CompraController.agregarCompra
)

.get(
    '/cliente/vehiculos',
    authMiddleware.verificarToken,
    authMiddleware.verificarRol('cliente'),
    CompraController.buscarTodo
)

.get(
    '/cliente/vehiculos/:key/:value',
    authMiddleware.verificarToken,
    authMiddleware.verificarRol('cliente'),
    CompraController.buscarVehiculo,
    CompraController.mostrarVehiculos
)

// === Rutas para GERENTE ===
router.get(
    '/gerente/vehiculos/pendientes',
    authMiddleware.verificarToken,
    authMiddleware.verificarRol('gerente'),
    GerenteController.obtenerPendientes
)

.put(
    '/gerente/vehiculos/aprobar/:key/:value',
    authMiddleware.verificarToken,
    authMiddleware.verificarRol('gerente'),
    GerenteController.aprobarVehiculo
)

.delete(
    '/gerente/vehiculos/rechazar/:key/:value',
    authMiddleware.verificarToken,
    authMiddleware.verificarRol('gerente'),
    GerenteController.rechazarVehiculo
)
.get(
    '/gerente/vehiculos',   
    authMiddleware.verificarToken,
    authMiddleware.verificarRol('gerente'),
    GerenteController.buscarVehiculo,
    GerenteController.mostrarVehiculos
)

.get(
    '/gerente/vehiculos/detalle',
    authMiddleware.verificarToken,
    authMiddleware.verificarRol('gerente'),
    GerenteController.mostrarTodosVehiculos
)

.get(
    '/gerente/vehiculos/detalle/:key/:value',
    authMiddleware.verificarToken,
    authMiddleware.verificarRol('gerente'),
    GerenteController.buscarVehiculo,
    GerenteController.mostrarVehiculos
)
.post(
    '/gerente/ventas/:key/:value',
    authMiddleware.verificarToken,
    authMiddleware.verificarRol('gerente'),
    ventascontroller.realizarVenta
)
.get(
  '/gerente/ventas/:key/:value',
  authMiddleware.verificarToken,
  authMiddleware.verificarRol('gerente'),
  ventascontroller.buscarventa,
  ventascontroller.mostrarventa
)
.get(
    '/gerente/ventas',
    authMiddleware.verificarToken, 
    authMiddleware.verificarRol('gerente'),
    ventascontroller.buscarTodo
)


// === Rutas para ADMIN ===
router.get(
    '/usuarios',
    authMiddleware.verificarToken,
    authMiddleware.verificarRol('admin'),
    adminController.obtenerUsuarios
);

// Registrar nuevo usuario
router.post(
    '/usuarios',
    authMiddleware.verificarToken,
    authMiddleware.verificarRol('admin'),
    adminController.registrarUsuario
);

// Buscar un usuario por campo
router.get(
    '/usuarios/:key/:value',
    authMiddleware.verificarToken,
    authMiddleware.verificarRol('admin'),
    adminController.buscarUsuario,
    adminController.mostrarUsuarios
);

// Actualizar un usuario encontrado
router.put(
    '/usuarios/:key/:value',
    authMiddleware.verificarToken,
    authMiddleware.verificarRol('admin'),
    adminController.buscarUsuario,
    adminController.actualizarUsuario
);

// Eliminar un usuario encontrado
router.delete(
    '/usuarios/:key/:value',
    authMiddleware.verificarToken,
    authMiddleware.verificarRol('admin'),
    adminController.buscarUsuario,
    adminController.eliminarUsuario
);



module.exports = router;
