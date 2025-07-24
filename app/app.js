const express = require('express');
const app = express();
const usuarioRoutes = require('./routes/usuarioRoutes'); 

// Parseo de body JSON y URL encoded
app.use(express.urlencoded({ extended: false }));
app.use(express.json());

// Servir archivos estáticos de la carpeta pública /uploads
app.use('/uploads', express.static('public/uploads'));

// Prefijo para las rutas de usuarios
app.use('/api', usuarioRoutes);

// Ruta base simple
app.get('/', (req, res) => {
    res.json({ mensaje: 'API de AutoPrest funcionando 🚗' });
});

module.exports = app;
