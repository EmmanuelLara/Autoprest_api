
const Usuario = require('../models/Usuariomodel');
const bcrypt = require('bcryptjs');

// Obtener todos los usuarios
function obtenerUsuarios(req, res) {
    Usuario.find({}) // Usar find si estás en MongoDB
        .then(usuarios => {
            if (!usuarios.length) {
                return res.status(204).send({ mensaje: 'No hay usuarios registrados' });
            }
            return res.status(200).send({ usuarios });
        })
        .catch(e => {
            return res.status(404).send({ mensaje: `Error al consultar los usuarios: ${e}` });
        });
}

// Registrar nuevo usuario
function registrarUsuario(req, res) {
    const { nombre, email, pass, telefono,rol } = req.body;

    Usuario.findOne({ email })
        .then(existe => {
            if (existe) {
                return res.status(400).send({ mensaje: 'El correo ya está registrado' });
            }

            bcrypt.hash(pass, 10)
                .then(hash => {
                    const nuevoUsuario = new Usuario({ nombre, email, pass: hash, telefono,rol });
                    return nuevoUsuario.save();
                })
                .then(usuario => {
                    return res.status(200).send({ mensaje: 'Usuario creado exitosamente', usuario });
                })
                .catch(err => {
                    return res.status(500).send({ mensaje: `Error al crear usuario: ${err}` });
                });
        })
        .catch(err => {
            return res.status(500).send({ mensaje: `Error en la verificación de email: ${err}` });
        });
}

// Buscar usuario por campo
function buscarUsuario(req, res, next) {
    const consulta = {};
    consulta[req.params.key] = req.params.value;

    Usuario.find(consulta)
        .then(usuarios => {
            req.body = req.body || {};
            req.body.usuarios = usuarios || [];
            return next();
        })
        .catch(e => {
            req.body = req.body || {};
            req.body.e = e;
            return next();
        });
}

// Mostrar usuario(s) encontrado(s)
function mostrarUsuarios(req, res) {
    if (req.body.e) return res.status(404).send({ mensaje: `Error al buscar usuario: ${req.body.e}` });
    if (!req.body.usuarios.length) return res.status(204).send({ mensaje: 'No hay coincidencias' });

    return res.status(200).send({ usuarios: req.body.usuarios });
}

// Actualizar usuario
function actualizarUsuario(req, res) {
    const usuario = req.body.usuarios[0];

    const datosActualizados = {
        nombre: req.body.nombre,
        email: req.body.email,
        rol: req.body.rol,
        telefono: req.body.telefono
    };

    const promesa = req.body.pass
        ? bcrypt.hash(req.body.pass, 10).then(hash => {
            datosActualizados.pass = hash;
            return Usuario.updateOne({ _id: usuario._id }, datosActualizados);
        })
        : Usuario.updateOne({ _id: usuario._id }, datosActualizados);

    promesa
        .then(info => {
            return res.status(200).send({ mensaje: 'Usuario actualizado correctamente', info });
        })
        .catch(e => {
            return res.status(404).send({ mensaje: `Error al actualizar usuario: ${e}` });
        });
}

// Eliminar usuario
function eliminarUsuario(req, res) {
    const usuario = req.body.usuarios[0];

    Usuario.deleteOne({ _id: usuario._id })
        .then(info => {
            return res.status(200).send({ mensaje: 'Usuario eliminado correctamente', info });
        })
        .catch(e => {
            return res.status(404).send({ mensaje: `Error al eliminar usuario: ${e}` });
        });
}

module.exports = {
    obtenerUsuarios,
    registrarUsuario,
    buscarUsuario,
    mostrarUsuarios,
    actualizarUsuario,
    eliminarUsuario
};
