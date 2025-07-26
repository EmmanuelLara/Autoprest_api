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

// --- Rutas públicas ---
router.post('/registro', UsuarioController.postRegistro);
router.post('/login', UsuarioController.postLogin);
router.get('/catalogo', CatalogoController.mostrarCatalogo);
router.post('/contacto' , ContactoController.agregarContacto);


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
    CompraController.buscarJoya,
    CompraController.mostrandojoyas
)

// === Rutas para GERENTE ===
router.get(
    '/gerente/vehiculos/pendientes',
    authMiddleware.verificarToken,
    authMiddleware.verificarRol('gerente'),
    GerenteController.obtenerPendientes
)

.put(
    '/gerente/vehiculos/aprobar/:id',
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
    '/gerente/vehiculos/detalle/:key/:value',
    authMiddleware.verificarToken,
    authMiddleware.verificarRol('gerente'),
    GerenteController.buscarVehiculo,
    GerenteController.mostrarVehiculos
)
.post(
    '/gerente/ventas/:id',
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
);



module.exports = router;
