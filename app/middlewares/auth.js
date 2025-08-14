// middlewares/auth.js
const jwt = require('jsonwebtoken');
const config = require('../config/configuracion');

function verificarToken(req, res, next) {
    const authHeader = req.headers.authorization;
    
    if (!authHeader) {
        return res.status(401).json({ 
            success: false, 
            message: 'Token requerido',
            error: 'No se proporcionó el header Authorization'
        });
    }

    const parts = authHeader.split(' ');
    if (parts.length !== 2 || parts[0] !== 'Bearer') {
        return res.status(401).json({ 
            success: false, 
            message: 'Formato de token inválido',
            error: 'El token debe tener el formato: Bearer <token>'
        });
    }

    const token = parts[1];
    if (!token) {
        return res.status(401).json({ 
            success: false, 
            message: 'Token requerido',
            error: 'No se proporcionó el token'
        });
    }

    try {
        const decoded = jwt.verify(token, config.JWT_SECRET);
        
        // Verificar que el token tenga la estructura esperada
        if (!decoded._id || !decoded.rol) {
            return res.status(403).json({ 
                success: false, 
                message: 'Token inválido',
                error: 'El token no contiene la información requerida'
            });
        }

        req.user = decoded;
        next();
    } catch (error) {
        if (error.name === 'JsonWebTokenError') {
            return res.status(403).json({ 
                success: false, 
                message: 'Token inválido',
                error: 'El token proporcionado no es válido'
            });
        } else if (error.name === 'TokenExpiredError') {
            return res.status(403).json({ 
                success: false, 
                message: 'Token expirado',
                error: 'El token ha expirado, por favor inicie sesión nuevamente'
            });
        } else {
            return res.status(403).json({ 
                success: false, 
                message: 'Token inválido',
                error: 'Error al verificar el token'
            });
        }
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