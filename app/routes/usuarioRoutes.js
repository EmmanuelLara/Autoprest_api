// routes/usuarioRoutes.js
const express = require('express');
const router = express.Router();
const UsuarioController = require('../controllers/UsuarioController');
const CompraController = require('../controllers/Compracontroller');
const authMiddleware = require('../middlewares/auth');
const subirImagen = require('../middlewares/subirImagen');

router.post('/registro', UsuarioController.postRegistro)
      .post('/login', UsuarioController.postLogin)
      .post('/logout', authMiddleware.verificarToken, UsuarioController.logout)

router.post('/compras', authMiddleware.verificarToken, subirImagen.upload.single('Imagen'), CompraController.agregarCompra);




module.exports = router;