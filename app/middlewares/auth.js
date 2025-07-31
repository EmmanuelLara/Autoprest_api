// middlewares/auth.js
const jwt = require('jsonwebtoken');
const config = require('../config/configuracion');

function verificarToken(req, res, next) {
    const token = req.headers.authorization?.split(' ')[1];
    if (!token) return res.status(401).json({ success: false, message: 'Token requerido' });

    try {
        req.user = jwt.verify(token, config.JWT_SECRET);
        next();
    } catch (error) {
        res.status(403).json({ success: false, message: 'Token inválido' });
    }
}

function verificarRol(...rolesPermitidos) {
    return (req, res, next) => {
        if (!req.user?.rol) {
            return res.status(401).json({ success: false, message: 'Usuario no autenticado' });
        }
        if (!rolesPermitidos.includes(req.user.rol)) {
            return res.status(403).json({ success: false, message: 'Permisos insuficientes' });
        }
        next();
    };
}

module.exports = { verificarToken, verificarRol };