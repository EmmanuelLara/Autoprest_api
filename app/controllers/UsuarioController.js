
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const Usuario = require('../models/Usuariomodel');
const config = require('../config/configuracion');

const ERROR_CREDENCIALES = 'Credenciales inválidas';
const ERROR_SERVIDOR = 'Error en el servidor';

function validarRegistro({ nombre, telefono, email, pass, rol }) {
    const errores = [];

    // Validación del nombre: letras, espacios, acentos y caracteres comunes
    if (!nombre || !nombre.trim()) {
        errores.push('El nombre es obligatorio');
    } else if (nombre.trim().length < 2) {
        errores.push('El nombre debe tener al menos 2 caracteres');
    } else if (nombre.trim().length > 50) {
        errores.push('El nombre no puede exceder 50 caracteres');
    } else if (!/^[A-Za-zÀ-ÿ\s]+$/i.test(nombre.trim())) {
        errores.push('Nombre inválido: solo se permiten letras, espacios y acentos');
    }

    // Validación del teléfono: exactamente 10 dígitos
    if (!telefono) {
        errores.push('El teléfono es obligatorio');
    } else if (!/^[0-9]{10}$/.test(telefono.toString())) {
        errores.push('Teléfono inválido: deben ser 10 dígitos');
    }

    // Validación del email: formato válido y sin caracteres especiales problemáticos
    if (!email || !email.trim()) {
        errores.push('El correo electrónico es obligatorio');
    } else {
        const emailLimpio = email.trim();
        // Verificar caracteres especiales problemáticos primero
        if (emailLimpio.includes('$') || emailLimpio.includes('%') || emailLimpio.includes('#')) {
            errores.push('Correo electrónico inválido: no se permiten caracteres especiales ($, %, #)');
        } else {
            const emailRegex = /^[a-zA-Z0-9._+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
            if (!emailRegex.test(emailLimpio)) {
                errores.push('Correo electrónico inválido: formato incorrecto');
            }
        }
    }

    // Validación de la contraseña
    if (!pass) {
        errores.push('La contraseña es obligatoria');
    } else if (pass.length < 6) {
        errores.push('La contraseña debe tener al menos 6 caracteres');
    } else if (!/^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d@$!%*?&]{6,}$/.test(pass)) {
        errores.push('La contraseña debe contener al menos una letra y un número');
    }

    // Validación del rol
    if (rol && !/^(admin|cliente|gerente)$/.test(rol)) {
        errores.push('Rol inválido. Debe ser admin, cliente o gerente');
    }

    return errores;
}

function generarToken(usuario) {
    return jwt.sign(
        { _id: usuario._id, rol: usuario.rol, nombre: usuario.nombre, telefono: usuario.telefono },
        config.JWT_SECRET,
        { expiresIn: config.JWT_EXPIRES_IN }
    );
}

function postRegistro(req, res) {
    const { nombre, telefono, email, pass, rol } = req.body;

    // Validar datos de entrada
    const errores = validarRegistro({ nombre, telefono, email, pass, rol });
    if (errores.length > 0) {
        return res.status(400).json({ 
            mensaje: 'Datos de entrada inválidos',
            errores: errores 
        });
    }

    // Limpiar y normalizar datos
    const datosLimpios = {
        nombre: nombre.trim(),
        telefono: telefono.toString(),
        email: email.trim().toLowerCase(),
        pass: pass,
        rol: rol || 'cliente'
    };

    Usuario.findOne({ email: datosLimpios.email })
        .then(usuarioExistente => {
            if (usuarioExistente) {
                return res.status(409).json({ 
                    mensaje: 'El correo electrónico ya está registrado',
                    error: 'EMAIL_EXISTS'
                });
            }

            return bcrypt.hash(datosLimpios.pass, 10)
                .then(passHash => {
                    return Usuario.create({
                        nombre: datosLimpios.nombre,
                        telefono: datosLimpios.telefono,
                        email: datosLimpios.email,
                        pass: passHash,
                        rol: datosLimpios.rol
                    });
                })
                .then(nuevoUsuario => {
                    const token = generarToken(nuevoUsuario);
                    res.status(201).json({
                        mensaje: 'Usuario creado exitosamente',
                        token,
                        usuario: {
                            usuarioId: nuevoUsuario._id,
                            nombre: nuevoUsuario.nombre,
                            rol: nuevoUsuario.rol,
                            telefono: nuevoUsuario.telefono,
                            email: nuevoUsuario.email
                        }
                    });
                });
        })
        .catch(e => {
            console.error('Error en registro:', e);
            
            // Manejar errores específicos de MongoDB
            if (e.code === 11000) {
                return res.status(409).json({ 
                    mensaje: 'El correo electrónico ya está registrado',
                    error: 'EMAIL_EXISTS'
                });
            }
            
            res.status(500).json({ 
                mensaje: ERROR_SERVIDOR,
                error: 'INTERNAL_ERROR'
            });
        });
}

function postLogin(req, res) {
    const { email, pass } = req.body;

    // Normalizar el email igual que en el registro
    const emailNormalizado = email.trim().toLowerCase();

    Usuario.findOne({ email: emailNormalizado })
        .then(usuario => {
            if (!usuario) {
                return res.status(401).json({ mensaje: ERROR_CREDENCIALES });
            }

            return bcrypt.compare(pass, usuario.pass)
                .then(esValido => {
                    if (!esValido) {
                        return res.status(401).json({ mensaje: ERROR_CREDENCIALES });
                    }

                    const token = generarToken(usuario);
                    res.status(200).json({
                        mensaje: 'Login exitoso',
                        token,
                        usuario: {
                            usuarioId: usuario._id,
                            nombre: usuario.nombre,
                            rol: usuario.rol,
                            telefono: usuario.telefono,
                            email: usuario.email
                        }
                    });
                });
        })
        .catch(e => {
            console.error('Error en login', e);
            res.status(500).json({ mensaje: ERROR_SERVIDOR });
        });
}

function logout(req, res) {
    res.status(200).json({ mensaje: 'Token eliminado en cliente. Logout exitoso.' });
}

module.exports = {
    postRegistro,
    postLogin,
    logout
};
