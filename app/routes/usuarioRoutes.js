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

/**
 * @swagger
 * /test:
 *   get:
 *     summary: Endpoint de prueba
 *     description: Endpoint para verificar que la API está funcionando correctamente
 *     tags: [Pruebas]
 *     responses:
 *       200:
 *         description: API funcionando correctamente
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 mensaje:
 *                   type: string
 *                   example: "API funcionando correctamente"
 *                 timestamp:
 *                   type: string
 *                   format: date-time
 *                 version:
 *                   type: string
 *                   example: "1.0.0"
 */
router.get('/test', (req, res) => {
    res.json({
        mensaje: "API funcionando correctamente",
        timestamp: new Date().toISOString(),
        version: "1.0.0"
    });
});

// Endpoint de prueba para verificar middleware
router.get('/test-auth', authMiddleware.verificarToken, (req, res) => {
    res.json({
        mensaje: "Middleware de autenticación funcionando correctamente",
        usuario: req.user,
        timestamp: new Date().toISOString()
    });
});

/**
 * @swagger
 * /registro:
 *   post:
 *     summary: Registrar un nuevo usuario
 *     description: Crea una nueva cuenta de usuario. El rol por defecto es 'cliente' si no se especifica.
 *     tags: [Autenticación]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/Usuario'
 *     responses:
 *       201:
 *         description: Usuario registrado exitosamente
 *       400:
 *         description: Datos inválidos
 *       409:
 *         description: Correo ya registrado
 *       500:
 *         description: Error del servidor
 */
router.post('/registro', UsuarioController.postRegistro);

/**
 * @swagger
 * /login:
 *   post:
 *     summary: Iniciar sesión
 *     description: Autentica un usuario y devuelve un token JWT
 *     tags: [Autenticación]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/Login'
 *     responses:
 *       200:
 *         description: Login exitoso
 *       400:
 *         description: Datos inválidos
 *       401:
 *         description: Credenciales incorrectas
 *       500:
 *         description: Error del servidor
 */
router.post('/login', UsuarioController.postLogin);

/**
 * @swagger
 * /catalogo:
 *   get:
 *     summary: Obtener catálogo de vehículos
 *     description: Obtiene todos los vehículos aprobados para venta
 *     tags: [Catálogo]
 *     responses:
 *       200:
 *         description: Lista de vehículos disponibles
 *       500:
 *         description: Error del servidor
 */
router.get('/catalogo', CatalogoController.mostrarCatalogo);

/**
 * @swagger
 * /contacto:
 *   post:
 *     summary: Enviar mensaje de contacto
 *     description: Registra un mensaje de contacto
 *     tags: [Contacto]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/Contacto'
 *     responses:
 *       201:
 *         description: Mensaje enviado exitosamente
 *       400:
 *         description: Datos inválidos
 *       500:
 *         description: Error del servidor
 */
router.post('/contacto', ContactoController.agregarContacto);

/**
 * @swagger
 * /logout:
 *   post:
 *     summary: Cerrar sesión
 *     description: Invalida el token JWT del usuario
 *     tags: [Autenticación]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Logout exitoso
 *       401:
 *         description: No autorizado
 *       500:
 *         description: Error del servidor
 */
router.post('/logout', authMiddleware.verificarToken, UsuarioController.logout);

// === Rutas para CLIENTE ===

/**
 * @swagger
 * /cliente/compras:
 *   post:
 *     summary: Registrar compra de vehículo
 *     description: Registra la compra de un vehículo por parte del cliente. Todos los campos son requeridos incluyendo la imagen. Los campos de texto no pueden contener caracteres especiales como %&$#@!*()_+-=[]{};':"\\|.<>/? (Descripción y Accesorios permiten comas).
 *     tags: [Cliente]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         multipart/form-data:
 *           schema:
 *             $ref: '#/components/schemas/Vehiculo'
 *     responses:
 *       200:
 *         description: Compra registrada exitosamente
 *       400:
 *         description: Datos inválidos, campos requeridos faltantes o caracteres especiales no permitidos
 *       401:
 *         description: No autorizado
 *       500:
 *         description: Error del servidor
 */
router.post('/cliente/compras', authMiddleware.verificarToken, authMiddleware.verificarRol('cliente'), subirImagen.upload.single('Imagen'), CompraController.agregarCompra);



// === Rutas para GERENTE ===

/**
 * @swagger
 * /gerente/vehiculos/pendientes:
 *   get:
 *     summary: Obtener vehículos pendientes de aprobación
 *     tags: [Gerente]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Lista de vehículos pendientes
 *       401:
 *         description: No autorizado
 *       500:
 *         description: Error del servidor
 */
router.get('/gerente/vehiculos/pendientes', authMiddleware.verificarToken, authMiddleware.verificarRol('gerente'), GerenteController.obtenerPendientes);

/**
 * @swagger
 * /gerente/vehiculos/aprobar/{key}/{value}:
 *   put:
 *     summary: Aprobar vehículo
 *     tags: [Gerente]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: key
 *         required: true
 *         schema:
 *           type: string
 *         description: Campo de búsqueda
 *       - in: path
 *         name: value
 *         required: true
 *         schema:
 *           type: string
 *         description: Valor a buscar
 *     responses:
 *       200:
 *         description: Vehículo aprobado exitosamente
 *       401:
 *         description: No autorizado
 *       404:
 *         description: Vehículo no encontrado
 *       500:
 *         description: Error del servidor
 */
router.put('/gerente/vehiculos/aprobar/:key/:value', authMiddleware.verificarToken, authMiddleware.verificarRol('gerente'), GerenteController.aprobarVehiculo);

/**
 * @swagger
 * /gerente/vehiculos/rechazar/{key}/{value}:
 *   delete:
 *     summary: Rechazar vehículo
 *     tags: [Gerente]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: key
 *         required: true
 *         schema:
 *           type: string
 *         description: Campo de búsqueda
 *       - in: path
 *         name: value
 *         required: true
 *         schema:
 *           type: string
 *         description: Valor a buscar
 *     responses:
 *       200:
 *         description: Vehículo rechazado exitosamente
 *       401:
 *         description: No autorizado
 *       404:
 *         description: Vehículo no encontrado
 *       500:
 *         description: Error del servidor
 */
router.delete('/gerente/vehiculos/rechazar/:key/:value', authMiddleware.verificarToken, authMiddleware.verificarRol('gerente'), GerenteController.rechazarVehiculo);

/**
 * @swagger
 * /gerente/vehiculos:
 *   get:
 *     summary: Obtener todos los vehículos
 *     tags: [Gerente]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Lista de todos los vehículos
 *       401:
 *         description: No autorizado
 *       500:
 *         description: Error del servidor
 */
router.get('/gerente/vehiculos', authMiddleware.verificarToken, authMiddleware.verificarRol('gerente'), GerenteController.mostrarTodosVehiculos);

/**
 * @swagger
 * /gerente/vehiculos/detalle:
 *   get:
 *     summary: Obtener todos los vehículos (detalle)
 *     tags: [Gerente]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Lista de todos los vehículos
 *       401:
 *         description: No autorizado
 *       500:
 *         description: Error del servidor
 */
router.get('/gerente/vehiculos/detalle', authMiddleware.verificarToken, authMiddleware.verificarRol('gerente'), GerenteController.mostrarTodosVehiculos);

/**
 * @swagger
 * /gerente/vehiculos/detalle/{key}/{value}:
 *   get:
 *     summary: Obtener detalles de un vehículo específico
 *     tags: [Gerente]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: key
 *         required: true
 *         schema:
 *           type: string
 *         description: Campo de búsqueda
 *       - in: path
 *         name: value
 *         required: true
 *         schema:
 *           type: string
 *         description: Valor a buscar
 *     responses:
 *       200:
 *         description: Detalles del vehículo
 *       401:
 *         description: No autorizado
 *       404:
 *         description: Vehículo no encontrado
 *       500:
 *         description: Error del servidor
 */
router.get('/gerente/vehiculos/detalle/:key/:value', authMiddleware.verificarToken, authMiddleware.verificarRol('gerente'), GerenteController.buscarVehiculo, GerenteController.mostrarVehiculos);

/**
 * @swagger
 * /gerente/ventas/{key}/{value}:
 *   post:
 *     summary: Realizar venta de vehículo
 *     tags: [Gerente]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: key
 *         required: true
 *         schema:
 *           type: string
 *         description: Campo de búsqueda
 *       - in: path
 *         name: value
 *         required: true
 *         schema:
 *           type: string
 *         description: Valor a buscar
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/Venta'
 *     responses:
 *       201:
 *         description: Venta realizada exitosamente
 *       400:
 *         description: Datos inválidos
 *       401:
 *         description: No autorizado
 *       404:
 *         description: Vehículo no encontrado
 *       500:
 *         description: Error del servidor
 *   get:
 *     summary: Buscar venta específica
 *     tags: [Gerente]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: key
 *         required: true
 *         schema:
 *           type: string
 *         description: Campo de búsqueda
 *       - in: path
 *         name: value
 *         required: true
 *         schema:
 *           type: string
 *         description: Valor a buscar
 *     responses:
 *       200:
 *         description: Venta encontrada
 *       401:
 *         description: No autorizado
 *       404:
 *         description: Venta no encontrada
 *       500:
 *         description: Error del servidor
 */
router.post('/gerente/ventas/:key/:value', authMiddleware.verificarToken, authMiddleware.verificarRol('gerente'), ventascontroller.realizarVenta);
router.get('/gerente/ventas/:key/:value', authMiddleware.verificarToken, authMiddleware.verificarRol('gerente'), ventascontroller.buscarventa, ventascontroller.mostrarventa);

/**
 * @swagger
 * /gerente/ventas:
 *   get:
 *     summary: Obtener todas las ventas
 *     tags: [Gerente]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Lista de todas las ventas
 *       401:
 *         description: No autorizado
 *       500:
 *         description: Error del servidor
 */
router.get('/gerente/ventas', authMiddleware.verificarToken, authMiddleware.verificarRol('gerente'), ventascontroller.buscarTodo);

// === Rutas para ADMIN ===

/**
 * @swagger
 * /usuarios:
 *   get:
 *     summary: Obtener todos los usuarios
 *     tags: [Admin]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Lista de todos los usuarios
 *       401:
 *         description: No autorizado
 *       500:
 *         description: Error del servidor
 *   post:
 *     summary: Registrar nuevo usuario
 *     tags: [Admin]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/Usuario'
 *     responses:
 *       201:
 *         description: Usuario registrado exitosamente
 *       400:
 *         description: Datos inválidos
 *       401:
 *         description: No autorizado
 *       409:
 *         description: Correo ya registrado
 *       500:
 *         description: Error del servidor
 */
router.get('/usuarios', authMiddleware.verificarToken, authMiddleware.verificarRol('admin'), adminController.obtenerUsuarios);
router.post('/usuarios', authMiddleware.verificarToken, authMiddleware.verificarRol('admin'), adminController.registrarUsuario);

/**
 * @swagger
 * /usuarios/{key}/{value}:
 *   get:
 *     summary: Buscar usuario específico
 *     tags: [Admin]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: key
 *         required: true
 *         schema:
 *           type: string
 *         description: Campo de búsqueda
 *       - in: path
 *         name: value
 *         required: true
 *         schema:
 *           type: string
 *         description: Valor a buscar
 *     responses:
 *       200:
 *         description: Usuario encontrado
 *       401:
 *         description: No autorizado
 *       404:
 *         description: Usuario no encontrado
 *       500:
 *         description: Error del servidor
 *   put:
 *     summary: Actualizar usuario
 *     tags: [Admin]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: key
 *         required: true
 *         schema:
 *           type: string
 *         description: Campo de búsqueda
 *       - in: path
 *         name: value
 *         required: true
 *         schema:
 *           type: string
 *         description: Valor a buscar
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/Usuario'
 *     responses:
 *       200:
 *         description: Usuario actualizado exitosamente
 *       400:
 *         description: Datos inválidos
 *       401:
 *         description: No autorizado
 *       404:
 *         description: Usuario no encontrado
 *       500:
 *         description: Error del servidor
 *   delete:
 *     summary: Eliminar usuario
 *     tags: [Admin]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: key
 *         required: true
 *         schema:
 *           type: string
 *         description: Campo de búsqueda
 *       - in: path
 *         name: value
 *         required: true
 *         schema:
 *           type: string
 *         description: Valor a buscar
 *     responses:
 *       200:
 *         description: Usuario eliminado exitosamente
 *       401:
 *         description: No autorizado
 *       404:
 *         description: Usuario no encontrado
 *       500:
 *         description: Error del servidor
 */
router.get('/usuarios/:key/:value', authMiddleware.verificarToken, authMiddleware.verificarRol('admin'), adminController.buscarUsuario, adminController.mostrarUsuarios);
router.put('/usuarios/:key/:value', authMiddleware.verificarToken, authMiddleware.verificarRol('admin'), adminController.buscarUsuario, adminController.actualizarUsuario);
router.delete('/usuarios/:key/:value', authMiddleware.verificarToken, authMiddleware.verificarRol('admin'), adminController.buscarUsuario, adminController.eliminarUsuario);

module.exports = router;
