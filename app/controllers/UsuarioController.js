const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const Usuario = require('../models/Usuariomodel');

// Constantes
const ERROR_CREDENCIALES = 'Credenciales inválidas';
const ERROR_SERVIDOR = 'Error en el servidor';

// --- Función de validación separada ---
function validarRegistro({ nombre, email, pass, rol }) {
    const errores = [];

    if (!/^[A-Za-záéíóúÁÉÍÓÚñÑ\s]+$/.test(nombre?.trim())) {
        errores.push('Nombre inválido: solo letras y espacios');
    }

    if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email?.trim())) {
        errores.push('Correo electrónico inválido');
    }

    if (!/^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{6,}$/.test(pass)) {
        errores.push('La contraseña debe tener al menos 6 caracteres, una letra y un número');
    }

    if (rol && !/^(admin|cliente|gerente)$/.test(rol)) {
        errores.push('Rol inválido. Debe ser admin, cliente o gerente');
    }

    return errores;
}

// --- Registro ---
async function postRegistro(req, res) {
    const { nombre, email, pass, rol } = req.body;
    const errores = validarRegistro({ nombre, email, pass, rol });

    if (errores.length > 0) {
        return res.status(400).json({
            success: false,
            errores,
            detalles: { email: email?.trim(), pass: '***' }
        });
    }

    try {
        const emailLimpio = email.trim().toLowerCase();
        const yaExiste = await Usuario.findOne({ email: emailLimpio });

        if (yaExiste) {
            return res.status(409).json({
                success: false,
                mensaje: 'El correo ya está registrado'
            });
        }

        const passHasheada = await bcrypt.hash(pass, 12);

        const nuevoUsuario = await Usuario.create({
            nombre: nombre.trim(),
            email: emailLimpio,
            pass: passHasheada,
            rol: rol || 'cliente'
        });

        const token = generarToken(nuevoUsuario);

        res.status(201).json({
            success: true,
            token,
            usuario: {
                id: nuevoUsuario._id,
                nombre: nuevoUsuario.nombre,
                rol: nuevoUsuario.rol
            }
        });

    } catch (error) {
        console.error('Error en registro:', error);
        res.status(500).json({ success: false, mensaje: ERROR_SERVIDOR });
    }
}

// --- Login ---
async function postLogin(req, res) {
    const { email, pass } = req.body;

    try {
        const emailLimpio = email?.trim().toLowerCase();
        const usuario = await Usuario.findOne({ email: emailLimpio });

        if (!usuario || !(await bcrypt.compare(pass, usuario.pass))) {
            return res.status(401).json({ success: false, mensaje: ERROR_CREDENCIALES });
        }

        const token = generarToken(usuario);

        res.status(200).json({
            success: true,
            token,
            usuario: {
                id: usuario._id,
                nombre: usuario.nombre,
                rol: usuario.rol
            }
        });

    } catch (error) {
        console.error('Error en login:', error);
        res.status(500).json({ success: false, mensaje: ERROR_SERVIDOR });
    }
}

// --- Logout (simulado) ---
function logout(req, res) {
    res.status(200).json({
        success: true,
        mensaje: 'Sesión cerrada. Elimina el token en el cliente.'
    });
}

// --- Generador de Token JWT ---
function generarToken(usuario) {
    return jwt.sign(
        { id: usuario._id, rol: usuario.rol },
        process.env.JWT_SECRET || 'secreto_jwt',
        { expiresIn: '1h' }
    );
}

module.exports = {
    postRegistro,
    postLogin,
    logout
};
