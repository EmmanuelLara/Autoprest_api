
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const Usuario = require('../models/Usuariomodel');

const ERROR_CREDENCIALES = 'Credenciales inválidas';
const ERROR_SERVIDOR = 'Error en el servidor';

function validarRegistro({ nombre, telefono, email, pass, rol }) {
    const errores = [];

    if (!/^[A-Za-záéíóúÁÉÍÓÚñÑ\s]+$/.test(nombre?.trim())) {
        errores.push('Nombre inválido: solo letras y espacios');
    }

    if (!/^[0-9]{10}$/.test(telefono)) {
        errores.push('Teléfono inválido: deben ser 10 dígitos');
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

function generarToken(usuario) {
    return jwt.sign(
        { _id: usuario._id, rol: usuario.rol, nombre: usuario.nombre, telefono: usuario.telefono },
        process.env.JWT_SECRET || 'secreto_jwt',
        { expiresIn: '1h' }
    );
}

function postRegistro(req, res) {
    const { nombre, telefono, email, pass, rol } = req.body;

    const errores = validarRegistro({ nombre, telefono, email, pass, rol });
    if (errores.length) {
        return res.status(400).json({ errores });
    }

    Usuario.findOne({ email })
        .then(usuarioExistente => {
            if (usuarioExistente) {
                return res.status(409).json({ mensaje: 'Correo ya registrado' });
            }

            return bcrypt.hash(pass, 10)
                .then(passHash => {
                    return Usuario.create({
                        nombre,
                        telefono,
                        email,
                        pass: passHash,
                        rol: rol || 'cliente'
                    });
                })
                .then(nuevoUsuario => {
                    const token = generarToken(nuevoUsuario);
                    res.status(201).json({
                        mensaje: 'Registro exitoso',
                        token,
                        usuario: {
                            id: nuevoUsuario._id,
                            nombre: nuevoUsuario.nombre,
                            rol: nuevoUsuario.rol,
                            telefono: nuevoUsuario.telefono,
                            email: nuevoUsuario.email
                        }
                    });
                });
        })
        .catch(e => {
            console.error('Error en registro', e);
            res.status(500).json({ mensaje: ERROR_SERVIDOR });
        });
}

function postLogin(req, res) {
    const { email, pass } = req.body;

    Usuario.findOne({ email })
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
                            id: usuario._id,
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
