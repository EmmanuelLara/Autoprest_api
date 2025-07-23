const express = require('express');
const app = express();
const usuarioRoutes = require('./routes/usuarioRoutes'); 

// Middleware de Express
app.use(express.urlencoded({ extended: false }))
app.use(express.json())

// Rutas de la API
app.use('/api/usuarios', usuarioRoutes) // prefijo para rutas de usuarios

// Ruta base
app.get('/', (req, res) => {
    res.json({ mensaje: 'API de AutoPrest funcionando 🚗' });
});

module.exports = app;
