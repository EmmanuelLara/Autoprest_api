// routes/usuarioRoutes.js
const express = require('express');
const router = express.Router();
const UsuarioController = require('../controllers/UsuarioController');
const authMiddleware = require('../middlewares/auth');

// Públicas
router.post('/registro', UsuarioController.postRegistro)
      .post('/login', UsuarioController.postLogin)
      .post('/logout', authMiddleware.verificarToken, UsuarioController.logout)
      



module.exports = router;