const express = require('express');
const app = express();
const router = require('./routes/usuarioRoutes'); 
const path = require('path');

// Parseo de body JSON y URL encoded
app.use(express.urlencoded({ extended: false }));
app.use(express.json());

// Servir archivos estáticos de la carpeta pública /uploads
app.use('/uploads', express.static(path.join(__dirname, 'public', 'uploads')));


// Prefijo para las rutas de usuarios
app.use('/', router);


app.get('/', (req, res) => {
    res.json({ mensaje: 'API de AutoPrest funcionando 🚗' });
});

module.exports = app;
